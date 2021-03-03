cimport SDL2
cimport tmxlite

from libc.stdint cimport uint32_t, uint16_t, uint8_t
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, make_shared, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from cpython.ref cimport PyObject
from cython.operator cimport dereference as deref
from enum import IntEnum

import sys

print("Hello World")

cdef class _SDL2TestApplication:
    cdef SDL2.SDL_Window* win
    cdef SDL2.SDL_Renderer* ren
    cdef SDL2.SDL_Surface* bmp
    cdef SDL2.SDL_Texture* tex

    def __cinit__(self):
        if (SDL2.SDL_Init(SDL2.SDL_INIT_EVERYTHING) != 0):
            raise SystemExit(f"SDL_Init Error: {SDL2.SDL_GetError()}")

        self.win = SDL2.SDL_CreateWindow("Hello World!", 100, 100, 620, 387, SDL2.SDL_WINDOW_SHOWN)
        if not self.win:
            raise SystemExit(f"SDL_CreateWindow Error: {SDL2.SDL_GetError()}")

        self.ren = SDL2.SDL_CreateRenderer(self.win, -1, SDL2.SDL_RENDERER_ACCELERATED | SDL2.SDL_RENDERER_PRESENTVSYNC)
        if not self.ren:
            errmsg = f"SDL_CreateRenderer Error: {SDL2.SDL_GetError()}"
            if self.win:
                SDL2.SDL_DestroyWindow(self.win)
            SDL2.SDL_Quit()
            raise SystemExit(errmsg)

        self.bmp = SDL2.SDL_LoadBMP("img/grumpy-cat.bmp")
        if not self.bmp:
            errmsg = f"SDL_LoadBMP Error: {SDL2.SDL_GetError()}"
            if self.ren:
                SDL2.SDL_DestroyRenderer(self.ren)
            if self.win:
                SDL2.SDL_DestroyWindow(self.win)
            SDL2.SDL_Quit()
            raise SystemExit(errmsg)

        self.tex = SDL2.SDL_CreateTextureFromSurface(self.ren, self.bmp)
        if not self.tex:
            errmsg = f"SDL_CreateTextureFromSurface Error: {SDL2.SDL_GetError()}"
            if self.bmp:
                SDL2.SDL_FreeSurface(self.bmp)
            if self.ren:
                SDL2.SDL_DestroyRenderer(self.ren)
            if self.win:
                SDL2.SDL_DestroyWindow(self.win)
            SDL2.SDL_Quit()
            raise SystemExit(errmsg)

        SDL2.SDL_FreeSurface(self.bmp)

        for i in range(20):
            SDL2.SDL_RenderClear(self.ren)
            SDL2.SDL_RenderCopy(self.ren, self.tex, NULL, NULL)
            SDL2.SDL_RenderPresent(self.ren)
            SDL2.SDL_Delay(100)

        SDL2.SDL_DestroyTexture(self.tex)
        SDL2.SDL_DestroyRenderer(self.ren)
        SDL2.SDL_DestroyWindow(self.win)
        SDL2.SDL_Quit()

class SDL2TestApplication(_SDL2TestApplication):
    pass

class TmxLayerType(IntEnum):
    Tile   = <int>tmxlite.Layer_Type_Tile
    Object = <int>tmxlite.Layer_Type_Object
    Image  = <int>tmxlite.Layer_Type_Image
    Group  = <int>tmxlite.Layer_Type_Group

cdef class _TmxLayer:
    cdef tmxlite.Layer * layer
    type_names = {
        <int>tmxlite.Layer_Type_Tile:   "Tile",
        <int>tmxlite.Layer_Type_Object: "Object",
        <int>tmxlite.Layer_Type_Image:  "Image",
        <int>tmxlite.Layer_Type_Group:  "Group",
    }
    def __cinit__(self):
        self.layer = NULL
    def getName(self):
        return deref(self.layer).getName().decode('utf8')
    def getType(self):
        return TmxLayerType(<int>deref(self.layer).getType())
    def getTypeName(self):
        return self.type_names.get(self.getType(), "Unknown")

cdef class _TmxLayerGroup(_TmxLayer):
    def __cinit__(self):
        pass
    def getLayers(self):
        layers = _TmxLayers()
        layers.layers = self.layer.getLayerAs[tmxlite.LayerGroup]().getLayers()
        return layers

cdef class _TmxObject:
    cdef tmxlite.Object * object
    shape_names = {
        <int>tmxlite.Object_Shape_Rectangle: "Rectangle",
        <int>tmxlite.Object_Shape_Ellipse:   "Ellipse",
        <int>tmxlite.Object_Shape_Point:     "Point",
        <int>tmxlite.Object_Shape_Polygon:   "Polygon",
        <int>tmxlite.Object_Shape_Polyline:  "Polyline",
        <int>tmxlite.Object_Shape_Text:      "Text",
    }
    def __cinit__(self):
        self.object = NULL
    def getUID(self):
        return <int>deref(self.object).getUID()
    def getName(self):
        return deref(self.object).getName().decode('utf8')
    def getType(self):
        return deref(self.object).getName().decode('utf8')
    def getShape(self):
        return TmxObjectShape(<int>deref(self.object).getShape())
    def getShapeName(self):
        return self.shape_names.get(self.getShape(), "Unknown")

cdef class _TmxObjectGroup(_TmxLayer):
    def __cinit__(self):
        pass
    def getObjects(self):
        objects = _TmxObjects()
        objects.objects = self.layer.getLayerAs[tmxlite.ObjectGroup]().getObjects()
        return objects

cdef class _TmxLayers:
    cdef vector[tmxlite.Layer.Ptr] layers
    def __cinit__(self):
        pass
    def size(self):
        return self.layers.size()
    def __len__(self):
        return self.layers.size()
    def getLayer(self, size_t key):
        layer = _TmxLayer()
        layer.layer = self.layers.at(key).get()
        return layer
    def getLayerGroup(self, size_t key):
        layer = _TmxLayerGroup()
        layer.layer = self.layers.at(key).get()
        return layer
    def getObjectGroup(self, size_t key):
        layer = _TmxObjectGroup()
        layer.layer = self.layers.at(key).get()
        return layer
    def __getitem__(self, size_t key):
        type = <int>self.layers.at(key).get().getType()
        return {
            <int>tmxlite.Layer_Type_Tile:   self.getLayer,
            <int>tmxlite.Layer_Type_Object: self.getObjectGroup,
            <int>tmxlite.Layer_Type_Image:  self.getLayer,
            <int>tmxlite.Layer_Type_Group:  self.getLayerGroup,
        }.get(type, self.getLayer)(key)

cdef class _TmxObjects:
    cdef vector[tmxlite.Object] objects
    def __cinit__(self):
        pass
    def size(self):
        return self.objects.size()
    def __len__(self):
        return self.objects.size()
    def __getitem__(self, size_t key):
        object = _TmxObject()
        object.object = &self.objects.at(key)
        return object

cdef class _TmxProperty:
    cdef const tmxlite.Property * property
    type_names = {
        <int>tmxlite.Property_Type_Boolean: "Boolean",
        <int>tmxlite.Property_Type_Float:   "Float",
        <int>tmxlite.Property_Type_Int:     "Int",
        <int>tmxlite.Property_Type_String:  "String",
        <int>tmxlite.Property_Type_Colour:  "Colour",
        <int>tmxlite.Property_Type_File:    "File",
        <int>tmxlite.Property_Type_Object:  "Object",
        <int>tmxlite.Property_Type_Undef:   "Undef",
    }
    def __cinit__(self):
        self.property = NULL
    def getName(self):
        return deref(self.property).getName().decode('utf8')
    def getType(self):
        return <int>deref(self.property).getType()
    def getTypeName(self):
        return self.type_names.get(self.getType(), "Unknown")

cdef class _TmxProperties:
    cdef const vector[tmxlite.Property] * properties
    def __cinit__(self):
        self.properties = NULL
    def size(self):
        return deref(self.properties).size()
    def __len__(self):
        return deref(self.properties).size()
    def __getitem__(self, size_t key):
        property = _TmxProperty()
        property.property = &deref(self.properties).at(key)
        return property

class TmxObjectShape(IntEnum):
    Rectangle = <int>tmxlite.Object_Shape_Rectangle
    Ellipse   = <int>tmxlite.Object_Shape_Ellipse
    Point     = <int>tmxlite.Object_Shape_Point
    Polygon   = <int>tmxlite.Object_Shape_Polygon
    Polyline  = <int>tmxlite.Object_Shape_Polyline
    Text      = <int>tmxlite.Object_Shape_Text

cdef class _TmxMap:
    cdef tmxlite.Map* map
    def __cinit__(self):
        self.map = NULL
    def load(self, path):
        self.map = new tmxlite.Map()
        if not self.map.load(path.encode('utf8')):
            raise SystemExit("Error loading map")
    def getVersion(self):
        version = self.map.getVersion()
        return (version.upper, version.lower)
    def getLayers(self):
        layers = _TmxLayers()
        layers.layers = self.map.getLayers()
        return layers
    def getProperties(self):
        properties = _TmxProperties()
        properties.properties = &self.map.getProperties()
        return properties
    def isInfinite(self):
        return self.map.isInfinite()

cdef class _TiledTestApplication:
    def __cinit__(self):
        self.map = _TmxMap()
        self.map.load("maps/platform.tmx")
        print(f"Map version: {self.map.getVersion()}")
        if self.map.isInfinite():
            print("Map is infinite.\n")
        mapProperties = self.map.getProperties()
        print(f"Map has {mapProperties.size()} properties")
        for prop in mapProperties:
            print(f"Found property: \"{prop.getName()}\", Type: {prop.getTypeName()}")
        layers = self.map.getLayers()
        print(f"Map has {layers.size()} layers")
        for layer in layers:
            print(f"Found Layer: \"{layer.getName()}\", Type: {layer.getTypeName()}")
            if layer.getType() == TmxLayerType.Group:
                sublayers = layer.getLayers()
                print(f"LayerGroup has {sublayers.size()} sublayers")
                for sublayer in sublayers:
                    print(f"Found Sublayer: \"{sublayer.getName()}\", Type: {sublayer.getTypeName())}")
            elif layer.getType() == TmxLayerType.Object:
                objects = layer.getObjects()
                print(f"Found has {objects.size()} objects in layer")
                for object in objects:
                    print(f"Object {object.getUID()}, Name: \"{object.getName()}\"")
            elif layer.getType() == TmxLayerType.Tile:
                print(f"OOK3")

class TiledTestApplication(_TiledTestApplication):
    pass
