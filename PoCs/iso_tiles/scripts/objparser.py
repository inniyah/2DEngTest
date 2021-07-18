#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# See: https://en.wikipedia.org/wiki/Wavefront_.obj_file
# See: http://paulbourke.net/dataformats/obj/
# See: http://paulbourke.net/dataformats/mtl/

import sys
import os

from collections import OrderedDict

import numpy as np

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

class ObjMaterial:
    def __init__(self, name, path):
        self.path = path
        self.name = name

        self.Ka = None        # The ambient color of the material
        self.map_Ka = None    # the ambient texture map
        self.Kd = None        # The diffuse color
        self.map_Kd = None    # the diffuse texture map (most of the time, it will be the same as the ambient texture map)
        self.Ks = None        # The specular color
        self.map_Ks = None    # specular color texture map
        self.Ns = None        # The specular exponent
        self.map_Ns = None    # specular highlight component
        self.Tf = None        # The transmission filter
        self.d = None         # Transparency. This is referred to as being dissolved.
        self.map_d = None     # the alpha texture map
        self.map_bump = None  # bump map (which by default uses luminance channel of the image)
        self.map_disp = None  # displacement map
        self.map_decal = None # stencil decal texture (defaults to 'matte' channel of the image)

        self.Ni = None        # Optical density. This is also known as index of refraction.
        self.illum = None     # Illumination model
        self.sharpness = None # Sharpness of the reflections from the local reflection map
        self.refl = None      # Reflection map statement

        self.Pr = None        # Roughness
        self.map_Pr = None
        self.Pm = None        # Metallic
        self.map_Pm = None
        self.Ps = None        # Sheen
        self.map_Ps = None
        self.Pc = None        # Clearcoat thickness
        self.Pcr = None       # Clearcoat roughness
        self.Ke = None        # Emissive
        self.map_Ke = None
        self.aniso = None     # anisotropy
        self.anisor = None    # anisotropy rotation
        self.norm = None      # normal map, same format as "bump" parameter

    def __repr__(self):
        s = f"newmtl {self.name}\n"

        s += "# Material color and illumination statements:\n"
        if not self.Ka is None:
            s += f"Ka {' '.join([str(i) for i in self.Ka])}\n"
        if not self.Kd is None:
            s += f"Kd {' '.join([str(i) for i in self.Kd])}\n"
        if not self.Ks is None:
            s += f"Ks {' '.join([str(i) for i in self.Ks])}\n"
        if not self.Tf is None:
            s += f"Tf {' '.join([str(i) for i in self.Tf])}\n"

        if not self.illum is None:
            s += f"illum {self.illum}\n"
        if not self.d is None:
            s += f"d {self.d}\n"
        if not self.Ns is None:
            s += f"Ns {self.Ns}\n"
        if not self.sharpness is None:
            s += f"sharpness {self.sharpness}\n"
        if not self.Ni is None:
            s += f"Ni {self.Ni}\n"

        s += "# Texture map statements:\n"
        if not self.map_Ka is None:
            s += f"map_Ka {' '.join([str(i) for i in self.map_Ka])}\n"
        if not self.map_Kd is None:
            s += f"map_Kd {' '.join([str(i) for i in self.map_Kd])}\n"
        if not self.map_Ks is None:
            s += f"map_Ks {' '.join([str(i) for i in self.map_Ks])}\n"
        if not self.map_Ns is None:
            s += f"map_Ns {self.map_Ns}\n"
        if not self.map_bump is None:
            s += f"map_bump {' '.join([str(i) for i in self.map_bump])}\n"
        if not self.map_d is None:
            s += f"map_d {' '.join([str(i) for i in self.map_d])}\n"
        if not self.map_disp is None:
            s += f"disp {' '.join([str(i) for i in self.map_disp])}\n"
        if not self.map_decal is None:
            s += f"decal {' '.join([str(i) for i in self.map_decal])}\n"

        return s

    def getKdImage(self):
        return Image.open(os.path.join(os.path.dirname(self.path), self.map_Kd))

def load_material(file):
    materials = {}

    def parse_map(parts):
        corrected_path = os.path.join(os.path.dirname(file), parts[-1])
        if not os.path.exists(corrected_path):
            eprint(f"File '{corrected_path}' not found")
        parts[-1] = corrected_path
        return parts

    matname = os.path.splitext(os.path.basename(file))[0]
    matdata = None

    line_nb = 0
    for line in open(file, 'r'):
        line_nb += 1
        line = line.strip()
        if line.startswith('#'): continue

        values = line.split()
        if not values: continue
        cmd_id = values[0].strip().lower();

        if cmd_id == 'newmtl':
            matname = values[1].strip()
            matdata = ObjMaterial(matname, file)
            materials[matname] = matdata
        elif cmd_id == 'ns':
            matdata.Ns = values[1]
        elif cmd_id == 'ni':
            matdata.Ni = values[1]
        elif cmd_id == 'ka':
            matdata.Ka = values[1:4]
        elif cmd_id == 'kd':
            matdata.Kd = values[1:4]
        elif cmd_id == 'ks':
            matdata.Ks = values[1:4]
        elif cmd_id == 'ke':
            matdata.Ke = values[1:4]
        elif cmd_id == 'd':
            matdata.d = values[1]
        elif cmd_id == 'illum':
            matdata.illum = values[1]
        elif cmd_id == 'map_ka':
            matdata.map_Ka = parse_map(values[1:])
        elif cmd_id == 'map_kd':
            matdata.map_Kd = parse_map(values[1:])
        elif cmd_id == 'map_ks':
            matdata.map_Ks = parse_map(values[1:])
        elif cmd_id == 'map_ns':
            matdata.map_Ns = parse_map(values[1:])
        elif cmd_id == 'map_bump' or values[0] == 'bump':
            matdata.map_bump = parse_map(values[1:])
        else:
            eprint(f"Not supported: '{values[0]}' (line {line_nb})")

    return materials

class ObjModel:
    def __init__(self, name, path):
        self.path = path
        self.name = name

        self.v_list = []
        self.vt_list = []
        self.vn_list = []
        self.f_list = []

        self.groups = []
        self.materials = {}

    @staticmethod
    def print_face(parts):
        if parts[1] and parts[2]:
            return f"{parts[0]}/{parts[1]}/{parts[2]}"
        elif not parts[1]:
            return f"{parts[0]}//{parts[2]}"
        elif not parts[2]:
            return f"{parts[0]}/{parts[1]}"
        else:
            return f"{parts[0]}"

    def __repr__(self):
        s = ""
        for mtllib in sorted(set([v.path for k, v in self.materials.items()])):
            s += f"mtllib {mtllib}\n"
        if not self.name is None:
            s += f"o {self.name}\n"
        for v in self.v_list:
            s += f"v {' '.join([str(i) for i in v])}\n"
        for vn in self.vn_list:
            s += f"vn {' '.join([str(i) for i in vn])}\n"
        for vt in self.vt_list:
            s += f"vt {' '.join([str(i) for i in vt])}\n"
        #~ if not self.usemtl is None:
            #~ s += f"usemtl {self.usemtl}\n"
        for (gname, smap, usemtl) in self.groups:
            if len(smap):
                if gname: s += f"g {gname}\n"
                else: s += f"g\n"
                if usemtl: s += f"usemtl {usemtl}\n"
            for k in sorted(smap.keys()):
                if k and len(smap) > 1: s += f"s {k}\n"
                for n in smap[k]:
                    f = self.f_list[n - 1]
                    s += f"f {' '.join([self.print_face(i) for i in f])}\n"
        return s

    def calc_boundaries(self):
        min_x = float('inf')
        min_y = float('inf')
        min_z = float('inf')

        max_x = float('-inf')
        max_y = float('-inf')
        max_z = float('-inf')

        for x, y, z in self.v_list:
            min_x = min(min_x, float(x))
            min_y = min(min_y, float(y))
            min_z = min(min_z, float(z))

            max_x = max(max_x, float(x))
            max_y = max(max_y, float(y))
            max_z = max(max_z, float(z))

        return (min_x, min_y, min_z), (max_x, max_y, max_z)

    def to_ogre_xml(self, file=sys.stderr):
        def w(*args, **kwargs):
            print(*args, file=file, **kwargs)

        w(f'<?xml version="1.0"?>')
        w(f'<mesh>')
        w(f'	<submeshes>')

        for (gname, smap, usemtl) in self.groups:
            material_name = f'{usemtl}' if usemtl else ''
            if len(smap):
                w(f'		<submesh material="{material_name}" usesharedvertices="false" use32bitindexes="false" operationtype="triangle_list">')

            vertex = {}
            vindex = 1
            for k in sorted(smap.keys()):
                for n in smap[k]:
                    f = self.f_list[n - 1]
                    for i in f:
                        try:
                            vertex[tuple(i)]
                        except KeyError:
                            vertex[tuple(i)] = vindex
                            vindex += 1

            # Sort dictionary by value
            vertex = OrderedDict(sorted(vertex.items(), key=lambda t: t[1]))

            #~ print(f"vertex = {vertex}")

            faces = []
            for k in sorted(smap.keys()):
                for n in smap[k]:
                    f = self.f_list[n - 1]
                    for i in range(len(f) - 2):
                        faces.append([ vertex[tuple(f[0])], vertex[tuple(f[i+1])], vertex[tuple(f[i+2])] ])

            #~ print(f"faces = {faces}")

            w(f'			<faces count="{len(faces)}">')
            for face in faces:
                w(f'				<face v1="{face[0]-1}" v2="{face[1]-1}" v3="{face[2]-1}" />')
            w(f'			</faces>')

            w(f'			<geometry vertexcount="{len(vertex)}">')
            w(f'				<vertexbuffer positions="true" normals="true">')

            for (i_v, i_vt, i_vn), vnum in vertex.items():
                v = self.v_list[i_v - 1]
                vn = self.vn_list[i_vn - 1]

                w(f'					<vertex>')
                w(f'						<position x="{v[0]}" y="{v[1]}" z="{v[2]}" />')
                w(f'						<normal x="{vn[0]}" y="{vn[1]}" z="{vn[2]}" />')
                w(f'					</vertex>')

            w(f'				</vertexbuffer>')
            w(f'				<vertexbuffer texture_coord_dimensions_0="float2" texture_coords="1">')

            for (i_v, i_vt, i_vn), vnum in vertex.items():
                vt = self.vt_list[i_vt - 1]

                w(f'					<vertex>')
                w(f'						<texcoord u="{vt[0]}" v="{vt[1]}" />')
                w(f'					</vertex>')

            w(f'				</vertexbuffer>')
            w(f'			</geometry>')

            w(f'		</submesh>')

        w(f'	</submeshes>')
        w(f'</mesh>')

def load_model(file):
    objects = {}
    materials = {}

    objname = None
    objdata = None

    curr_usemtl = None
    curr_material = None
    curr_group = None
    curr_smooth = 0

    def parse_vertex(parts):
        return np.array(parts, dtype=np.float64)

    def parse_face(parts):
        return np.array([parse_face_vertex(part) for part in parts])

    def parse_face_vertex(part):
        if '//' in part:
            parts = part.split('//')
            return np.array([parts[0], 0, parts[1]], dtype=np.int64).T
        elif '/' in part:
            parts = part.split('/')
            return np.array(parts, dtype=np.int64).T
        else:
            return np.array([np.int64(part), 0, 0], dtype=np.int64).T

    line_nb = 0
    for line in open(file, 'r'):
        line_nb += 1
        line = line.strip()
        if line.startswith('#'): continue

        parts = line.split()
        nb_parts = len(parts)
        if nb_parts == 0: continue
        cmd_id = parts[0].strip().lower();

        if cmd_id == 'o' and nb_parts > 1:
            objname = parts[1].strip()
            objdata = ObjModel(objname, file)
            objects[objname] = objdata
            objdata.materials = materials
        elif cmd_id == 'mtllib' and nb_parts > 1:
            mtllib = os.path.join(os.path.dirname(file), parts[1])
            materials.update(load_material(mtllib))
        elif cmd_id == 'usemtl' and nb_parts > 1:
            curr_usemtl = parts[1].strip()
            curr_material = materials[parts[1]]
            if curr_group is not None and not len(curr_group[1]): curr_group[2] = curr_usemtl
        elif not objdata:
            objname = os.path.splitext(os.path.basename(file))[0]
            objdata = ObjModel(objname, file)
            objects[objname] = objdata
            objdata.materials = materials

        if cmd_id == 'g':
            curr_group = [parts[1] if nb_parts > 1 else None, {}, curr_usemtl]
            objdata.groups.append(curr_group)

        if cmd_id == 's' and nb_parts > 1:
            curr_smooth = int(parts[1])
        elif cmd_id == 'v' and nb_parts > 1:
            objdata.v_list.append(parse_vertex(parts[1:]))
        elif cmd_id == 'vt' and nb_parts > 1:
            objdata.vt_list.append(parse_vertex(parts[1:]))
        elif cmd_id == 'vn' and nb_parts > 1:
            objdata.vn_list.append(parse_vertex(parts[1:]))
        elif cmd_id == 'f' and nb_parts > 1:
            objdata.f_list.append(parse_face(parts[1:]))
            f_num = len(objdata.f_list)
            if curr_group is None:
                curr_group = [None, {}, curr_usemtl]
                objdata.groups.append(curr_group)
            try:
                curr_group[1][curr_smooth].append(f_num)
            except KeyError:
                curr_group[1][curr_smooth] = [f_num]

        if cmd_id not in ['o', 'mtllib', 'usemtl', 'g', 's', 'v', 'vt', 'vn', 'f']:
            eprint(f"Not supported: '{parts[0]}' (line {line_nb})")

    return objects, materials

if __name__ == "__main__":
    import argparse

    def extant_file(x):
        """
        'Type' for argparse - checks that file exists but does not open.
        """
        if not os.path.exists(x):
            # Argparse uses the ArgumentTypeError to give a rejection message like:
            # error: argument input: x does not exist
            raise argparse.ArgumentTypeError("{0} does not exist".format(x))
        return x

    arg_parser = argparse.ArgumentParser()
    arg_parser.add_argument(dest="file", type=extant_file, help="Obj File", metavar="FILE")
    arg_parser.add_argument('--verbose', '-v', action='count', default=0)
    arg_parser.add_argument('--dump-obj', action='store_true')
    arg_parser.add_argument('--dump-mtl', action='store_true')
    arg_parser.add_argument("-m", "--mesh", help="output mesh xml", default=None)
    args = arg_parser.parse_args()

    obj_filename = str(args.file)
    objects, materials = load_model(obj_filename)

    if args.dump_mtl:
        for mtl, mtldata in materials.items():
            print(f"{mtldata}")

    if args.dump_obj:
        for obj, objdata in objects.items():
            print(f"{objdata}")

        (min_x, min_y, min_z), (max_x, max_y, max_z) = objdata.calc_boundaries()
        #~ print(f"Min: ({min_x}, {min_y}, {min_z})")
        #~ print(f"Max: ({max_x}, {max_y}, {max_z})")

    if args.mesh:
        with open(args.mesh, 'w') as file:
            for obj, objdata in objects.items():
                objdata.to_ogre_xml(file)
