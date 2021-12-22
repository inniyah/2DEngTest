#!/usr/bin/env python3

import argparse
import logging
import os
import json
import sys

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))
sys.path.append(os.path.abspath(os.path.join(MY_PATH, 'python')))

from funcs import printAsJson

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))

logging.basicConfig(level=logging.INFO)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import gonlet
import tmxlite

from game import Game

def run_game():
    g = Game()
    g.run()

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
        print(f"Tileset \"{tileset.getName()}\" (\"{tileset.getImagePath()}\"): Tiles= {tileset.getFirstGID()} - {tileset.getLastGID()}, Tile Size= {twidth} x {theight}, Image size= {iwidth} x {iheight}")



# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--quiet", help="set logging to ERROR",
                        action="store_const", dest="loglevel",
                        const=logging.ERROR, default=logging.INFO)
    parser.add_argument("-d", "--debug", help="set logging to DEBUG",
                        action="store_const", dest="loglevel",
                        const=logging.DEBUG, default=logging.INFO)
    parser.add_argument("-t", "--test", dest="test", required=False, help="Test to run", default=None)
    args = parser.parse_args()

    if args.test is None:
        tests = [ 'loadtmx' ]
    else:
        tests = [ args.test ]

    for test in tests:
        logging.info(f"Running test: {test}")
        if test == 'game':
            run_game()
        if test == 'printtmx':
            printTmxMapInfo("assets/map/example.tmx")
        if test == 'loadtmx':
            loadTmxMap("assets/map/example.tmx")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if __name__ == "__main__":
    main()
