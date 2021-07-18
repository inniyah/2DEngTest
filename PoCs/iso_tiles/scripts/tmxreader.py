#! /usr/bin/env python3
# -*- coding: utf-8 -*-

# Copyright (c) 2011, DR0ID
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#     * Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.
#     * Redistributions in binary form must reproduce the above copyright
#       notice, this list of conditions and the following disclaimer in the
#       documentation and/or other materials provided with the distribution.
#     * Neither the name of the <organization> nor the
#       names of its contributors may be used to endorse or promote products
#       derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL DR0ID BE LIABLE FOR ANY
# DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
# (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
# ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
# SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

"""
TileMap loader for python for Tiled, a generic tile map editor
from http://mapeditor.org/ .
It loads the \*.tmx files produced by Tiled.


"""

# import logging
# #the following few lines are needed to use logging if this module used without
# # a previous call to logging.basicConfig()
# if 0 == len(logging.root.handlers):
    # logging.basicConfig(level=logging.DEBUG)

# _LOGGER = logging.getLogger('tiledtmxloader')
# if __debug__:
    # _LOGGER.debug('%s loading ...' % (__name__))

#  -----------------------------------------------------------------------------


import sys
import os

from xml.dom import minidom, Node
try:
    # python 2.x
    import StringIO
    from StringIO import StringIO
except:
    # python 3.x
    from io import StringIO

import struct
import array

#  -----------------------------------------------------------------------------
class TileMap(object):
    """
    {mapattr: value,
        layers: [{layerattr, data: [gid]},
                 {objects: [{objectattr}]}
                 ],
        tilesets: [tileset]
        }



    The TileMap holds all the map data.

    :Ivariables:
        orientation : string
            orthogonal or isometric or hexagonal or shifted
        tilewidth : int
            width of the tiles (for all layers)
        tileheight : int
            height of the tiles (for all layers)
        width : int
            width of the map (number of tiles)
        height : int
            height of the map (number of tiles)
        version : string
            version of the map format
        tile_sets : list
            list of TileSet
        properties : dict
            the propertis set in the editor, name-value pairs, strings
        layers : list
            list of TileLayer
        map_file_name : string
            file name of the map
        tiles : dict
            dict containint {gid : Tile}
        named_layers : dict of string:TledLayer
            dict containing {name : TileLayer}
        named_tile_sets : dict
            dict containing {name : TileSet}
        pixel_width : int
            width of the map in pixels
        pixel_height : int
            height of the map in pixels

    """

    def __init__(self):
#        This is the top container for all data. The gid is the global id
#       (for a image).
#        Before calling convert most of the values are strings. Some additional
#        values are also calculated, see convert() for details. After calling
#        convert, most values are integers or floats where appropriat.
        """
        The TileMap holds all the map data.
        """
        # set through parser
        self.orientation = None
        self.tileheight = 0
        self.tilewidth = 0
        self.width = 0
        self.height = 0
        self.version = 0
        self.tile_sets = [] # TileSet
        self.cells = {} # {gid : Cell}
        # ISSUE 9: object groups should be in the same order as layers
        self.layers = [] # WorldTileLayer <- what order? back to front (guessed)
        # self.object_groups = []
        self.properties = {} # {name: value}
        # additional info
        self.pixel_width = 0
        self.pixel_height = 0
        self.named_layers = {} # {name: layer}
        self.named_tile_sets = {} # {name: tile_set}
        self.map_file_name = ""
        self.tiles = {} # {gid: Tile}

    def convert(self):
        """
        Converts numerical values from strings to numerical values.
        It also calculates or set additional data:
        pixel_width
        pixel_height
        named_layers
        named_tile_sets
        """
        self.tilewidth = int(self.tilewidth)
        self.tileheight = int(self.tileheight)
        self.width = int(self.width)
        self.height = int(self.height)
        self.pixel_width = self.width * self.tilewidth
        self.pixel_height = self.height * self.tileheight

        for layer in self.layers:
            # ISSUE 9
            if not layer.is_object_group:
                layer.tilewidth = self.tilewidth
                layer.tileheight = self.tileheight
                self.named_layers[layer.name] = layer
            layer.convert()

        for tile_set in self.tile_sets:
            self.named_tile_sets[tile_set.name] = tile_set
            tile_set.spacing = int(tile_set.spacing)
            tile_set.margin = int(tile_set.margin)
            for img in tile_set.images:
                if img.trans:
                    img.trans = (int(img.trans[:2], 16), \
                                 int(img.trans[2:4], 16), \
                                 int(img.trans[4:], 16))

    def decode(self):
        """
        Decodes the TileLayer encoded_content and saves it in decoded_content.
        """
        for layer in self.layers:
            if not layer.is_object_group:
                self._decode_layer(layer)
                layer.generate_2D()

    def _decode_layer(self, layer):
        """
        Converts the contents in a list of integers which are the gid of the
        used tiles. If necessary it decodes and uncompresses the contents.
        """
        layer.decoded_content = []
        if layer.encoded_content:
            content = layer.encoded_content
            if layer.encoding:
                if layer.encoding.lower() == 'base64':
                    content = decode_base64(content)
                elif layer.encoding.lower() == 'csv':
                    list_of_lines = content.split()
                    for line in list_of_lines:
                        layer.decoded_content.extend(line.split(','))
                    self._fill_decoded_content(layer, list(map(int, \
                                [val for val in layer.decoded_content if val])))
                    content = ""
                else:
                    raise Exception('unknown data encoding %s' % \
                                                                (layer.encoding))
            else:
                # in the case of xml the encoded_content already contains a
                # list of integers
                self._fill_decoded_content(layer, list(map(int, layer.encoded_content)))

                content = ""
            if layer.compression:
                if layer.compression == 'gzip':
                    content = decompress_gzip(content)
                elif layer.compression == 'zlib':
                    content = decompress_zlib(content)
                else:
                    raise Exception('unknown data compression %s' % \
                                                            (layer.compression))
        else:
            raise Exception('no encoded content to decode')

        if content:
            struc = struct.Struct("<" + "I" * layer.width * layer.height)
            val = struc.unpack(content)
            self._fill_decoded_content(layer, val)

    def _fill_decoded_content(self, layer, gid_list):
        layer.decoded_content = array.array('L')
        layer.decoded_content.extend(gid_list)# make Cell

        # TODO: generate property grid here??


#  -----------------------------------------------------------------------------


class TileSet(object):
    """
    A tileset holds the tiles and its images.

    :Ivariables:
        firstgid : int
            the first gid of this tileset
        name : string
            the name of this TileSet
        images : list
            list of TileImages
        tiles : list
            list of Tiles
        indexed_images : dict
            after calling load() it is dict containing id: image
        spacing : int
            the spacing between tiles
        marging : int
            the marging of the tiles
        properties : dict
            the propertis set in the editor, name-value pairs
        tilewidth : int
            the actual width of the tile, can be different from the tilewidth
            of the map
        tilehight : int
            the actual hight of th etile, can be different from the tilehight
            of the  map

    """

    def __init__(self):
        self.firstgid = 0
        self.name = None
        self.images = [] # TileImage
        self.tiles = [] # Tile
        self.indexed_images = {} # {id:image}
        self.spacing = 0
        self.margin = 0
        self.properties = {}
        self.tileheight = 0
        self.tilewidth = 0

#  -----------------------------------------------------------------------------

class TileImage(object):
    """
    An image of a tile or just an image.

    :Ivariables:
        id : int
            id of this image (has nothing to do with gid)
        format : string
            the format as string, only 'png' at the moment
        source : string
            filename of the image. either this is set or the content
        encoding : string
            encoding of the content
        trans : tuple of (r,g,b)
            the colorkey color, raw as hex, after calling convert just a
            (r,g,b) tuple
        properties : dict
            the propertis set in the editor, name-value pairs
        image : TileImage
            after calling load the pygame surface
    """

    def __init__(self):
        self.id = 0
        self.format = None
        self.source = None
        self.encoding = None # from <data>...</data>
        self.content = None # from <data>...</data>
        self.image = None
        self.trans = None
        self.properties = {} # {name: value}

#  -----------------------------------------------------------------------------

class Tile(object):
    """
    A single tile.

    :Ivariables:
        id : int
            id of the tile gid = TileSet.firstgid + Tile.id
        images : list of :class:TileImage
            list of TileImage, either its 'id' or 'image data' will be set
        properties : dict of name:value
            the propertis set in the editor, name-value pairs
        tile_set : TileSet
            the tileset this tile belongs to
    """

# [20:22]	DR0ID_: to sum up: there are two use cases,
# if the tile element has a child element 'image' then tile is
# standalone with its own id and
# the other case where a tileset is present then it
# referes to the image with that id in the tileset

    def __init__(self, gid):
        self.id = 0
        self.gid = gid
        self.images = [] # uses TileImage but either only id will be set or image data
        self.properties = {} # {name: value}

#  -----------------------------------------------------------------------------

class Cell(object):
    """
    A single tile.

    :Ivariables:
        id : int
            id of the tile gid = TileSet.firstgid + Tile.id
        images : list of :class:TileImage
            list of TileImage, either its 'id' or 'image data' will be set
        properties : dict of name:value
            the propertis set in the editor, name-value pairs
        tile_set : TileSet
            the tileset this tile belongs to
    """

# [20:22]	DR0ID_: to sum up: there are two use cases,
# if the tile element has a child element 'image' then tile is
# standalone with its own id and
# the other case where a tileset is present then it
# referes to the image with that id in the tileset

    def __init__(self, gid, tile_set):
        self.gid = gid
        self.properties = {} # {name: value}
        self.tile_set = tile_set

#  -----------------------------------------------------------------------------

class TileLayer(object):
    """
    A layer of the world.

    :Ivariables:
        x : int
            position of layer in the world in number of tiles (not pixels)
        y : int
            position of layer in the world in number of tiles (not pixels)
        width : int
            number of tiles in x direction
        height : int
            number of tiles in y direction
        pixel_width : int
            width of layer in pixels
        pixel_height : int
            height of layer in pixels
        name : string
            name of this layer
        opacity : float
            float from 0 (full transparent) to 1.0 (opaque)
        decoded_content : list
            list of graphics id going through the map::

                e.g [1, 1, 1, ]
                where decoded_content[0]   is (0,0)
                      decoded_content[1]   is (1,0)
                      ...
                      decoded_content[w]   is (width,0)
                      decoded_content[w+1] is (0,1)
                      ...
                      decoded_content[w * h]  is (width,height)

                usage: graphics id = decoded_content[tile_x + tile_y * width]
        content2D : list
            list of list, usage: graphics id = content2D[x][y]

    """

    def __init__(self):
        self.width = 0
        self.height = 0
        self.x = 0
        self.y = 0
        self.pixel_width = 0
        self.pixel_height = 0
        self.name = None
        self.opacity = 0
        self.encoding = None
        self.compression = None
        self.encoded_content = None
        self.decoded_content = []
        self.visible = True
        self.properties = {} # {name: value}
        self.is_object_group = False    # ISSUE 9
        self._content2D = None

    # def decode(self):
        # """
        # Converts the contents in a list of integers which are the gid of the
        # used tiles. If necessairy it decodes and uncompresses the contents.
        # """
        # self.decoded_content = []
        # if self.encoded_content:
            # content = self.encoded_content
            # if self.encoding:
                # if self.encoding.lower() == 'base64':
                    # content = decode_base64(content)
                # elif self.encoding.lower() == 'csv':
                    # list_of_lines = content.split()
                    # for line in list_of_lines:
                        # self.decoded_content.extend(line.split(','))
                    # self.decoded_content = list(map(int, \
                                # [val for val in self.decoded_content if val]))
                    # content = ""
                # else:
                    # raise Exception('unknown data encoding %s' % \
                                                                # (self.encoding))
            # else:
                # # in the case of xml the encoded_content already contains a
                # # list of integers
                # self.decoded_content = list(map(int, self.encoded_content))
                # content = ""
            # if self.compression:
                # if self.compression == 'gzip':
                    # content = decompress_gzip(content)
                # elif self.compression == 'zlib':
                    # content = decompress_zlib(content)
                # else:
                    # raise Exception('unknown data compression %s' % \
                                                            # (self.compression))
        # else:
            # raise Exception('no encoded content to decode')

        # # struc = struct.Struct("<" + "I" * self.width)
        # # struc_unpack_from = struc.unpack_from
        # # self_decoded_content_extend = self.decoded_content.extend
        # # for idx in range(0, len(content), 4 * self.width):
            # # val = struc_unpack_from(content, idx)
            # # self_decoded_content_extend(val)
# ####
        # struc = struct.Struct("<" + "I" * self.width * self.height)
        # val = struc.unpack(content) # make Cell
        # # self.decoded_content.extend(val)


        # self.decoded_content = array.array('I')
        # self.decoded_content.extend(val)


        # # arr = array.array('I')
        # # arr.fromlist(self.decoded_content)
        # # self.decoded_content = arr

        # # TODO: generate property grid here??

        # self._gen_2D()

    def generate_2D(self):
        self.content2D = []

        # generate the needed lists and fill them
        for xpos in range(self.width):
            self.content2D.append(array.array('I'))
            for ypos in range(self.height):
                self.content2D[xpos].append( \
                                self.decoded_content[xpos + ypos * self.width])

    def pretty_print(self):
        num = 0
        for y in range(int(self.height)):
            output = ""
            for x in range(int(self.width)):
                output += str(self.decoded_content[num])
                num += 1

    def convert(self):
        self.opacity = float(self.opacity)
        self.x = int(self.x)
        self.y = int(self.y)
        self.width = int(self.width)
        self.height = int(self.height)
        self.pixel_width = self.width * self.tilewidth
        self.pixel_height = self.height * self.tileheight
        self.visible = bool(int(self.visible))

    # def get_visible_tile_range(self, xmin, ymin, xmax, ymax):
        # tile_w = self.pixel_width / self.width
        # tile_h = self.pixel_height / self.height
        # left = int(round(float(xmin) / tile_w)) - 1
        # right = int(round(float(xmax) / tile_w)) + 2
        # top = int(round(float(ymin) / tile_h)) - 1
        # bottom = int(round(float(ymax) / tile_h)) + 2
        # return (left, top, left - right, top - bottom)

    # def get_tiles(self, xmin, ymin, xmax, ymax):
        # tiles = []
        # if self.visible:
            # for ypos in range(ymin, ymax):
                # for xpos in range(xmin, xmax):
                    # try:
                        # img_idx = self.content2D[xpos][ypos]
                        # if img_idx:
                            # tiles.append((xpos, ypos, img_idx))
                    # except IndexError:
                        # pass
        # return tiles

#  -----------------------------------------------------------------------------


class MapObjectGroupLayer(object):
    """
    Group of objects on the map.

    :Ivariables:
        x : int
            the x position
        y : int
            the y position
        width : int
            width of the bounding box (usually 0, so no use)
        height : int
            height of the bounding box (usually 0, so no use)
        name : string
            name of the group
        objects : list
            list of the map objects

    """

    def __init__(self):
        self.width = 0
        self.height = 0
        self.name = None
        self.objects = []
        self.x = 0
        self.y = 0
        self.visible = True
        self.properties = {} # {name: value}
        self.is_object_group = True # ISSUE 9

    def convert(self):
        self.x = int(self.x)
        self.y = int(self.y)
        self.width = int(self.width)
        self.height = int(self.height)
        for map_obj in self.objects:
            map_obj.x = int(map_obj.x)
            map_obj.y = int(map_obj.y)
            map_obj.width = int(map_obj.width)
            map_obj.height = int(map_obj.height)

#  -----------------------------------------------------------------------------

class MapObject(object):
    """
    A single object on the map.

    :Ivariables:
        x : int
            x position relative to group x position
        y : int
            y position relative to group y position
        width : int
            width of this object
        height : int
            height of this object
        type : string
            the type of this object
        image_source : string
            source path of the image for this object
        image : :class:TileImage
            after loading this is the pygame surface containing the image
    """
    def __init__(self):
        self.name = None
        self.x = 0
        self.y = 0
        self.width = 0
        self.height = 0
        self.type = None
        self.image_source = None
        self.image = None
        self.properties = {} # {name: value}

#  -----------------------------------------------------------------------------
def decode_base64(in_str, string_encoding='latin-1'):
    """
    Decodes a base64 string and returns it.

    :Parameters:
        in_str : string
            base64 encoded string
        string_encoding : string
            the encoding of the string, default: 'latin-1'

    :returns: decoded string
    """
    import base64
    return base64.decodebytes(in_str.encode(string_encoding))

#  -----------------------------------------------------------------------------
def decompress_gzip(in_str, string_encoding='latin-1'):
    """
    Uncompresses a gzip string and returns it.

    :Parameters:
        in_str : string
            gzip compressed string
        string_encoding : string
            the encoding of the string, default: 'latin-1'

    :returns: uncompressed string
    """
    import gzip

    if sys.version_info > (2, ):
        from io import BytesIO
        copmressed_stream = BytesIO(in_str)
    else:
        # gzip can only handle file object therefore using StringIO
        copmressed_stream = StringIO(in_str.decode(string_encoding))
    gzipper = gzip.GzipFile(fileobj=copmressed_stream)
    content = gzipper.read()
    gzipper.close()
    return content

#  -----------------------------------------------------------------------------
def decompress_zlib(in_str):
    """
    Uncompresses a zlib string and returns it.

    :Parameters:
        in_str : string
            zlib compressed string

    :returns: uncompressed string
    """
    import zlib
    content = zlib.decompress(in_str)
    return content
#  -----------------------------------------------------------------------------
def printer(obj, ident=''):
    """
    Helper function, prints a hirarchy of objects.
    """
    import inspect
    print(ident + obj.__class__.__name__.upper())
    ident += '    '
    lists = []
    for name in dir(obj):
        elem = getattr(obj, name)
        if isinstance(elem, list) and name != 'decoded_content':
            lists.append(elem)
        elif not inspect.ismethod(elem):
            if not name.startswith('__'):
                if name == 'data' and elem:
                    print(ident + 'data = ')
                    printer(elem, ident + '    ')
                else:
                    print(ident + '%s\t= %s' % (name, getattr(obj, name)))
    for objt_list in lists:
        for _obj in objt_list:
            printer(_obj, ident + '    ')

#  -----------------------------------------------------------------------------

class VersionError(Exception): pass

#  -----------------------------------------------------------------------------
class TileMapParser(object):
    """
    Allows to parse and decode map files for 'Tiled', a open source map editor
    written in java. It can be found here: http://mapeditor.org/
    """

    def _build_tile_set(self, tile_set_node, world_map):
        tile_set = TileSet()
        self._set_attributes(tile_set_node, tile_set)

        if hasattr(tile_set, "source"):
            tile_set = self._parse_tsx(tile_set, world_map)
        else:
            tile_set = self._get_tile_set(tile_set_node, tile_set, self.map_file_name, world_map)
        world_map.tile_sets.append(tile_set)

    def _parse_tsx(self, tile_set, world_map):
        file_name = tile_set.source
        # ISSUE 5: the *.tsx file is probably relative to the *.tmx file
        if not os.path.isabs(file_name):
            # print "map file name", self.map_file_name
            file_name = self._get_abs_path(self.map_file_name, file_name)
        with open(file_name, "rb") as file:
            dom = minidom.parseString(file.read())
        # tile_set = TileSet()
        for node in self._get_nodes(dom.childNodes, 'tileset'):
            # TODO: is there only one Tileset per *.tsx file????
            self._set_attributes(node, tile_set)
            tile_set = self._get_tile_set(node, tile_set, file_name, world_map)
            break
        return tile_set

    def _get_tile_set(self, tile_set_node, tile_set, base_path, world_map):
        self._build_tile_set_images(tile_set_node, tile_set, base_path)
        firstgid = int(tile_set.firstgid)
        # for image in tile_set.images:
        # TODO: can't rely on image.width and image.height because they are optional
        #     for id in range(0, (int(image.width) // int(tile_set.tilewidth)) * (int(image.height) // int(tile_set.tileheight))):
        #         gid = firstgid + id
        #         # TODO: cell creation should be lazy done when layers are read in????
        #         cell = Cell(gid, tile_set)
        #         cell.properties = dict(tile_set.properties)
        #         world_map.tiles[gid] = cell
        for node in self._get_nodes(tile_set_node.childNodes, 'tile'):
            self._build_tile_set_tile(node, tile_set, world_map)
        return tile_set

    def _build_tile_set_images(self, tile_set_node, tile_set, base_path):
        # printer(tile_set)
        for node in self._get_nodes(tile_set_node.childNodes, 'image'):
            self._build_tile_set_image(node, tile_set, base_path)

    def _build_tile_set_image(self, image_node, tile_set, base_path):
        image = TileImage()
        self._set_attributes(image_node, image)
        # id of TileImage has to be set! -> Tile.TileImage will only have id set
        for node in self._get_nodes(image_node.childNodes, 'data'):
            self._set_attributes(node, image)
            image.content = node.childNodes[0].nodeValue
        image.source = self._get_abs_path(base_path, image.source) # ISSUE 5
        tile_set.images.append(image)
        # printer(image)

    def _get_abs_path(self, base, relative):
        if os.path.isabs(relative):
            return relative
        if os.path.isfile(base):
            base = os.path.dirname(base)
        return os.path.abspath(os.path.join(base, relative))

    def _build_tile_set_tile(self, tile_set_tile_node, tile_set, world_map):
        tile_gid = int(tile_set.firstgid) + int(tile_set_tile_node.attributes.get("id").nodeValue)
        tile = Tile(tile_gid)
        self._set_attributes(tile_set_tile_node, tile)
        try:
            world_map.tiles[tile_gid].properties.update(tile.properties)
        except KeyError:
            cell = Cell(tile_gid, tile_set)
            cell.properties = dict(tile_set.properties)
            world_map.tiles[tile_gid] = cell
            world_map.tiles[tile_gid].properties.update(tile.properties)
        for node in self._get_nodes(tile_set_tile_node.childNodes, 'image'):
            self._build_tile_set_tile_image(node, tile)
        tile_set.tiles.append(tile)

    def _build_tile_set_tile_image(self, tile_node, tile):
        tile_image = TileImage()
        self._set_attributes(tile_node, tile_image)
        for node in self._get_nodes(tile_node.childNodes, 'data'):
            self._set_attributes(node, tile_image)
            tile_image.content = node.childNodes[0].nodeValue
        tile.images.append(tile_image)

    def _build_layer(self, layer_node, world_map):
        layer = TileLayer()
        self._set_attributes(layer_node, layer)
        for node in self._get_nodes(layer_node.childNodes, 'data'):
            self._set_attributes(node, layer)
            if layer.encoding:
                layer.encoded_content = node.lastChild.nodeValue
            else:
                layer.encoded_content = []
                for child in node.childNodes:
                    if child.nodeType == Node.ELEMENT_NODE and child.nodeName == "tile":
                        val = child.attributes["gid"].nodeValue
                        #print child, val
                        layer.encoded_content.append(val)
        world_map.layers.append(layer)

    def _build_group(self, group_node, world_map):
        for node in self._get_nodes(group_node.childNodes, 'layer'):
            self._build_layer(node, world_map)
        for node in self._get_nodes(group_node.childNodes, 'group'):
            self._build_group(node, world_map)

    def _build_world_map(self, world_node):
        world_map = TileMap()
        self._set_attributes(world_node, world_map)
        if world_map.version not in ["1.0", "1.1", "1.2"]:
            raise VersionError('this parser was made for maps of version 1.0, found version %s' % world_map.version)
        for node in self._get_nodes(world_node.childNodes, 'tileset'):
            self._build_tile_set(node, world_map)
        for node in self._get_nodes(world_node.childNodes, 'layer'):
            self._build_layer(node, world_map)
        for node in self._get_nodes(world_node.childNodes, 'group'):
            self._build_group(node, world_map)
        for node in self._get_nodes(world_node.childNodes, 'objectgroup'):
            self._build_object_groups(node, world_map)
        return world_map

    def _build_object_groups(self, object_group_node, world_map):
        object_group = MapObjectGroupLayer()
        self._set_attributes(object_group_node,  object_group)
        for node in self._get_nodes(object_group_node.childNodes, 'object'):
            tiled_object = MapObject()
            self._set_attributes(node, tiled_object)
            for img_node in self._get_nodes(node.childNodes, 'image'):
                tiled_object.image_source = \
                                        img_node.attributes['source'].nodeValue
            object_group.objects.append(tiled_object)
        # ISSUE 9
        world_map.layers.append(object_group)

    # -- helpers -- #
    def _get_nodes(self, nodes, name):
        for node in nodes:
            if node.nodeType == Node.ELEMENT_NODE and node.nodeName == name:
                yield node

    def _set_attributes(self, node, obj):
        attrs = node.attributes
        for attr_name in list(attrs.keys()):
            setattr(obj, attr_name, attrs.get(attr_name).nodeValue)
        self._get_properties(node, obj)

    def _get_properties(self, node, obj):
        props = {}
        for properties_node in self._get_nodes(node.childNodes, 'properties'):
            for property_node in self._get_nodes(properties_node.childNodes, 'property'):
                try:
                    props[property_node.attributes['name'].nodeValue] = \
                                    property_node.attributes['value'].nodeValue
                except KeyError:
                    props[property_node.attributes['name'].nodeValue] = \
                                            property_node.lastChild.nodeValue
        obj.properties.update(props)


    # -- parsers -- #
    def parse(self, file_name):
        """
        Parses the given map. Does no decoding nor loading of the data.
        :return: instance of TileMap
        """
        self.map_file_name = os.path.abspath(file_name)
        with open(self.map_file_name, "rb") as tmx_file:
            dom = minidom.parseString(tmx_file.read())
        for node in self._get_nodes(dom.childNodes, 'map'):
            world_map = self._build_world_map(node)
            break
        world_map.map_file_name = self.map_file_name
        # printer(world_map)
        world_map.convert()
        return world_map

    def parse_decode(self, file_name):
        """
        Parses the map but additionally decodes the data.
        :return: instance of TileMap
        """
        world_map = self.parse(file_name)
        world_map.decode()
        return world_map


#  -----------------------------------------------------------------------------

class AbstractResourceLoader(object):
    """
    Abstract base class for the resource loader.

    """

    FLIP_X = 1 << 31
    FLIP_Y = 1 << 30
    FLIP_DIAGONAL = 1 << 29

    def __init__(self):
        self.indexed_tiles = {} # {gid: (offsetx, offsety, image}
        self.world_map = None
        self._img_cache = {}

    def _load_image(self, filename, colorkey=None): # -> image
        """
        Load a single image.

        :Parameters:
            filename : string
                Path to the file to be loaded.
            colorkey : tuple
                The (r, g, b) color that should be used as colorkey
                (or magic color).
                Default: None

        :rtype: image

        """
        raise NotImplementedError('This should be implemented in a inherited class')

    def _load_image_file_like(self, file_like_obj, colorkey=None): # -> image
        """
        Load a image from a file like object.

        :Parameters:
            file_like_obj : file
                This is the file like object to load the image from.
            colorkey : tuple
                The (r, g, b) color that should be used as colorkey
                (or magic color).
                Default: None

        :rtype: image
        """
        raise NotImplementedError('This should be implemented in a inherited class')

    def _load_image_parts(self, filename, margin, spacing, tilewidth, tileheight, colorkey=None): #-> [images]
        """
        Load different tile images from one source image.

        :Parameters:
            filename : string
                Path to image to be loaded.
            margin : int
                The margin around the image.
            spacing : int
                The space between the tile images.
            tilewidth : int
                The width of a single tile.
            tileheight : int
                The height of a single tile.
            colorkey : tuple
                The (r, g, b) color that should be used as colorkey
                (or magic color).
                Default: None

        Luckily that iteration is so easy in python::

            ...
            w, h = image_size
            for y in xrange(margin, h, tileheight + spacing):
                for x in xrange(margin, w, tilewidth + spacing):
                    ...

        :rtype: a list of images
        """
        raise NotImplementedError('This should be implemented in a inherited class')

    def load(self, tile_map):
        """
        Loads the image data into the single images.
        """
        self.world_map = tile_map
        for tile_set in tile_map.tile_sets:
            # do images first, because tiles could reference it
            for img in tile_set.images:
                if img.source:
                    self._load_image_from_source(tile_map, tile_set, img)
                else:
                    tile_set.indexed_images[img.id] = self._load_tile_image(img)
            # tiles
            for tile in tile_set.tiles:
                for img in tile.images:
                    if not img.content and not img.source:
                        # only image id set
                        indexed_img = tile_set.indexed_images[img.id]
                        self.indexed_tiles[int(tile_set.firstgid) + int(tile.id)] = (0, 0, indexed_img)
                    else:
                        if img.source:
                            self._load_image_from_source(tile_map, tile_set, img)
                        else:
                            indexed_img = self._load_tile_image(img)
                            self.indexed_tiles[int(tile_set.firstgid) + int(tile.id)] = (0, 0, indexed_img)

    def _load_image_from_source(self, tile_map, tile_set, a_tile_image):
        # relative path to file
        img_path = os.path.join(os.path.dirname(tile_map.map_file_name), \
                                                            a_tile_image.source)
        tile_width = int(tile_map.tilewidth)
        tile_height = int(tile_map.tileheight)
        if tile_set.tileheight:
            tile_width = int(tile_set.tilewidth)
        if tile_set.tilewidth:
            tile_height = int(tile_set.tileheight)
        offsetx = 0
        offsety = 0
        # the offset is used for pygame because the origin is topleft in pygame
        if tile_height > tile_map.tileheight:
            offsety = tile_height - tile_map.tileheight
        idx = 0
        for image in self._load_image_parts(img_path, \
                    tile_set.margin, tile_set.spacing, \
                    tile_width, tile_height, a_tile_image.trans):
            self.indexed_tiles[int(tile_set.firstgid) + idx] = \
                                                    (offsetx, -offsety, image)
            idx += 1

    def _load_tile_image(self, a_tile_image):
        img_str = a_tile_image.content
        if a_tile_image.encoding:
            if a_tile_image.encoding == 'base64':
                img_str = decode_base64(a_tile_image.content)
            else:
                raise Exception('unknown image encoding %s' % a_tile_image.encoding)
        sio = StringIO(img_str)
        new_image = self._load_image_file_like(sio, a_tile_image.trans)
        return new_image

#  -----------------------------------------------------------------------------

if __name__ == "__main__":
	import argparse
	from PIL import Image

	class MapResourceLoader(AbstractResourceLoader):
		def load(self, tile_map):
			AbstractResourceLoader.load(self, tile_map)

			for layer in self.world_map.layers:
				if layer.is_object_group:
					continue

				for gid in layer.decoded_content:
					if gid not in self.indexed_tiles:
						if gid & self.FLIP_X or gid & self.FLIP_Y or gid & self.FLIP_DIAGONAL:
							image_gid = gid & ~(self.FLIP_X | self.FLIP_Y | self.FLIP_DIAGONAL)
							offset_x, offset_y, img = self.indexed_tiles[image_gid]
							tex = img.get_texture()
							orig_anchor_x = tex.anchor_x
							orig_anchor_y = tex.anchor_y
							tex.anchor_x = tex.width / 2
							tex.anchor_y = tex.height / 2
							if gid & self.FLIP_DIAGONAL:
								if gid & self.FLIP_X:
									tex2 = tex.get_transform(rotate=90)
								elif gid & self.FLIP_Y:
									tex2 = tex.get_transform(rotate=270)
							else:
								tex2 = tex.get_transform(flip_x=bool(gid & self.FLIP_X), flip_y=bool(gid & self.FLIP_Y))
							tex2.anchor_x = tex.anchor_x = orig_anchor_x
							tex2.anchor_y = tex.anchor_y = orig_anchor_y
							self.indexed_tiles[gid] = (offset_x, offset_y, tex2)

			#json.dump(self.indexed_tiles, sys.stdout, cls=JSONDebugEncoder, indent=2, sort_keys=True)

		def _load_image(self, filename, colorkey=None):
			img = self._img_cache.get(filename, None)
			if img is None:
				print("~ Image: '{}'".format(filename))
				try:
					img = Image.open(filename)
				except FileNotFoundError:
					img = None
				self._img_cache[filename] = img
			return img

		def _load_image_file_like(self, file_like_obj, colorkey=None):
			return self._load_image(file_like_obj)

		def _load_image_part(self, filename, xpos, ypos, width, height, colorkey=None):
			#print("~ Image Part: '{}' ({}, {}, {}, {}, {})".format(filename, xpos, ypos, width, height, colorkey))
			source_img = self._load_image(filename, colorkey)
			crop_rectangle = (xpos, ypos, xpos + width, ypos + height)
			return self._load_image(filename).crop(crop_rectangle)

		def _load_image_parts(self, filename, margin, spacing, tile_width, tile_height, colorkey=None):
			source_img = self._load_image(filename, colorkey)
			if not source_img is None:
				width, height = source_img.size
			else:
				width = 0
				height = 0
			tile_width_spacing = tile_width + spacing
			width = (width // tile_width_spacing) * tile_width_spacing
			tile_height_spacing = tile_height + spacing
			height = (height // tile_height_spacing) * tile_height_spacing
			images = []
			for y_pos in range(margin, height, tile_height_spacing):
				for x_pos in range(margin, width, tile_width_spacing):
					img_part = self._load_image_part(filename, x_pos, y_pos, tile_width, tile_height, colorkey)
					images.append(img_part)
			return images

		def get_indexed_tiles(self):
			return self.indexed_tiles

		def save_tile_images(self, directory):
			os.makedirs(directory, exist_ok=True)
			for id, (offsetx, neg_offsety, img) in self.indexed_tiles.items():
				print("~ Tile '{}' ({}, {}): {}".format(id, offsetx, neg_offsety, img))
				sha1sum = hashlib.sha1()
				output = io.BytesIO()
				img.save(output, format='PNG')
				sha1sum.update(output.getvalue())
				sha1sum = sha1sum.hexdigest()
				print("~ SHA1: {}".format(sha1sum))
				filename = os.path.join(directory, "tile_{}.png".format(sha1sum))
				with open(filename, 'wb') as f:
					f.write(output.getvalue())

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
	arg_parser.add_argument(dest="file", type=extant_file, help="TMX File", metavar="FILE")
	args = arg_parser.parse_args()

	map_filename = str(args.file)
	print("~ Map: '{}'".format(map_filename))
	map = TileMapParser().parse_decode(map_filename)
	resources = MapResourceLoader()
	resources.load(map)
	print("~ Orientation: '{}'".format(map.orientation))
	all_sprite_layers = []

	map_tilewidth = map.tilewidth
	map_tileheight = map.tileheight
	map_num_tiles_x = map.width
	map_num_tiles_y = map.height

	print(f"\nTiled Layers ({len(resources.world_map.layers)}):\n")

	for idx, layer in enumerate(resources.world_map.layers):
			layer_name = layer.name
			layer_position_x = layer.x
			layer_position_y = layer.y
			layer_is_object_group = layer.is_object_group
			layer_is_visible = layer.visible

			layer_level = int(layer.properties.get('Level', 0))

			if layer.is_object_group:
				print("Objects Layer '{}' ({}): {}".format(layer.name, 'visible' if layer.visible else 'not visible', layer.properties))
				#json.dump(layer, sys.stdout, cls=JSONDebugEncoder, indent=2, sort_keys=True)
				for obj in layer.objects:
					obj_id = obj.properties.get('Id', None)
					obj_type = obj.properties.get('Type', None)
					if obj_type == 'avatar':
						print("Avatar '{}' ('{}') at x={}, y={}".format(obj_id, obj_type, obj.x, obj.y))
					else:
						print("Object '{}' ('{}') at x={}, y={}".format(obj_id, obj_type, obj.x, obj.y))
			else:
				layer_is_metadata = layer.properties.get('Metadata', None)
				layer_is_wall = layer.properties.get('Avatar', None)
				layer_is_floor = not layer_is_metadata and not layer_is_wall

				if layer_is_metadata:
					layer_type = 'metadata'
				elif layer_is_floor:
					layer_type = 'floor'
				elif layer_is_wall:
					layer_type = 'wall'
				else:
					layer_type = 'unknown'

				print("Tiled Layer '{}' ({}): {} ({}x{})".format(
					layer_name,
					layer_type,
					layer.properties,
					layer.width,
					layer.height
				))
				layer_content = layer.decoded_content # array.array(height*width)

				layer_sprites = []

				bottom_margin = 0

				content2D = [None] * map_num_tiles_y
				for ypos in range(0, map_num_tiles_y):
					content2D[ypos] = [None] * map_num_tiles_x
					for xpos in range(0, map_num_tiles_x):
						#tile = map.tiles.get(k, None)
						content2D[ypos][xpos] = None

				#sprite_layer = tiledtmxloader.helperspygame.get_layer_at_index(idx, resources)
				#all_sprite_layers.append(sprite_layer)

		#resources.save_tile_images('tmp')

	print(f"\nTile Sets ({len(map.tile_sets)}):\n")

	for tileset in map.tile_sets:
		print(f"Tile Set '{tileset.name}': {len(tileset.tiles)} tiles, starting at firstgid = {tileset.firstgid}")

	print(f"\nTiles ({len(map.tiles)}):\n")

	for gid, cell in map.tiles.items():
		print(f"Tile {gid} (from Tile Set '{cell.tile_set.name}') -> {cell.properties}")

	print(f"\nLayers ({len(map.layers)}):\n")

	for layer in map.layers:
		print(f"Layer '{layer.name}' ({layer.width}x{layer.height})")
		contents = layer.decoded_content
		histogram = {}
		for gid in contents:
			try:
				histogram[gid] += 1
			except KeyError:
				histogram[gid] = 1
		print(f"  - GID Histogram: {', '.join([f'{c} times tile {i}' for i,c in histogram.items()])}")
		print(f"  - Properties: {layer.properties}")
