# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libc.stdint cimport int32_t, uint32_t, int16_t, uint16_t, int8_t, uint8_t
from libc.stdlib cimport calloc, malloc, free
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, make_shared, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair
from cpython.ref cimport PyObject
from cython cimport view
cimport cpython.array
from cython.operator cimport dereference as deref
from enum import IntEnum

cimport tmx.tmx as ctmx

cdef class tmx_map_orient:
    O_NONE = ctmx.O_NONE
    O_ORT = ctmx.O_ORT
    O_ISO = ctmx.O_ISO
    O_STA = ctmx.O_STA
    O_HEX = ctmx.O_HEX

cdef class tmx_map_renderorder:
    R_NONE = ctmx.R_NONE
    R_RIGHTDOWN = ctmx.R_RIGHTDOWN
    R_RIGHTUP = ctmx.R_RIGHTUP
    R_LEFTDOWN = ctmx.R_LEFTDOWN
    R_LEFTUP = ctmx.R_LEFTUP

cdef class tmx_stagger_index:
    SI_NONE = ctmx.SI_NONE
    SI_EVEN = ctmx.SI_EVEN
    SI_ODD = ctmx.SI_ODD

cdef class tmx_stagger_axis:
    SA_NONE = ctmx.SA_NONE
    SA_X = ctmx.SA_X
    SA_Y = ctmx.SA_Y

cdef class tmx_obj_alignment:
    OA_NONE = ctmx.OA_NONE
    OA_TOP = ctmx.OA_TOP
    OA_LEFT = ctmx.OA_LEFT
    OA_BOTTOM = ctmx.OA_BOTTOM
    OA_RIGHT = ctmx.OA_RIGHT
    OA_CENTER = ctmx.OA_CENTER
    OA_TOPLEFT = ctmx.OA_TOPLEFT
    OA_TOPRIGHT = ctmx.OA_TOPRIGHT
    OA_BOTTOMLEFT = ctmx.OA_BOTTOMLEFT
    OA_BOTTOMRIGHT = ctmx.OA_BOTTOMRIGHT

cdef class tmx_layer_type:
    L_NONE = ctmx.L_NONE
    L_LAYER = ctmx.L_LAYER
    L_OBJGR = ctmx.L_OBJGR
    L_IMAGE = ctmx.L_IMAGE
    L_GROUP = ctmx.L_GROUP

cdef class tmx_objgr_draworder:
    G_NONE = ctmx.G_NONE
    G_INDEX = ctmx.G_INDEX
    G_TOPDOWN = ctmx.G_TOPDOWN

cdef class tmx_obj_type:
    OT_NONE = ctmx.OT_NONE
    OT_SQUARE = ctmx.OT_SQUARE
    OT_POLYGON = ctmx.OT_POLYGON
    OT_POLYLINE = ctmx.OT_POLYLINE
    OT_ELLIPSE = ctmx.OT_ELLIPSE
    OT_TILE = ctmx.OT_TILE
    OT_TEXT = ctmx.OT_TEXT
    OT_POINT = ctmx.OT_POINT

cdef class tmx_property_type:
    PT_NONE = ctmx.PT_NONE
    PT_INT = ctmx.PT_INT
    PT_FLOAT = ctmx.PT_FLOAT
    PT_BOOL = ctmx.PT_BOOL
    PT_STRING = ctmx.PT_STRING
    PT_COLOR = ctmx.PT_COLOR
    PT_FILE = ctmx.PT_FILE

cdef class tmx_horizontal_align:
    HA_NONE = ctmx.HA_NONE
    HA_LEFT = ctmx.HA_LEFT
    HA_CENTER = ctmx.HA_CENTER
    HA_RIGHT = ctmx.HA_RIGHT

cdef class tmx_vertical_align:
    VA_NONE = ctmx.VA_NONE
    VA_TOP = ctmx.VA_TOP
    VA_CENTER = ctmx.VA_CENTER
    VA_BOTTOM = ctmx.VA_BOTTOM

cdef class tmx_error_codes:
    E_NONE = ctmx.E_NONE
    E_UNKN = ctmx.E_UNKN
    E_INVAL = ctmx.E_INVAL
    E_ALLOC = ctmx.E_ALLOC
    E_ACCESS = ctmx.E_ACCESS
    E_NOENT = ctmx.E_NOENT
    E_FORMAT = ctmx.E_FORMAT
    E_ENCCMP = ctmx.E_ENCCMP
    E_FONCT = ctmx.E_FONCT
    E_BDATA = ctmx.E_BDATA
    E_ZDATA = ctmx.E_ZDATA
    E_XDATA = ctmx.E_XDATA
    E_ZSDATA = ctmx.E_ZSDATA
    E_CDATA = ctmx.E_CDATA
    E_MISSEL = ctmx.E_MISSEL
