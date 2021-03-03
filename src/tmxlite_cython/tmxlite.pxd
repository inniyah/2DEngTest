# cython: profile=False
# distutils: language = c++
# cython: embedsignature = True
# cython: language_level = 3

from libc.stdint cimport uint32_t, uint16_t, uint8_t
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from cpython.ref cimport PyObject

cdef extern from "Property.hpp" namespace "tmx" nogil:
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

cdef extern from "Layer.hpp" namespace "tmx" nogil:
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

cdef extern from "LayerGroup.hpp" namespace "tmx" nogil:
    cdef cppclass LayerGroup(Layer):
        LayerGroup() except +
        const vector[Layer.Ptr]& getLayers() const

cdef extern from "Map.hpp" namespace "tmx" nogil:
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
        bool load(const string&);
        const Version& getVersion() const
        Orientation getOrientation() const
        RenderOrder getRenderOrder() const
        bool isInfinite() const
        const vector[Layer.Ptr]& getLayers() const
        const vector[Property]& getProperties() const

cdef extern from "ObjectGroup.hpp" namespace "tmx" nogil:
    cdef cppclass ObjectGroup(Layer):
        ObjectGroup() except +

cdef extern from "TileLayer.hpp" namespace "tmx" nogil:
    pass
