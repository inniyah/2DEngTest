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
from cpython.pycapsule cimport PyCapsule_New, PyCapsule_IsValid, PyCapsule_GetPointer, PyCapsule_GetName
from enum import IntEnum

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cimport hub

def get():
    return hub.get_singleton()

def set(new_val):
    hub.set_singleton(new_val)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cdef class _test:

    cdef ctmx.tmx_map * _map
    cdef SDL2_gpu.GPU_Target * _screen

    def __cinit__(self):
        self._map = NULL
        self._screen = NULL

    def __dealloc___(self):
        if self._map == NULL:
            ctmx.tmx_map_free(self._map);

    def reset(self):
        if self._map == NULL:
            ctmx.tmx_map_free(self._map);
        self._map = NULL
        self._screen = NULL

    def putScreenCapsule(self, screen):
        cdef const char *name = "SDL2_gpu.GPU_Target"
        if not PyCapsule_IsValid(screen, name):
            raise ValueError("invalid pointer to parameters")
        self._screen = <SDL2_gpu.GPU_Target *>PyCapsule_GetPointer(screen, name)

    def load(self, filename):
        self.reset()
        self._map = ctmx.tmx_load(filename.encode('utf8'))
        if not self._map:
            raise SystemExit(f"Error loading map: {ctmx.tmx_strerr()}")

    def render_map(self):
        cdef ctmx.tmx_col_bytes col = ctmx.tmx_col_to_bytes(self._map.backgroundcolor)
        #~ GPU_ClearRGBA(screen, col.r, col.g, col.b, col.a)
        self.draw_all_layers(self._map.ly_head)

    cdef draw_all_layers(self, ctmx.tmx_layer *layers):
        while layers:
            if layers.visible:
                if layers.type == ctmx.L_GROUP:
                    print(f"Drawing Group Layer: '{layers.name.decode('utf8')}'")
                    self.draw_all_layers(layers.content.group_head)
                elif layers.type == ctmx.L_OBJGR:
                    print(f"Drawing Objects Layer: '{layers.name.decode('utf8')}'")
                    self.draw_objects(layers.content.objgr)
                elif layers.type == ctmx.L_IMAGE:
                    print(f"Drawing Image Layer: '{layers.name.decode('utf8')}'")
                    self.draw_image_layer(layers.content.image)
                elif layers.type == ctmx.L_LAYER:
                    print(f"Drawing Tiled Layer: '{layers.name.decode('utf8')}'")
                    self.draw_layer(layers)
            layers = layers.next

    cdef draw_image_layer(self, ctmx.tmx_image *image):
        print("draw_image_layer")
        #~ GPU_Image *texture = (GPU_Image*)image->resource_image; // Texture loaded by libTMX
        #~ GPU_Rect dim;
        #~ dim.x = dim.y = 0;
        #~ dim.w = texture->w;
        #~ dim.h = texture->h;
        #~ GPU_Blit(texture, &dim, screen, dim.x, dim.y);

    cdef draw_layer(self, ctmx.tmx_layer *layer):
        print("draw_layer")

        cdef unsigned long i, j
        cdef unsigned int gid, x, y, w, h, flags
        cdef float op
        cdef ctmx.tmx_tileset *ts
        cdef ctmx.tmx_image *im
        cdef void* image

        op = layer.opacity
        for i in range(self._map.height):
            for j in range(self._map.width):
                gid = (layer.content.gids[(i * self._map.width) + j]) & ctmx.TMX_FLIP_BITS_REMOVAL
                if self._map.tiles[gid] != NULL:
                    ts = self._map.tiles[gid].tileset;
                    im = self._map.tiles[gid].image;
                    x  = self._map.tiles[gid].ul_x;
                    y  = self._map.tiles[gid].ul_y;
                    w  = ts.tile_width;
                    h  = ts.tile_height;
                    if im != NULL:
                        image = im.resource_image
                    else:
                        image = ts.image.resource_image
                    flags = (layer.content.gids[(i * self._map.width) + j]) & ~ctmx.TMX_FLIP_BITS_REMOVAL
                    self.draw_tile(image, x, y, w, h, j * ts.tile_width, i * ts.tile_height, op, flags)

    cdef draw_tile(self, void *image, unsigned int sx, unsigned int sy, unsigned int sw, unsigned int sh, unsigned int dx, unsigned int dy, float opacity, unsigned int flags):
        print("draw_tile")
        #~ GPU_Rect src_rect, dest_rect;
        #~ src_rect.x = sx;
        #~ src_rect.y = sy;
        #~ src_rect.w = dest_rect.w = sw;
        #~ src_rect.h = dest_rect.h = sh;
        #~ dest_rect.x = dx;
        #~ dest_rect.y = dy;
        #~ GPU_BlitRect((GPU_Image*)image, &src_rect, screen, &dest_rect);

    cdef draw_objects(self, ctmx.tmx_object_group *objgr):
        print("draw_objects")

        cdef ctmx.tmx_col_bytes col = ctmx.tmx_col_to_bytes(objgr.color)
        #~ SDL_Color color = {.r = col.r, .g = col.g, .b = col.b, .a = 255};

        cdef ctmx.tmx_object *head = objgr.head
        while head != NULL:
            if head.visible:
                if head.obj_type == ctmx.OT_SQUARE:
                    print("OT_SQUARE")
                    #~ GPU_Rectangle(screen, head->x, head->y, head->x + head->width, head->y + head->height, color);
                elif head.obj_type == ctmx.OT_POLYGON:
                    print("OT_POLYGON")
                    self.draw_polygon(head.content.shape.points, head.x, head.y, head.content.shape.points_len)
                elif head.obj_type == ctmx.OT_POLYLINE:
                    print("OT_POLYLINE")
                    self.draw_polyline(head.content.shape.points, head.x, head.y, head.content.shape.points_len)
                elif head.obj_type == ctmx.OT_ELLIPSE:
                    print("OT_ELLIPSE")
                    #~ GPU_Ellipse(screen, head->x + head->width/2.0, head->y + head->height/2.0, head->width/2.0, head->height/2.0, 360.0, color)
            head = head.next;

    cdef draw_polyline(self, double **points, double x, double y, int pointsc):
        print("draw_polyline")
        cdef int i
        for i in range(1, pointsc):
            #~ GPU_Line(screen, x+points[i-1][0], y+points[i-1][1], x+points[i][0], y+points[i][1], color)
            pass

    cdef draw_polygon(self, double **points, double x, double y, int pointsc):
        print("draw_polygon")
        self.draw_polyline(points, x, y, pointsc)
        if pointsc > 2:
            #~ GPU_Line(screen, x+points[0][0], y+points[0][1], x+points[pointsc-1][0], y+points[pointsc-1][1], color)
            pass

class test(_test):
    def __init__(self, filename : str = None):
        if not filename is None:
            self.load(filename)

