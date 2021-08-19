#!/usr/bin/env python3

import logging
import os
import sys

sys.path.append(os.path.normpath(os.path.abspath(os.path.dirname(__file__))))

LOG_CONSOLE_FORMAT = "%(message)s (%(pathname)s:%(lineno)d)"

class ColorStderr(logging.StreamHandler):
    def __init__(self, fmt=None):
        class AddColor(logging.Formatter):
            def __init__(self):
                super().__init__(fmt)
            def format(self, record: logging.LogRecord):
                msg = super().format(record)
                # Green/Cyan/Yellow/Red/Redder based on log level:
                color = '\033[1;' + ('32m', '36m', '33m', '31m', '41m')[min(4,int(4 * record.levelno / logging.FATAL))]
                return color + record.levelname + '\033[1;0m: ' + msg
        super().__init__(sys.stderr)
        self.setFormatter(AddColor())

from PyTexturePacker import Packer

def pack(in_dir, out_path):
    packer = Packer.create(max_width=2048, max_height=2048, bg_color=0xffffff00)
    # pack texture images under the directory "test_case/" and name the output images as "test_case".
    # "%d" in output file name "test_case%d" is a placeholder, which is a multipack index, starting with 0.
    packer.pack(in_dir, out_path, "")

if __name__ == '__main__':
    from argparse import ArgumentParser
    parser = ArgumentParser()

    # Output verbosity options.
    parser.add_argument("-q", "--quiet", help="set logging to ERROR",
                        action="store_const", dest="loglevel",
                        const=logging.ERROR, default=logging.INFO)
    parser.add_argument("-d", "--debug", help="set logging to DEBUG",
                        action="store_const", dest="loglevel",
                        const=logging.DEBUG, default=logging.INFO)
    parser.add_argument("-f", "--from", help="Directory with source images",
                        dest="from_dir", required=True, default=None)
    parser.add_argument("-t", "--to", help="Template name for output images (\"filename_%d\")",
                        dest="to_filename", required=False, default=None)

    args = parser.parse_args()

    logging.basicConfig(level=args.loglevel, format=LOG_CONSOLE_FORMAT, handlers=[ColorStderr(LOG_CONSOLE_FORMAT)])

    if not os.path.exists(args.from_dir) or not os.path.isdir(os.path.realpath(args.from_dir)):
        logging.error(f"Wrong input directory: '{args.from_dir}'")
        sys.exit(-1)

    if args.to_filename is None:
        args.to_filename = os.path.basename(args.from_dir.strip("/")) + "_%d"

    res = pack(args.from_dir, args.to_filename)

    sys.exit(res)
