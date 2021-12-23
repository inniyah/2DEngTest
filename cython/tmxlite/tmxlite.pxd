# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from libc.stdint cimport int32_t, uint32_t, int16_t, uint16_t, int8_t, uint8_t
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp.unordered_map cimport unordered_map
from libcpp.utility cimport pair
from cpython.ref cimport PyObject

cdef extern from "tmxlite/Types.hpp" namespace "tmx" nogil:
    cdef cppclass Vector2[T]:
        Vector2() except +
        Vector2(T x, T y) except +
        T x
        T y
    ctypedef Vector2[float]    Vector2f
    ctypedef Vector2[int]      Vector2i
    ctypedef Vector2[unsigned] Vector2u
    cdef cppclass Rectangle[T]:
        Rectangle() except +
        Rectangle(T l, T t, T w, T h) except +
        Rectangle(Vector2[T] position, Vector2[T] size) except +
        T left
        T top
        T width
        T height
    ctypedef Rectangle[float] FloatRect
    ctypedef Rectangle[int] IntRect
    cdef cppclass Colour:
        Colour() except +
        Colour(uint8_t red, uint8_t green, uint8_t blue) except +
        Colour(uint8_t red, uint8_t green, uint8_t blue, uint8_t alpha) except +
        bool operator == (const Colour& other)
        bool operator != (const Colour& other)
        uint8_t r
        uint8_t g
        uint8_t b
        uint8_t a

cdef extern from "tmxlite/Property.hpp" namespace "tmx" nogil:
    cdef cppclass Property_Type "tmx::Property::Type":
        pass

    cdef bool operator==(const Property_Type&, const Property_Type&)

    cdef Property_Type Property_Type_Boolean "tmx::Property::Type::Boolean"
    cdef Property_Type Property_Type_Float   "tmx::Property::Type::Float"
    cdef Property_Type Property_Type_Int     "tmx::Property::Type::Int"
    cdef Property_Type Property_Type_String  "tmx::Property::Type::String"
    cdef Property_Type Property_Type_Colour  "tmx::Property::Type::Colour"
    cdef Property_Type Property_Type_File    "tmx::Property::Type::File"
    cdef Property_Type Property_Type_Object  "tmx::Property::Type::Object"
    cdef Property_Type Property_Type_Undef   "tmx::Property::Type::Undef"

    cdef cppclass Property:
        Property_Type getType() const
        const string& getName() const

        @staticmethod
        Property fromBoolean(bool value)
        @staticmethod
        Property fromFloat(float value)
        @staticmethod
        Property fromInt(int value)
        @staticmethod
        Property fromString(const string& value)
        @staticmethod
        Property fromColour(const Colour& value)
        @staticmethod
        Property fromFile(const string& value)
        @staticmethod
        Property fromObject(int value)

        bool getBoolValue() const
        float getFloatValue() const
        int getIntValue() const
        const string& getStringValue() const
        const Colour& getColourValue() const
        const string& getFileValue() const
        int getObjectValue() const

cdef extern from "tmxlite/Layer.hpp" namespace "tmx" nogil:
    cdef cppclass Layer_Type "tmx::Layer::Type":
        pass

    cdef bool operator==(const Layer_Type&, const Layer_Type&)

    cdef Layer_Type Layer_Type_Tile   "tmx::Layer::Type::Tile"
    cdef Layer_Type Layer_Type_Object "tmx::Layer::Type::Object"
    cdef Layer_Type Layer_Type_Image  "tmx::Layer::Type::Image"
    cdef Layer_Type Layer_Type_Group  "tmx::Layer::Type::Group"

    cdef cppclass Layer:
        Layer() except +
        Layer_Type getType()
        const string& getName() const
        ctypedef shared_ptr[Layer] Ptr
        T& getLayerAs[T]() except +
        float getOpacity() const
        bool getVisible() const
        const Vector2i& getOffset() const
        const Vector2u& getSize() const
        const vector[Property]& getProperties() const

cdef extern from "tmxlite/LayerGroup.hpp" namespace "tmx" nogil:
    cdef cppclass LayerGroup(Layer):
        LayerGroup() except +
        const vector[Layer.Ptr]& getLayers() const

cdef extern from "tmxlite/ObjectTypes.hpp" namespace "tmx" nogil:
    cdef cppclass ObjectTypes_Type "tmx::ObjectTypes::Type":
        string name
        Colour colour;
        vector[Property] properties

    cdef cppclass ObjectTypes:
        ObjectTypes() except +
        bool load(const string&)
        bool loadFromString(const string& data, const string& workingDir)
        const vector[ObjectTypes_Type]& getTypes() const

cdef extern from "tmxlite/Object.hpp" namespace "tmx" nogil:
    cdef cppclass Text_HAlign "tmx::Text::HAlign":
        pass
    cdef Text_HAlign Text_HAlign_Left   "tmx::Text::HAlign::Left"
    cdef Text_HAlign Text_HAlign_Centre "tmx::Text::HAlign::Centre"
    cdef Text_HAlign Text_HAlign_Right  "tmx::Text::HAlign::Right"

    cdef cppclass Text_HAlign "tmx::Text::VAlign":
        pass
    cdef Text_HAlign Text_VAlign_Top    "tmx::Text::VAlign::Top"
    cdef Text_HAlign Text_VAlign_Centre "tmx::Text::VAlign::Centre"
    cdef Text_HAlign Text_VAlign_Bottom "tmx::Text::VAlign::Bottom"

    cdef cppclass Text "tmx::Text":
        string fontFamily
        uint32_t pixelSize
        bool wrap
        Colour colour
        bool bold
        bool italic
        bool underline
        bool strikethough
        bool kerning
        string content

    cdef cppclass Object_Shape "tmx::Object::Shape":
        pass

    cdef bool operator==(const Object_Shape&, const Object_Shape&)

    cdef Object_Shape Object_Shape_Rectangle "tmx::Object::Shape::Rectangle"
    cdef Object_Shape Object_Shape_Ellipse   "tmx::Object::Shape::Ellipse"
    cdef Object_Shape Object_Shape_Point     "tmx::Object::Shape::Point"
    cdef Object_Shape Object_Shape_Polygon   "tmx::Object::Shape::Polygon"
    cdef Object_Shape Object_Shape_Polyline  "tmx::Object::Shape::Polyline"
    cdef Object_Shape Object_Shape_Text      "tmx::Object::Shape::Text"

    cdef cppclass Object:
        Object() except +
        Layer_Type getType()
        uint32_t getUID() const
        const string& getName() const
        const string& getType() const
        const Vector2f& getPosition()
        const FloatRect& getAABB()
        float getRotation() const
        uint32_t getTileID() const
        uint8_t getFlipFlags() const
        bool visible() const
        Object_Shape getShape() const
        const vector[Vector2f]& getPoints() const
        const vector[Property]& getProperties() const
        const Text& getText() const
        Text& getText()
        const string& getTilesetName() const

cdef extern from "tmxlite/ObjectGroup.hpp" namespace "tmx" nogil:
    cdef cppclass DrawOrder "tmx::DrawOrder":
        pass
    cdef DrawOrder DrawOrder_Index   "tmx::DrawOrder::Index"
    cdef DrawOrder DrawOrder_TopDown "tmx::DrawOrder::TopDown"

    cdef cppclass ObjectGroup(Layer):
        ObjectGroup() except +
        const Colour& getColour()
        DrawOrder getDrawOrder() const
        const vector[Property]& getProperties() const
        const vector[Object]& getObjects() const

cdef extern from "tmxlite/ImageLayer.hpp" namespace "tmx" nogil:
    cdef cppclass ImageLayer(Layer):
        ImageLayer() except +
        const string& getImagePath() const
        const Colour& getTransparencyColour() const
        bool hasTransparency() const
        const Vector2u& getImageSize() const

cdef extern from "tmxlite/TileLayer.hpp" namespace "tmx" nogil:
    ctypedef enum FlipFlag "tmx::TileLayer::FlipFlag":
        Horizontal "tmx::TileLayer::Horizontal"
        Vertical "tmx::TileLayer::Vertical"
        Diagonal "tmx::TileLayer::Diagonal"

    cdef cppclass TileLayer_Tile "tmx::TileLayer::Tile":
        uint32_t ID
        uint8_t flipFlags

    cdef cppclass TileLayer_Chunk "tmx::TileLayer::Chunk":
        Vector2i position
        Vector2i size
        vector[TileLayer_Tile] tiles

    cdef cppclass TileLayer(Layer):
        TileLayer() except +
        const string& getImagePath() const
        const vector[TileLayer_Tile]& getTiles() const
        const vector[TileLayer_Chunk]& getChunks() const

cdef extern from "<array>" namespace "std" nogil:
    cdef cppclass array4 "std::array<std::int32_t, 4u>":
        array4() except+
        int32_t& operator[](size_t)

cdef extern from "tmxlite/Tileset.hpp" namespace "tmx" nogil:
    cdef cppclass Tileset_Tile_Frame "tmx::Tileset::Tile::Frame":
        uint32_t tileID
        uint32_t duration
        bool operator == (const Tileset_Tile_Frame& other) const
        bool operator != (const Tileset_Tile_Frame& other) const

    cdef cppclass Tileset_Tile_Animation "tmx::Tileset::Tile::Animation":
        vector[Tileset_Tile_Frame] frames;

    cdef cppclass Tileset_Tile "tmx::Tileset::Tile":
        uint32_t ID
        array4 terrainIndices
        uint32_t probability

        vector[Property] properties;
        ObjectGroup objectGroup;
        string imagePath;
        Vector2u imageSize;
        Vector2u imagePosition;
        string type;

    cdef cppclass Tileset_Terrain "tmx::Tileset::Terrain":
        string name
        uint32_t tileID
        vector[Property] properties

    cdef cppclass Tileset_ObjectAlignment:
        pass

    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_Unspecified    "tmx::Tileset::ObjectAlignment::Unspecified"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_TopLeft        "tmx::Tileset::ObjectAlignment::TopLeft"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_Top            "tmx::Tileset::ObjectAlignment::Top"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_TopRight       "tmx::Tileset::ObjectAlignment::TopRight"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_Left           "tmx::Tileset::ObjectAlignment::Left"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_Center         "tmx::Tileset::ObjectAlignment::Center"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_Right          "tmx::Tileset::ObjectAlignment::Right"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_BottomLeft     "tmx::Tileset::ObjectAlignment::BottomLeft"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_Bottom         "tmx::Tileset::ObjectAlignment::Bottom"
    cdef Tileset_ObjectAlignment Tileset_ObjectAlignment_BottomRight    "tmx::Tileset::ObjectAlignment::BottomRight"

    cdef cppclass Tileset:
        Tileset() except +
        uint32_t getFirstGID() const
        uint32_t getLastGID() const
        const string& getName() const
        const Vector2u& getTileSize() const
        uint32_t getSpacing() const
        uint32_t getMargin() const
        uint32_t getTileCount() const
        uint32_t getColumnCount() const
        Tileset_ObjectAlignment getObjectAlignment() const
        const Vector2u& getTileOffset() const
        const vector[Property]& getProperties() const
        const string getImagePath() const
        const Vector2u& getImageSize() const
        const Colour& getTransparencyColour() const
        bool hasTransparency() const
        const vector[Tileset_Terrain]& getTerrainTypes() const
        const vector[Tileset_Tile]& getTiles() const
        bool hasTile(uint32_t id) const
        const Tileset_Tile* getTile(uint32_t id) const

cdef extern from "tmxlite/Map.hpp" namespace "tmx" nogil:
    cdef cppclass Version:
        uint16_t upper
        uint16_t lower
        Version()
        Version(uint16_t maj, uint16_t min)

    cdef cppclass Orientation:
        pass

    cdef Orientation Orientation_Orthogonal "tmx::Orientation::Orthogonal"
    cdef Orientation Orientation_Isometric  "tmx::Orientation::Isometric"
    cdef Orientation Orientation_Staggered  "tmx::Orientation::Staggered"
    cdef Orientation Orientation_Hexagonal  "tmx::Orientation::Hexagonal"
    cdef Orientation Orientation_None       "tmx::Orientation::None"

    cdef cppclass RenderOrder:
        pass

    cdef RenderOrder RenderOrder_RightDown "tmx::RenderOrder::RightDown"
    cdef RenderOrder RenderOrder_RightUp   "tmx::RenderOrder::RightUp"
    cdef RenderOrder RenderOrder_LeftDown  "tmx::RenderOrder::LeftDown"
    cdef RenderOrder RenderOrder_LeftUp    "tmx::RenderOrder::LeftUp"
    cdef RenderOrder RenderOrder_None      "tmx::RenderOrder::None"

    cdef cppclass StaggerAxis:
        pass

    cdef StaggerAxis StaggerAxis_X    "tmx::StaggerAxis::X"
    cdef StaggerAxis StaggerAxis_Y    "tmx::StaggerAxis::Y"
    cdef StaggerAxis StaggerAxis_None "tmx::StaggerAxis::None"

    cdef cppclass StaggerIndex:
        pass

    cdef StaggerIndex StaggerIndex_Even "tmx::StaggerIndex::Even"
    cdef StaggerIndex StaggerIndex_Odd  "tmx::StaggerIndex::Odd"
    cdef StaggerIndex StaggerIndex_None "tmx::StaggerIndex::None"

    cdef cppclass Map:
        bool load(const string&)
        bool loadFromString(const string& data, const string& workingDir)
        const Version& getVersion() const
        Orientation getOrientation() const
        RenderOrder getRenderOrder() const
        const Vector2u& getTileCount() const
        const Vector2u& getTileSize() const
        FloatRect getBounds() const
        float getHexSideLength() const
        StaggerAxis getStaggerAxis() const
        StaggerIndex getStaggerIndex() const
        const Colour& getBackgroundColour() const
        const vector[Tileset]& getTilesets() const
        const vector[Layer.Ptr]& getLayers() const
        const vector[Property]& getProperties() const
        const map[uint32_t, Tileset_Tile]& getAnimatedTiles() const
        const string& getWorkingDirectory() const
        unordered_map[string, Object]& getTemplateObjects()
        const unordered_map[string, Object]& getTemplateObjects() const
        unordered_map[string, Tileset]& getTemplateTilesets()
        const unordered_map[string, Tileset]& getTemplateTilesets() const
        bool isInfinite() const

cdef extern from "tmxlite/ObjectGroup.hpp" namespace "tmx" nogil:
    cdef cppclass ObjectGroup(Layer):
        ObjectGroup() except +
