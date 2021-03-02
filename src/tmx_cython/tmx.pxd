cdef extern from "tmx.h" nogil:

    ctypedef enum tmx_map_orient:
        O_NONE
        O_ORT
        O_ISO
        O_STA
        O_HEX

    ctypedef enum tmx_map_renderorder:
        R_NONE
        R_RIGHTDOWN
        R_RIGHTUP
        R_LEFTDOWN
        R_LEFTUP

    ctypedef enum tmx_stagger_index:
        SI_NONE
        SI_EVEN
        SI_ODD

    ctypedef enum tmx_stagger_axis:
        SA_NONE
        SA_X
        SA_Y

    ctypedef enum tmx_obj_alignment:
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

    ctypedef enum tmx_layer_type:
        L_NONE
        L_LAYER
        L_OBJGR
        L_IMAGE
        L_GROUP

    ctypedef enum tmx_objgr_draworder:
        G_NONE
        G_INDEX
        G_TOPDOWN

    ctypedef enum tmx_obj_type:
        OT_NONE
        OT_SQUARE
        OT_POLYGON
        OT_POLYLINE
        OT_ELLIPSE
        OT_TILE
        OT_TEXT
        OT_POINT

    ctypedef enum tmx_property_type:
        PT_NONE
        PT_INT
        PT_FLOAT
        PT_BOOL
        PT_STRING
        PT_COLOR
        PT_FILE

    ctypedef enum tmx_horizontal_align:
        HA_NONE
        HA_LEFT
        HA_CENTER
        HA_RIGHT

    ctypedef enum tmx_vertical_align:
        VA_NONE
        VA_TOP
        VA_CENTER
        VA_BOTTOM

