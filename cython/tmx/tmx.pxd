# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libc.stdint cimport int32_t, uint32_t, int16_t, uint16_t, int8_t, uint8_t
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.map cimport map
from libcpp.unordered_map cimport unordered_map
from libcpp.utility cimport pair
from cpython.ref cimport PyObject

cdef extern from "tmx/tmx.h" namespace "":
    ctypedef void tmx_properties
    ctypedef void tmx_resource_manager
    ctypedef int (*tmx_read_functor)(void *userdata, char *buffer, int len)
    ctypedef void (*tmx_property_functor)(tmx_property *property, void *userdata)

    cdef enum tmx_map_orient:
        O_NONE
        O_ORT
        O_ISO
        O_STA
        O_HEX

    cdef enum tmx_map_renderorder:
        R_NONE
        R_RIGHTDOWN
        R_RIGHTUP
        R_LEFTDOWN
        R_LEFTUP

    cdef enum tmx_stagger_index:
        SI_NONE
        SI_EVEN
        SI_ODD

    cdef enum tmx_stagger_axis:
        SA_NONE
        SA_X
        SA_Y

    cdef enum tmx_obj_alignment:
        OA_NONE
        OA_TOP
        OA_LEFT
        OA_BOTTOM
        OA_RIGHT
        OA_CENTER
        OA_TOPLEFT
        OA_TOPRIGHT
        OA_BOTTOMLEFT
        OA_BOTTOMRIGHT

    cdef enum tmx_layer_type:
        L_NONE
        L_LAYER
        L_OBJGR
        L_IMAGE
        L_GROUP

    cdef enum tmx_objgr_draworder:
        G_NONE
        G_INDEX
        G_TOPDOWN

    cdef enum tmx_obj_type:
        OT_NONE
        OT_SQUARE
        OT_POLYGON
        OT_POLYLINE
        OT_ELLIPSE
        OT_TILE
        OT_TEXT
        OT_POINT

    cdef enum tmx_property_type:
        PT_NONE
        PT_INT
        PT_FLOAT
        PT_BOOL
        PT_STRING
        PT_COLOR
        PT_FILE

    cdef enum tmx_horizontal_align:
        HA_NONE
        HA_LEFT
        HA_CENTER
        HA_RIGHT

    cdef enum tmx_vertical_align:
        VA_NONE
        VA_TOP
        VA_CENTER
        VA_BOTTOM

    cdef enum _tmx_error_codes:
        # Syst
        E_NONE
        E_UNKN
        E_INVAL

        # I/O
        E_ALLOC
        E_ACCESS
        E_NOENT
        E_FORMAT
        E_ENCCMP
        E_FONCT
        E_BDATA
        E_ZDATA
        E_XDATA
        E_ZSDATA
        E_CDATA
        E_MISSEL

    ctypedef _tmx_error_codes tmx_error_codes

    cdef union tmx_user_data:
        int integer
        float decimal
        void *pointer

    cdef union tmx_property_value:
        int integer, boolean
        float decimal
        char *string
        char *file
        uint32_t color

    cdef cppclass tmx_property:
        char *name
        tmx_property_type type
        tmx_property_value value

    cdef cppclass tmx_image:
        char *source
        unsigned int trans
        int uses_trans
        unsigned long width
        unsigned long height
        #char *format
        #char *data
        void *resource_image

    cdef cppclass tmx_anim_frame:
        unsigned int tile_id
        unsigned int duration

    cdef cppclass tmx_tile:
        unsigned int id
        tmx_tileset *tileset
        unsigned int ul_x
        unsigned int ul_y
        tmx_image *image
        tmx_object *collision
        unsigned int animation_len
        tmx_anim_frame *animation
        char *type
        tmx_properties *properties
        tmx_user_data user_data

    cdef cppclass tmx_tileset:
        char *name
        unsigned int tile_width
        unsigned int tile_height
        unsigned int spacing
        unsigned int margin
        int x_offset
        int y_offset
        tmx_obj_alignment objectalignment
        unsigned int tilecount
        tmx_image *image
        tmx_user_data user_data
        tmx_properties *properties
        tmx_tile *tiles

    cdef cppclass tmx_tileset_list:
        int is_embedded
        unsigned int firstgid
        char *source
        tmx_tileset *tileset
        tmx_tileset_list *next

    cdef cppclass tmx_shape:
        double **points
        int points_len

    cdef cppclass tmx_text:
        char *fontfamily
        int pixelsize
        uint32_t color
        int wrap
        int bold
        int italic
        int underline
        int strikeout
        int kerning
        tmx_horizontal_align halign
        tmx_vertical_align valign
        char *text

    cdef cppclass tmx_object:
        unsigned int id
        tmx_obj_type obj_type
        double x
        double y
        double width
        double height
        union content:
                int gid
                tmx_shape *shape
                tmx_text *text
        int visible
        double rotation
        char *name
        char *type
        tmx_template *template_ref
        tmx_properties *properties
        tmx_object *next

    cdef cppclass tmx_object_group:
        uint32_t color
        tmx_objgr_draworder draworder
        tmx_object *head

    cdef cppclass tmx_template:
        int is_embedded
        tmx_tileset_list *tileset_ref
        tmx_object *object

    cdef cppclass tmx_layer:
        int id
        char *name
        double opacity
        int visible
        int offsetx
        int offsety;
        double parallaxx
        double parallaxy
        uint32_t tintcolor
        tmx_layer_type type
        union content:
                uint32_t *gids
                tmx_object_group *objgr
                tmx_image *image
                tmx_layer *group_head
        tmx_user_data user_data
        tmx_properties *properties
        tmx_layer *next

    cdef cppclass tmx_map:
        tmx_map_orient orient
        unsigned int width
        unsigned int height
        unsigned int tile_width
        unsigned int tile_height
        tmx_stagger_index stagger_index
        tmx_stagger_axis stagger_axis
        int hexsidelength
        uint32_t backgroundcolor
        tmx_map_renderorder renderorder
        tmx_properties *properties
        tmx_tileset_list *ts_head
        tmx_layer *ly_head
        unsigned int tilecount
        tmx_tile **tiles
        tmx_user_data user_data

    cdef cppclass tmx_col_bytes:
        int r
        int g
        int b
        int a

    cdef cppclass tmx_col_floats:
        float r
        float g
        float b
        float a

    tmx_map* tmx_load(const char *path)
    tmx_map* tmx_load_buffer(const char *buffer, int len)
    tmx_map* tmx_load_buffer_path(const char *buffer, int len, const char* path)
    tmx_map* tmx_load_fd(int fd)

    tmx_map* tmx_load_callback(tmx_read_functor callback, void *userdata)
    void tmx_map_free(tmx_map *map) except +
    tmx_tile* tmx_get_tile(tmx_map *map, unsigned int gid)
    tmx_layer* tmx_find_layer_by_id(const tmx_map *map, int id)
    tmx_layer* tmx_find_layer_by_name(const tmx_map *map, const char *name)
    tmx_property* tmx_get_property(tmx_properties *hash, const char *key)

    void tmx_property_foreach(tmx_properties *hash, tmx_property_functor callback, void *userdata) except +

    tmx_col_bytes tmx_col_to_bytes(uint32_t color) except +
    tmx_col_floats tmx_col_to_floats(uint32_t color) except +

    tmx_resource_manager* tmx_make_resource_manager()
    void tmx_free_resource_manager(tmx_resource_manager *rc_mgr) except +

    int tmx_load_tileset(tmx_resource_manager *rc_mgr, const char *path) except +
    int tmx_load_tileset_buffer(tmx_resource_manager *rc_mgr, const char *buffer, int len, const char *key) except +
    int tmx_load_tileset_fd(tmx_resource_manager *rc_mgr, int fd, const char *key) except +
    int tmx_load_tileset_callback(tmx_resource_manager *rc_mgr, tmx_read_functor callback, void *userdata, const char *key) except +

    int tmx_load_template(tmx_resource_manager *rc_mgr, const char *path) except +
    int tmx_load_template_buffer(tmx_resource_manager *rc_mgr, const char *buffer, int len, const char *key) except +
    int tmx_load_template_fd(tmx_resource_manager *rc_mgr, int fd, const char *key) except +
    int tmx_load_template_callback(tmx_resource_manager *rc_mgr, tmx_read_functor callback, void *userdata, const char *key) except +

    tmx_map* tmx_rcmgr_load(tmx_resource_manager *rc_mgr, const char *path)
    tmx_map* tmx_rcmgr_load_buffer(tmx_resource_manager *rc_mgr, const char *buffer, int len)
    tmx_map* tmx_rcmgr_load_fd(tmx_resource_manager *rc_mgr, int fd)
    tmx_map* tmx_rcmgr_load_callback(tmx_resource_manager *rc_mgr, tmx_read_functor callback, void *userdata)

    cdef tmx_error_codes tmx_errno
    void tmx_perror(const char*) except +
    const char* tmx_strerr()
