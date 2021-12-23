cimport tmxlite.tmxlite as tmxlite

cdef class _TmxConstColour:
    cdef const tmxlite.Colour * colour
    def __cinit__(self):
        self.colour = NULL
    @staticmethod
    cdef create(const tmxlite.Colour * colour):
        cdef _TmxConstColour self = _TmxConstColour()
        self.colour = colour
        return self
    def red(self):
        return self.colour.r
    def green(self):
        return self.colour.g
    def blue(self):
        return self.colour.b
    def alpha(self):
        return self.colour.a

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
    def getOpacity(self):
        return deref(self.layer).getOpacity()
    def getVisible(self):
        return deref(self.layer).getVisible()
    def getOffset(self):
        cdef const tmxlite.Vector2i * offset = &deref(self.layer).getOffset()
        return offset.x, offset.y
    def getSize(self):
        cdef const tmxlite.Vector2u * size = &deref(self.layer).getSize()
        return size.x, size.y
    def getProperties(self):
        return _TmxProperties.create(&self.layer.getProperties())

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
    def getProperties(self):
        properties = _TmxProperties()
        properties.properties = &self.object.getProperties()
        return properties

cdef class _TmxObjectGroup(_TmxLayer):
    def __cinit__(self):
        pass
    def getObjects(self):
        objects = _TmxObjects()
        objects.objects = self.layer.getLayerAs[tmxlite.ObjectGroup]().getObjects()
        return objects

cdef class _TmxImageLayer(_TmxLayer):
    def __cinit__(self):
        pass
    def getImagePath(self):
        return self.layer.getLayerAs[tmxlite.ImageLayer]().getImagePath().decode('utf8')

cdef class _TmxTileLayer_ConstTile:
    cdef const tmxlite.TileLayer_Tile * tile
    def __cinit__(self):
        self.tile = NULL
    @staticmethod
    cdef create(const tmxlite.TileLayer_Tile * tile):
        cdef _TmxTileLayer_ConstTile self = _TmxTileLayer_ConstTile()
        self.tile = tile
        return self
    def getID(self):
        return deref(self.tile).ID
    def getFlipFlags(self):
        return deref(self.tile).flipFlags

cdef class _TmxTileLayer_ConstTiles:
    cdef const vector[tmxlite.TileLayer_Tile] * tiles
    def __cinit__(self):
        self.tiles = NULL
    @staticmethod
    cdef create(const vector[tmxlite.TileLayer_Tile] * tiles):
        cdef _TmxTileLayer_ConstTiles self = _TmxTileLayer_ConstTiles()
        self.tiles = tiles
        return self
    def size(self):
        return deref(self.tiles).size()
    def __len__(self):
        return deref(self.tiles).size()
    def __getitem__(self, size_t key):
        tile = _TmxTileLayer_ConstTile()
        tile.tile = &deref(self.tiles).at(key)
        return tile

cdef class _TmxTileLayer_ConstChunk:
    cdef const tmxlite.TileLayer_Chunk * chnk
    def __cinit__(self):
        self.chnk = NULL
    @staticmethod
    cdef create(const tmxlite.TileLayer_Chunk * chnk):
        cdef _TmxTileLayer_ConstChunk self = _TmxTileLayer_ConstChunk()
        self.chnk = chnk
        return self
    def getPosition(self):
        cdef const tmxlite.Vector2i * pos = &deref(self.chnk).position
        return pos.x, pos.y
    def getSize(self):
        cdef const tmxlite.Vector2i * size = &deref(self.chnk).size
        return size.x, size.y
    def getTiles(self, size_t key):
        return _TmxTileLayer_ConstTiles.create(&deref(self.chnk).tiles)

cdef class _TmxTileLayer_ConstChunks:
    cdef const vector[tmxlite.TileLayer_Chunk] * chunks
    def __cinit__(self):
        self.chunks = NULL
    @staticmethod
    cdef create(const vector[tmxlite.TileLayer_Chunk] * chunks):
        cdef _TmxTileLayer_ConstChunks self = _TmxTileLayer_ConstChunks()
        self.chunks = chunks
        return self
    def size(self):
        return deref(self.chunks).size()
    def __len__(self):
        return deref(self.chunks).size()
    def __getitem__(self, size_t key):
        chnk = _TmxTileLayer_ConstChunk()
        chnk.chnk = &deref(self.chunks).at(key)
        return chnk
    def getChunkTiles(self, size_t key):
        return _TmxTileLayer_ConstTiles.create(&self.chunks.at(key).tiles)

cdef class _TmxTileLayer(_TmxLayer):
    def __cinit__(self):
        pass
    def getTiles(self):
        return _TmxTileLayer_ConstTiles.create(&self.layer.getLayerAs[tmxlite.TileLayer]().getTiles())
    def getChunks(self):
        chunks = _TmxTileLayer_ConstChunks()
        chunks.chunks = &self.layer.getLayerAs[tmxlite.TileLayer]().getChunks()
        return chunks

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
    def getImageLayer(self, size_t key):
        layer = _TmxImageLayer()
        layer.layer = self.layers.at(key).get()
        return layer
    def getTileLayer(self, size_t key):
        layer = _TmxTileLayer()
        layer.layer = self.layers.at(key).get()
        return layer
    def __getitem__(self, size_t key):
        type = <int>self.layers.at(key).get().getType()
        return {
            <int>tmxlite.Layer_Type_Tile:   self.getTileLayer,
            <int>tmxlite.Layer_Type_Object: self.getObjectGroup,
            <int>tmxlite.Layer_Type_Image:  self.getImageLayer,
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
    @staticmethod
    cdef create(const vector[tmxlite.Property] * properties):
        cdef _TmxProperties self = _TmxProperties()
        self.properties = properties
        return self
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

cdef class _TmxTileset_ConstTile:
    cdef const tmxlite.Tileset_Tile * tile
    def __cinit__(self):
        self.tile = NULL
    @staticmethod
    cdef create(const tmxlite.Tileset_Tile * tile):
        cdef _TmxTileset_ConstTile self = _TmxTileset_ConstTile()
        self.tile = tile
        return self
    def getID(self):
        return deref(self.tile).ID
    def getTerrainIndices(self):
        cdef const int32_t * data = &deref(self.tile).terrainIndices[0]
        cdef const int32_t[::1] mview = <int32_t[:4]>data
        return mview.copy()
    def getProbability(self):
        return deref(self.tile).probability
    def getProperties(self):
        return _TmxProperties.create(&deref(self.tile).properties)
    #~ ObjectGroup objectGroup;
    def getImagePath(self):
        return deref(self.tile).imagePath.decode('utf8')
    def getImageSize(self):
        cdef const tmxlite.Vector2u * imagesize = &deref(self.tile).imageSize
        return imagesize.x, imagesize.y
    def getImagePosition(self):
        cdef const tmxlite.Vector2u * imagepos = &deref(self.tile).imagePosition
        return imagepos.x, imagepos.y
    def getType(self):
        return deref(self.tile).type.decode('utf8')

cdef class _TmxTileset_ConstTiles:
    cdef const vector[tmxlite.Tileset_Tile] * tiles
    def __cinit__(self):
        self.tiles = NULL
    @staticmethod
    cdef create(const vector[tmxlite.Tileset_Tile] * tiles):
        cdef _TmxTileset_ConstTiles self = _TmxTileset_ConstTiles()
        self.tiles = tiles
        return self
    def size(self):
        return deref(self.tiles).size()
    def __len__(self):
        return deref(self.tiles).size()
    def __getitem__(self, size_t key):
        tile = _TmxTileset_ConstTile()
        tile.tile = &deref(self.tiles).at(key)
        return tile

cdef class _TmxTileset_ConstTerrain:
    cdef const tmxlite.Tileset_Terrain * terrain
    def __cinit__(self):
        self.terrain = NULL
    @staticmethod
    cdef create(const tmxlite.Tileset_Terrain * terrain):
        cdef _TmxTileset_ConstTerrain self = _TmxTileset_ConstTerrain()
        self.terrain = terrain
        return self
    def getName(self):
        return deref(self.terrain).name.decode('utf8')
    def getTileID(self):
        return deref(self.terrain).tileID
    def getProperties(self):
        return _TmxProperties.create(&deref(self.terrain).properties)

cdef class _TmxTileset_ConstTerrains:
    cdef const vector[tmxlite.Tileset_Terrain] * terrains
    def __cinit__(self):
        self.terrains = NULL
    @staticmethod
    cdef create(const vector[tmxlite.Tileset_Terrain] * terrains):
        cdef _TmxTileset_ConstTerrains self = _TmxTileset_ConstTerrains()
        self.terrains = terrains
        return self
    def size(self):
        return deref(self.terrains).size()
    def __len__(self):
        return deref(self.terrains).size()
    def __getitem__(self, size_t key):
        terrain = _TmxTileset_ConstTerrain()
        terrain.terrain = &deref(self.terrains).at(key)
        return terrain

cdef class _TmxTileset:
    cdef const tmxlite.Tileset * tileset
    def __cinit__(self):
        self.tileset = NULL
    @staticmethod
    cdef create(const tmxlite.Tileset * tileset):
        cdef _TmxTileset self = _TmxTileset()
        self.tileset = tileset
        return self
    def getFirstGID(self):
        return <int>deref(self.tileset).getFirstGID()
    def getLastGID(self):
        return <int>deref(self.tileset).getLastGID()
    def getName(self):
        return deref(self.tileset).getName().decode('utf8')
    def getTileSize(self):
        cdef const tmxlite.Vector2u * tilesize = &deref(self.tileset).getTileSize()
        return tilesize.x, tilesize.y
    def getSpacing(self):
        return deref(self.tileset).getName().getSpacing()
    def getMargin(self):
        return deref(self.tileset).getName().getMargin()
    def getTileCount(self):
        return deref(self.tileset).getName().getTileCount()
    def getColumnCount(self):
        return deref(self.tileset).getName().getColumnCount()
    #~ Tileset_ObjectAlignment getObjectAlignment() const
    def getTileOffset(self):
        cdef const tmxlite.Vector2u * tileoffset = &deref(self.tileset).getTileOffset()
        return tileoffset.x, tileoffset.y
    def getProperties(self):
        return _TmxProperties.create(&deref(self.tileset).getProperties())
    def getImagePath(self):
        return deref(self.tileset).getImagePath().decode('utf8')
    def getImageSize(self):
        cdef const tmxlite.Vector2u * imagesize = &deref(self.tileset).getImageSize()
        return imagesize.x, imagesize.y
    def getTransparencyColour(self):
        return _TmxConstColour.create(&deref(self.tileset).getTransparencyColour())
    def hasTransparency(self):
        return deref(self.tileset).hasTransparency()
    def getTerrainTypes(self):
        return _TmxTileset_ConstTerrains.create(&deref(self.tileset).getTerrainTypes())
    def getTiles(self):
        return _TmxTileset_ConstTiles.create(&deref(self.tileset).getTiles())
    def hasTile(self, id : uint32_t):
        return deref(self.tileset).hasTile(id)
    def getTile(self, uint32_t id : uint32_t):
        return _TmxTileset_ConstTile.create(deref(self.tileset).getTile(id))

cdef class _TmxTilesets:
    cdef const vector[tmxlite.Tileset] * tilesets
    def __cinit__(self):
        self.tilesets = NULL
    def size(self):
        return deref(self.tilesets).size()
    def __len__(self):
        return deref(self.tilesets).size()
    def __getitem__(self, size_t key):
        return _TmxTileset.create(&deref(self.tilesets).at(key))

cdef class _TmxMap:
    cdef tmxlite.Map* map
    def __cinit__(self):
        self.map = NULL
    def __dealloc___(self):
        if self.map != NULL:
            del self.map
    def reset(self):
        if self.map != NULL:
            del self.map
        self.map = NULL
    def load(self, filename):
        self.reset()
        self.map = new tmxlite.Map()
        if not self.map.load(filename.encode('utf8')):
            raise SystemExit("Error loading map")
    def getVersion(self):
        version = self.map.getVersion()
        return (version.upper, version.lower)
    def getLayers(self):
        layers = _TmxLayers()
        layers.layers = self.map.getLayers()
        return layers
    def getTilesets(self):
        tilesets = _TmxTilesets()
        tilesets.tilesets = &self.map.getTilesets()
        return tilesets
    def getProperties(self):
        properties = _TmxProperties()
        properties.properties = &self.map.getProperties()
        return properties
    def isInfinite(self):
        return self.map.isInfinite()
    def getTileCount(self):
        cdef const tmxlite.Vector2u * map_dimensions = &self.map.getTileCount()
        return map_dimensions.x, map_dimensions.y
    def getTileSize(self):
        cdef const tmxlite.Vector2u * tilesize = &self.map.getTileSize()
        return tilesize.x, tilesize.y


class TmxMap(_TmxMap):
    def __init__(self, filename : str = None):
        if not filename is None:
            self.load(filename)
