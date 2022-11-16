#!/usr/bin/env python3

import argparse
#~ import faulthandler
import logging
import os
import sys

from datetime import datetime
from pprint import pprint

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))
sys.path.append(os.path.abspath(os.path.join(MY_PATH, 'python')))

logging.basicConfig(level=logging.INFO)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import gonlet
import tmxlite
import ctmx
import raylib

from lights import Lights
from game import Game
from shadertest import runShader
from tmxgame import TmxGame

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def printTmxMapInfo(filename : str):
    map = tmxlite.TmxMap()
    map.load(filename)
    print(f"Map version: {map.getVersion()}")
    if map.isInfinite():
        print("Map is infinite.\n")
    mapProperties = map.getProperties()
    print(f"Map has {mapProperties.size()} properties")
    for prop in mapProperties:
        print(f"Found property: \"{prop.getName()}\", Type: {prop.getTypeName()}")
    layers = map.getLayers()
    print(f"Map has {layers.size()} layers")
    for layer in layers:
        print(f"Found Layer: \"{layer.getName()}\", Type: {layer.getTypeName()}")

        if layer.getType() == tmxlite.TmxLayerType.Group:
            sublayers = layer.getLayers()
            print(f"LayerGroup has {sublayers.size()} sublayers")
            for sublayer in sublayers:
                print(f"Found Sublayer: \"{sublayer.getName()}\", Type: {sublayer.getTypeName()}")
                if sublayer.getType() == tmxlite.TmxLayerType.Tile:
                    tiles = sublayer.getTiles()
                    if tiles:
                        print(f"TileLayer has {tiles.size()} tiles")
                    chunks = sublayer.getChunks()
                    if chunks:
                        print(f"TileLayer has {chunks.size()} chunks")
                    tilesProperties = sublayer.getProperties()
                    if tilesProperties:
                        print(f"TileLayer has {tilesProperties.size()} properties")
                        for prop in tilesProperties:
                            print(f"Found property: \"{prop.getName()}\", Type: {prop.getTypeName()}")

        elif layer.getType() == tmxlite.TmxLayerType.Object:
            objects = layer.getObjects()
            print(f"Found has {objects.size()} objects in layer")
            for object in objects:
                print(f"Object {object.getUID()}, Name: \"{object.getName()}\"")
                objProperties = object.getProperties()
                if objProperties:
                    print(f"Object has {objProperties.size()} properties")
                    for prop in objProperties:
                        print(f"Found property: \"{prop.getName()}\", Type: {prop.getTypeName()}")

        elif layer.getType() == tmxlite.TmxLayerType.Image:
            print(f"ImagePath: \"{layer.getImagePath()}\"")

        elif layer.getType() == tmxlite.TmxLayerType.Tile:
            tiles = layer.getTiles()
            if tiles:
                print(f"TileLayer has {tiles.size()} tiles")
            chunks = layer.getChunks()
            if chunks:
                print(f"TileLayer has {chunks.size()} chunks")
            tilesProperties = layer.getProperties()
            if tilesProperties:
                print(f"TileLayer has {tilesProperties.size()} properties")
                for prop in tilesProperties:
                    print(f"Found property: \"{prop.getName()}\", Type: {prop.getTypeName()}")

    tilesets = map.getTilesets()
    print(f"Map has {tilesets.size()} tilesets")
    for tileset in tilesets:
        print(f"Found Tileset \"{tileset.getName()}\", {tileset.getFirstGID()} - {tileset.getLastGID()}")

def loadTmxMap(filename : str):
    map = tmxlite.TmxMap(filename)
    map_rows, map_cols = map.getTileCount()
    print(f"Map dimensions: {map_rows} x {map_cols}")
    tile_width, tile_height = map.getTileSize()
    print(f"Tile size: {tile_width} x {tile_height}")
    tilesets = map.getTilesets()
    print(f"Map has {tilesets.size()} tilesets")
    for tileset in tilesets:
        twidth, theight = tileset.getTileSize()
        iwidth, iheight = tileset.getImageSize()
        print(f"- Tileset \"{tileset.getName()}\" ({tileset.getFirstGID()}-{tileset.getLastGID()}): Image=\"{tileset.getImagePath()}\" ({iwidth}x{iheight}), Tile Size={twidth}x{theight}")
        for tile in tileset.getTiles():
            tidx = tile.getTerrainIndices()
            #~ print(f"{tile.getID()} {tile.getImagePath()} {tile.getImagePosition()} {tile.getImageSize()} {[i for i in tidx]}")

    layers = map.getLayers()
    print(f"Map has {layers.size()} layers")
    for layer in layers:
        if layer.getType() != tmxlite.TmxLayerType.Tile:
            continue
        tiles = layer.getTiles()
        print(f"- Layer \"{layer.getName()}\" ({layer.getTypeName()}) has {tiles.size()} tiles")

        for y in range(map_rows):
            for x in range(map_cols):
                tile_index = x + (y * map_cols)
                cur_gid = tiles[tile_index].getID();
                if not cur_gid:
                    continue
                for tileset in tilesets:
                    if tileset.getFirstGID() <= cur_gid and tileset.getLastGID() >= cur_gid:
                        print(f"  [{x}, {y}]: {cur_gid} -> Tileset \"{tileset.getName()}\" ({tileset.getFirstGID()}-{tileset.getLastGID()})")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def runRaylib():
    test = raylib.test()
    test.run()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Dump logging output with colors

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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

LOG_FILE_FORMAT = "[%(levelname)s] [%(pathname)s:%(lineno)d] [%(asctime)s] [%(name)s]: '%(message)s'"
LOG_CONSOLE_FORMAT = "[%(pathname)s:%(lineno)d] [%(asctime)s]: '%(message)s'"
LOG_GUI_FORMAT = "[%(levelname)s] %(message)s"

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--quiet", help="set logging to ERROR",
                        action="store_const", dest="loglevel",
                        const=logging.ERROR, default=logging.INFO)
    parser.add_argument("-d", "--debug", help="set logging to DEBUG",
                        action="store_const", dest="loglevel",
                        const=logging.DEBUG, default=logging.INFO)
    parser.add_argument("-t", "--test", dest="test", required=False, help="Test to run", default=None)
    parser.add_argument('--log', action=argparse.BooleanOptionalAction)
    args = parser.parse_args()

    logger = logging.getLogger()
    logger.setLevel(logging.DEBUG)
    logger.handlers = []

    log_console_handler = ColorStderr(LOG_CONSOLE_FORMAT)
    log_console_handler.setLevel(args.loglevel)
    logger.addHandler(log_console_handler)

    if args.log:
        now = datetime.now()
        logs_dir = os.path.abspath(os.path.join(MY_PATH, "logs", f"{now.strftime('%Y%m%d')}"))
        os.makedirs(logs_dir, exist_ok=True)
        log_filename = f"{now.strftime('%Y%m%d')}_{now.strftime('%H%M%S')}.txt"
        log_file_handler = logging.FileHandler(os.path.join(logs_dir, log_filename))
        log_formatter = logging.Formatter(LOG_FILE_FORMAT)
        log_file_handler.setFormatter(log_formatter)
        log_file_handler.setLevel(logging.DEBUG)
        logger.addHandler(log_file_handler)
        logging.info(f"Storing log into '{logs_dir}/{log_filename}'")

    if args.test is None:
        tests = [ 'light' ]
    else:
        tests = [ args.test ]

    for test in tests:
        logging.info(f"Running test: {test}")
        if test == 'game':
            g = Game()
            g.run()
            del g
        if test=='light':
            g=Lights()
            g.run()
            del g
        
        if test == 'printtmx':
            printTmxMapInfo("assets/map/example.tmx")
        if test == 'loadtmx':
            loadTmxMap("assets/map/example.tmx")
        if test == 'hub':
            gonlet.set(22)
            print("singleton: ", [ gonlet.get(), tmxlite.get() ])
        if test=='shadertest':
            a=runShader()
            a.run()
        if test == 'tmxgame':
            g = TmxGame()
            g.run()
            del g
        if test == 'raylib':
            runRaylib()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if __name__ == "__main__":
    #~ faulthandler.enable()
    main()
