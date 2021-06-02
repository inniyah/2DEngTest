#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import os
import json
import sys

try:
    import pygments
except ImportError:
    pygments = None
except AttributeError:
    pygments = None

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))

class JSONDebugEncoder(json.JSONEncoder):
    def default(self, obj):
        if isinstance(obj, set):
            return sorted(obj)
        if isinstance(obj, bytes):
            return escape(obj.decode('utf-8'))
        if isinstance(obj, object):
            return f"object ({type(obj)}): {obj}"
        try:
            ret = json.JSONEncoder.default(self, obj)
        except:
            ret = ('%s' % (obj,))
        return ret

# See: https://github.com/eliben/pyelftools/blob/master/examples/dwarf_decode_address.py

def decode_funcname(dwarfinfo, address):
    # Go over all DIEs in the DWARF information, looking for a subprogram
    # entry with an address range that includes the given address. Note that
    # this simplifies things by disregarding subprograms that may have
    # split address ranges.
    for CU in dwarfinfo.iter_CUs():
        for DIE in CU.iter_DIEs():
            try:
                if DIE.tag == 'DW_TAG_subprogram':
                    lowpc = DIE.attributes['DW_AT_low_pc'].value

                    # DWARF v4 in section 2.17 describes how to interpret the
                    # DW_AT_high_pc attribute based on the class of its form.
                    # For class 'address' it's taken as an absolute address
                    # (similarly to DW_AT_low_pc); for class 'constant', it's
                    # an offset from DW_AT_low_pc.
                    highpc_attr = DIE.attributes['DW_AT_high_pc']
                    highpc_attr_class = describe_form_class(highpc_attr.form)
                    if highpc_attr_class == 'address':
                        highpc = highpc_attr.value
                    elif highpc_attr_class == 'constant':
                        highpc = lowpc + highpc_attr.value
                    else:
                        print('Error: invalid DW_AT_high_pc class:',
                              highpc_attr_class)
                        continue

                    if lowpc <= address <= highpc:
                        return DIE.attributes['DW_AT_name'].value
            except KeyError:
                continue
    return None


def decode_file_line(dwarfinfo, address):
    # Go over all the line programs in the DWARF information, looking for
    # one that describes the given address.
    for CU in dwarfinfo.iter_CUs():
        # First, look at line programs to find the file/line for the address
        lineprog = dwarfinfo.line_program_for_CU(CU)
        prevstate = None
        for entry in lineprog.get_entries():
            # We're interested in those entries where a new state is assigned
            if entry.state is None:
                continue
            if entry.state.end_sequence:
                # if the line number sequence ends, clear prevstate.
                prevstate = None
                continue
            # Looking for a range of addresses in two consecutive states that
            # contain the required address.
            if prevstate and prevstate.address <= address < entry.state.address:
                filename = lineprog['file_entry'][prevstate.file - 1].name
                line = prevstate.line
                return filename, line
            prevstate = entry.state
    return None, None

# See: https://stackoverflow.com/questions/25638905/coloring-json-output-in-python
# Alternative: json.dump(obj, sys.stdout, cls=JSONDebugEncoder, indent=2, sort_keys=True)
def printAsJson(obj):
    obj_as_json = json.dumps(obj, cls=JSONDebugEncoder, indent=2, sort_keys=True)
    if pygments:
        from pygments import highlight, lexers, formatters
        obj_as_json = highlight(obj_as_json, lexers.JsonLexer(), formatters.TerminalFormatter())
    print(obj_as_json, file = sys.stderr)
