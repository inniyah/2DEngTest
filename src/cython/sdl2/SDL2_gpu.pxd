# Cython PXD file for SDL2_gpu 0.12

# The MIT License (MIT)
# Copyright (c) 2019 Jonathan Dearborn
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
# THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS
# IN THE SOFTWARE.

from sdl2.SDL2 cimport *

from libc.stdint cimport uint32_t, uint16_t, uint8_t, uintptr_t

cdef extern from "stdarg.h":
    ctypedef struct va_list:
        pass
    ctypedef struct fake_type:
        pass
    void va_start(va_list, void* arg)
    void* va_arg(va_list, fake_type)
    void va_end(va_list)
    fake_type int_type "int"
    fake_type char_ptr_type "char*"

cdef extern from "SDL_gpu.h" nogil:
    ctypedef enum GPU_bool:
        GPU_FALSE
        GPU_TRUE

    ctypedef struct GPU_Renderer
    ctypedef struct GPU_Target

    ctypedef struct GPU_Rect:
        float x, y
        float w, h

    ctypedef enum IMG_InitFlags:
        IMG_INIT_JPG
        IMG_INIT_PNG
        IMG_INIT_TIF
        IMG_INIT_WEBP

    ctypedef Uint32 GPU_RendererEnum

    cdef enum:
        GPU_RENDERER_UNKNOWN
        GPU_RENDERER_OPENGL_1_BASE
        GPU_RENDERER_OPENGL_1
        GPU_RENDERER_OPENGL_2
        GPU_RENDERER_OPENGL_3
        GPU_RENDERER_OPENGL_4
        GPU_RENDERER_GLES_1
        GPU_RENDERER_GLES_2
        GPU_RENDERER_GLES_3
        GPU_RENDERER_D3D9
        GPU_RENDERER_D3D10
        GPU_RENDERER_D3D11

    ctypedef struct GPU_RendererID:
        const char* name
        GPU_RendererEnum renderer
        int major_version
        int minor_version

    ctypedef enum GPU_ComparisonEnum:
        GPU_NEVER
        GPU_LESS
        GPU_EQUAL
        GPU_LEQUAL
        GPU_GREATER
        GPU_NOTEQUAL
        GPU_GEQUAL
        GPU_ALWAYS

    ctypedef enum GPU_BlendFuncEnum:
        GPU_FUNC_ZERO
        GPU_FUNC_ONE
        GPU_FUNC_SRC_COLOR
        GPU_FUNC_DST_COLOR
        GPU_FUNC_ONE_MINUS_SRC
        GPU_FUNC_ONE_MINUS_DST
        GPU_FUNC_SRC_ALPHA
        GPU_FUNC_DST_ALPHA
        GPU_FUNC_ONE_MINUS_SRC_ALPHA
        GPU_FUNC_ONE_MINUS_DST_ALPHA

    ctypedef enum GPU_BlendEqEnum:
        GPU_EQ_ADD
        GPU_EQ_SUBTRACT
        GPU_EQ_REVERSE_SUBTRACT

    ctypedef struct GPU_BlendMode:
        GPU_BlendFuncEnum source_color
        GPU_BlendFuncEnum dest_color
        GPU_BlendFuncEnum source_alpha
        GPU_BlendFuncEnum dest_alpha
        GPU_BlendEqEnum color_equation
        GPU_BlendEqEnum alpha_equation

    ctypedef enum GPU_BlendPresetEnum:
        GPU_BLEND_NORMAL
        GPU_BLEND_PREMULTIPLIED_ALPHA
        GPU_BLEND_MULTIPLY
        GPU_BLEND_ADD
        GPU_BLEND_SUBTRACT
        GPU_BLEND_MOD_ALPHA
        GPU_BLEND_SET_ALPHA
        GPU_BLEND_SET
        GPU_BLEND_NORMAL_KEEP_ALPHA
        GPU_BLEND_NORMAL_ADD_ALPHA
        GPU_BLEND_NORMAL_FACTOR_ALPHA

    ctypedef enum GPU_FilterEnum:
        GPU_FILTER_NEAREST
        GPU_FILTER_LINEAR
        GPU_FILTER_LINEAR_MIPMAP

    ctypedef enum GPU_SnapEnum:
        GPU_SNAP_NONE
        GPU_SNAP_POSITION
        GPU_SNAP_DIMENSIONS
        GPU_SNAP_POSITION_AND_DIMENSIONS

    ctypedef enum GPU_WrapEnum:
        GPU_WRAP_NONE
        GPU_WRAP_REPEAT
        GPU_WRAP_MIRRORED

    ctypedef enum GPU_FormatEnum:
        GPU_FORMAT_LUMINANCE
        GPU_FORMAT_LUMINANCE_ALPHA
        GPU_FORMAT_RGB
        GPU_FORMAT_RGBA
        GPU_FORMAT_ALPHA
        GPU_FORMAT_RG
        GPU_FORMAT_YCbCr422
        GPU_FORMAT_YCbCr420P
        GPU_FORMAT_BGR
        GPU_FORMAT_BGRA
        GPU_FORMAT_ABGR

    ctypedef enum GPU_FileFormatEnum:
        GPU_FILE_AUTO
        GPU_FILE_PNG
        GPU_FILE_BMP
        GPU_FILE_TGA

    ctypedef struct GPU_Image:
        GPU_Renderer* renderer
        GPU_Target* context_target
        GPU_Target* target
        void* data

        Uint16 w, h
        GPU_FormatEnum format
        int num_layers
        int bytes_per_pixel
        Uint16 base_w, base_h
        Uint16 texture_w, texture_h

        float anchor_x
        float anchor_y

        SDL_Color color
        GPU_BlendMode blend_mode
        GPU_FilterEnum filter_mode
        GPU_SnapEnum snap_mode
        GPU_WrapEnum wrap_mode_x
        GPU_WrapEnum wrap_mode_y

        int refcount

        GPU_bool using_virtual_resolution
        GPU_bool has_mipmaps
        GPU_bool use_blending
        GPU_bool is_alias

    ctypedef uintptr_t GPU_TextureHandle

    ctypedef struct GPU_Camera:
        float x, y, z
        float angle
        float zoom_x, zoom_y
        float z_near, z_far
        GPU_bool use_centered_origin

    ctypedef struct GPU_ShaderBlock:
        int position_loc
        int texcoord_loc
        int color_loc
        int modelViewProjection_loc

    cdef enum:
        GPU_MODEL
        GPU_VIEW
        GPU_PROJECTION

    ctypedef struct GPU_MatrixStack:
        unsigned int storage_size
        unsigned int size
        float** matrix

    ctypedef struct GPU_Context:
        void* context
        GPU_Target* active_target
        GPU_ShaderBlock current_shader_block
        GPU_ShaderBlock default_textured_shader_block
        GPU_ShaderBlock default_untextured_shader_block
        Uint32 windowID
        int window_w
        int window_h
        int drawable_w
        int drawable_h
        int stored_window_w
        int stored_window_h
        Uint32 default_textured_vertex_shader_id
        Uint32 default_textured_fragment_shader_id
        Uint32 default_untextured_vertex_shader_id
        Uint32 default_untextured_fragment_shader_id
        Uint32 current_shader_program
        Uint32 default_textured_shader_program
        Uint32 default_untextured_shader_program
        GPU_BlendMode shapes_blend_mode
        float line_thickness
        int refcount
        void* data
        GPU_bool failed
        GPU_bool use_texturing
        GPU_bool shapes_use_blending

    ctypedef struct GPU_Target:
        GPU_Renderer* renderer
        GPU_Target* context_target
        GPU_Image* image
        void* data
        Uint16 w, h
        Uint16 base_w, base_h
        GPU_Rect clip_rect
        SDL_Color color
        GPU_Rect viewport
        int matrix_mode
        GPU_MatrixStack projection_matrix
        GPU_MatrixStack view_matrix
        GPU_MatrixStack model_matrix
        GPU_Camera camera
        GPU_bool using_virtual_resolution
        GPU_bool use_clip_rect
        GPU_bool use_color
        GPU_bool use_camera
        GPU_ComparisonEnum depth_function
        GPU_Context* context
        int refcount
        GPU_bool use_depth_test
        GPU_bool use_depth_write
        GPU_bool is_alias

    ctypedef Uint32 GPU_FeatureEnum

    cdef enum:
        GPU_FEATURE_NON_POWER_OF_TWO
        GPU_FEATURE_RENDER_TARGETS
        GPU_FEATURE_BLEND_EQUATIONS
        GPU_FEATURE_BLEND_FUNC_SEPARATE
        GPU_FEATURE_BLEND_EQUATIONS_SEPARATE
        GPU_FEATURE_GL_BGR
        GPU_FEATURE_GL_BGRA
        GPU_FEATURE_GL_ABGR
        GPU_FEATURE_VERTEX_SHADER
        GPU_FEATURE_FRAGMENT_SHADER
        GPU_FEATURE_PIXEL_SHADER
        GPU_FEATURE_GEOMETRY_SHADER
        GPU_FEATURE_WRAP_REPEAT_MIRRORED
        GPU_FEATURE_CORE_FRAMEBUFFER_OBJECTS
        GPU_FEATURE_ALL_BASE
        GPU_FEATURE_ALL_BLEND_PRESETS
        GPU_FEATURE_ALL_GL_FORMATS
        GPU_FEATURE_BASIC_SHADERS
        GPU_FEATURE_ALL_SHADERS

    ctypedef Uint32 GPU_WindowFlagEnum

    ctypedef Uint32 GPU_InitFlagEnum

    cdef enum:
        GPU_INIT_ENABLE_VSYNC
        GPU_INIT_DISABLE_VSYNC
        GPU_INIT_DISABLE_DOUBLE_BUFFER
        GPU_INIT_DISABLE_AUTO_VIRTUAL_RESOLUTION
        GPU_INIT_REQUEST_COMPATIBILITY_PROFILE
        GPU_INIT_USE_ROW_BY_ROW_TEXTURE_UPLOAD_FALLBACK
        GPU_INIT_USE_COPY_TEXTURE_UPLOAD_FALLBACK
        GPU_DEFAULT_INIT_FLAGS

    cdef enum:
        GPU_NONE

    ctypedef Uint32 GPU_PrimitiveEnum

    cdef enum:
        GPU_POINTS
        GPU_LINES
        GPU_LINE_LOOP
        GPU_LINE_STRIP
        GPU_TRIANGLES
        GPU_TRIANGLE_STRIP
        GPU_TRIANGLE_FAN

    ctypedef Uint32 GPU_BatchFlagEnum

    cdef enum:
        GPU_BATCH_XY
        GPU_BATCH_XYZ
        GPU_BATCH_ST
        GPU_BATCH_RGB
        GPU_BATCH_RGBA
        GPU_BATCH_RGB8
        GPU_BATCH_RGBA8
        GPU_BATCH_XY_ST
        GPU_BATCH_XYZ_ST
        GPU_BATCH_XY_RGB
        GPU_BATCH_XYZ_RGB
        GPU_BATCH_XY_RGBA
        GPU_BATCH_XYZ_RGBA
        GPU_BATCH_XY_ST_RGBA
        GPU_BATCH_XYZ_ST_RGBA
        GPU_BATCH_XY_RGB8
        GPU_BATCH_XYZ_RGB8
        GPU_BATCH_XY_RGBA8
        GPU_BATCH_XYZ_RGBA8
        GPU_BATCH_XY_ST_RGBA8
        GPU_BATCH_XYZ_ST_RGBA8

    ctypedef Uint32 GPU_FlipEnum

    cdef enum:
        GPU_FLIP_NONE
        GPU_FLIP_HORIZONTAL
        GPU_FLIP_VERTICAL

    ctypedef Uint32 GPU_TypeEnum

    cdef enum:
        GPU_TYPE_BYTE
        GPU_TYPE_UNSIGNED_BYTE
        GPU_TYPE_SHORT
        GPU_TYPE_UNSIGNED_SHORT
        GPU_TYPE_INT
        GPU_TYPE_UNSIGNED_INT
        GPU_TYPE_FLOAT
        GPU_TYPE_DOUBLE

    ctypedef enum GPU_ShaderEnum:
        GPU_VERTEX_SHADER
        GPU_FRAGMENT_SHADER
        GPU_PIXEL_SHADER
        GPU_GEOMETRY_SHADER

    ctypedef enum GPU_ShaderLanguageEnum:
        GPU_LANGUAGE_NONE
        GPU_LANGUAGE_ARB_ASSEMBLY
        GPU_LANGUAGE_GLSL
        GPU_LANGUAGE_GLSLES
        GPU_LANGUAGE_HLSL
        GPU_LANGUAGE_CG

    ctypedef struct GPU_AttributeFormat:
        int num_elems_per_value
        GPU_TypeEnum type
        int stride_bytes
        int offset_bytes
        GPU_bool is_per_sprite
        GPU_bool normalize

    ctypedef struct GPU_Attribute:
        void* values
        GPU_AttributeFormat format
        int location

    ctypedef struct GPU_AttributeSource:
        void* next_value
        void* per_vertex_storage
        int num_values
        int per_vertex_storage_stride_bytes
        int per_vertex_storage_offset_bytes
        int per_vertex_storage_size
        GPU_Attribute attribute
        GPU_bool enabled

    ctypedef enum GPU_ErrorEnum:
        GPU_ERROR_NONE
        GPU_ERROR_BACKEND_ERROR
        GPU_ERROR_DATA_ERROR
        GPU_ERROR_USER_ERROR
        GPU_ERROR_UNSUPPORTED_FUNCTION
        GPU_ERROR_NULL_ARGUMENT
        GPU_ERROR_FILE_NOT_FOUND

    ctypedef struct GPU_ErrorObject:
        char* function
        char* details
        GPU_ErrorEnum error

    ctypedef enum GPU_DebugLevelEnum:
        GPU_DEBUG_LEVEL_0
        GPU_DEBUG_LEVEL_1
        GPU_DEBUG_LEVEL_2
        GPU_DEBUG_LEVEL_3
        GPU_DEBUG_LEVEL_MAX

    ctypedef enum GPU_LogLevelEnum:
        GPU_LOG_INFO
        GPU_LOG_WARNING
        GPU_LOG_ERROR

    ctypedef struct GPU_RendererImpl:
        pass

    ctypedef struct GPU_Renderer:
        GPU_RendererID id
        GPU_RendererID requested_id
        GPU_WindowFlagEnum SDL_init_flags
        GPU_InitFlagEnum GPU_init_flags
        GPU_ShaderLanguageEnum shader_language
        int min_shader_version
        int max_shader_version
        GPU_FeatureEnum enabled_features
        GPU_Target* current_context_target
        float default_image_anchor_x
        float default_image_anchor_y
        GPU_RendererImpl* impl
        GPU_bool coordinate_mode

    # Initialization
    SDL_version GPU_GetCompiledVersion()
    SDL_version GPU_GetLinkedVersion()
    void GPU_SetInitWindow(Uint32 windowID)
    Uint32 GPU_GetInitWindow()
    void GPU_SetPreInitFlags(GPU_InitFlagEnum GPU_flags)
    GPU_InitFlagEnum GPU_GetPreInitFlags()
    void GPU_SetRequiredFeatures(GPU_FeatureEnum features)
    GPU_FeatureEnum GPU_GetRequiredFeatures()
    void GPU_GetDefaultRendererOrder(int* order_size, GPU_RendererID* order)
    void GPU_GetRendererOrder(int* order_size, GPU_RendererID* order)
    void GPU_SetRendererOrder(int order_size, GPU_RendererID* order)
    GPU_Target* GPU_Init(Uint16 w, Uint16 h, GPU_WindowFlagEnum SDL_flags)
    GPU_Target* GPU_InitRenderer(GPU_RendererEnum renderer_enum, Uint16 w, Uint16 h, GPU_WindowFlagEnum SDL_flags)
    GPU_Target* GPU_InitRendererByID(GPU_RendererID renderer_request, Uint16 w, Uint16 h, GPU_WindowFlagEnum SDL_flags)
    GPU_bool GPU_IsFeatureEnabled(GPU_FeatureEnum feature)
    void GPU_CloseCurrentRenderer()
    void GPU_Quit()

    # Logging
    void GPU_SetDebugLevel(GPU_DebugLevelEnum level)
    GPU_DebugLevelEnum GPU_GetDebugLevel()
    void GPU_LogInfo(const char* format, ...)
    void GPU_LogWarning(const char* format, ...)
    void GPU_LogError(const char* format, ...)
    void GPU_SetLogCallback(int (*callback)(GPU_LogLevelEnum log_level, const char* format, va_list args))
    void GPU_PushErrorCode(const char* function, GPU_ErrorEnum error, const char* details, ...)
    GPU_ErrorObject GPU_PopErrorCode()
    const char* GPU_GetErrorString(GPU_ErrorEnum error)
    void GPU_SetErrorQueueMax(unsigned int max)

    # RendererSetup
    GPU_RendererID GPU_MakeRendererID(const char* name, GPU_RendererEnum renderer, int major_version, int minor_version)
    GPU_RendererID GPU_GetRendererID(GPU_RendererEnum renderer)
    int GPU_GetNumRegisteredRenderers()
    void GPU_GetRegisteredRendererList(GPU_RendererID* renderers_array)
    void GPU_RegisterRenderer(GPU_RendererID id, GPU_Renderer* (*create_renderer)(GPU_RendererID request), void (*free_renderer)(GPU_Renderer* renderer))

    # RendererControls
    GPU_RendererEnum GPU_ReserveNextRendererEnum()
    int GPU_GetNumActiveRenderers()
    void GPU_GetActiveRendererList(GPU_RendererID* renderers_array)
    GPU_Renderer* GPU_GetCurrentRenderer()
    void GPU_SetCurrentRenderer(GPU_RendererID id)
    GPU_Renderer* GPU_GetRenderer(GPU_RendererID id)
    void GPU_FreeRenderer(GPU_Renderer* renderer)
    void GPU_ResetRendererState()
    void GPU_SetCoordinateMode(GPU_bool use_math_coords)
    GPU_bool GPU_GetCoordinateMode()
    void GPU_SetDefaultAnchor(float anchor_x, float anchor_y)
    void GPU_GetDefaultAnchor(float* anchor_x, float* anchor_y)

    # ContextControls
    GPU_Target* GPU_GetContextTarget()
    GPU_Target* GPU_GetWindowTarget(Uint32 windowID)
    GPU_Target* GPU_CreateTargetFromWindow(Uint32 windowID)
    void GPU_MakeCurrent(GPU_Target* target, Uint32 windowID)
    GPU_bool GPU_SetWindowResolution(Uint16 w, Uint16 h)
    GPU_bool GPU_SetFullscreen(GPU_bool enable_fullscreen, GPU_bool use_desktop_resolution)
    GPU_bool GPU_GetFullscreen()
    GPU_Target* GPU_GetActiveTarget()
    GPU_bool GPU_SetActiveTarget(GPU_Target* target)
    void GPU_SetShapeBlending(GPU_bool enable)
    GPU_BlendMode GPU_GetBlendModeFromPreset(GPU_BlendPresetEnum preset)
    void GPU_SetShapeBlendFunction(GPU_BlendFuncEnum source_color, GPU_BlendFuncEnum dest_color, GPU_BlendFuncEnum source_alpha, GPU_BlendFuncEnum dest_alpha)
    void GPU_SetShapeBlendEquation(GPU_BlendEqEnum color_equation, GPU_BlendEqEnum alpha_equation)
    void GPU_SetShapeBlendMode(GPU_BlendPresetEnum mode)
    float GPU_SetLineThickness(float thickness)
    float GPU_GetLineThickness()

    # TargetControls
    GPU_Target* GPU_CreateAliasTarget(GPU_Target* target)
    GPU_Target* GPU_LoadTarget(GPU_Image* image)
    GPU_Target* GPU_GetTarget(GPU_Image* image)
    void GPU_FreeTarget(GPU_Target* target)
    void GPU_SetVirtualResolution(GPU_Target* target, Uint16 w, Uint16 h)
    void GPU_GetVirtualResolution(GPU_Target* target, Uint16* w, Uint16* h)
    void GPU_GetVirtualCoords(GPU_Target* target, float* x, float* y, float displayX, float displayY)
    void GPU_UnsetVirtualResolution(GPU_Target* target)
    GPU_Rect GPU_MakeRect(float x, float y, float w, float h)
    SDL_Color GPU_MakeColor(Uint8 r, Uint8 g, Uint8 b, Uint8 a)
    void GPU_SetViewport(GPU_Target* target, GPU_Rect viewport)
    void GPU_UnsetViewport(GPU_Target* target)
    GPU_Camera GPU_GetDefaultCamera()
    GPU_Camera GPU_GetCamera(GPU_Target* target)
    GPU_Camera GPU_SetCamera(GPU_Target* target, GPU_Camera* cam)
    void GPU_EnableCamera(GPU_Target* target, GPU_bool use_camera)
    GPU_bool GPU_IsCameraEnabled(GPU_Target* target)
    GPU_bool GPU_AddDepthBuffer(GPU_Target* target)
    void GPU_SetDepthTest(GPU_Target* target, GPU_bool enable)
    void GPU_SetDepthWrite(GPU_Target* target, GPU_bool enable)
    void GPU_SetDepthFunction(GPU_Target* target, GPU_ComparisonEnum compare_operation)
    SDL_Color GPU_GetPixel(GPU_Target* target, Sint16 x, Sint16 y)
    GPU_Rect GPU_SetClipRect(GPU_Target* target, GPU_Rect rect)
    GPU_Rect GPU_SetClip(GPU_Target* target, Sint16 x, Sint16 y, Uint16 w, Uint16 h)
    void GPU_UnsetClip(GPU_Target* target)
    GPU_bool GPU_IntersectRect(GPU_Rect A, GPU_Rect B, GPU_Rect* result)
    GPU_bool GPU_IntersectClipRect(GPU_Target* target, GPU_Rect B, GPU_Rect* result)
    void GPU_SetTargetColor(GPU_Target* target, SDL_Color color)
    void GPU_SetTargetRGB(GPU_Target* target, Uint8 r, Uint8 g, Uint8 b)
    void GPU_SetTargetRGBA(GPU_Target* target, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
    void GPU_UnsetTargetColor(GPU_Target* target)

    # SurfaceControls
    SDL_Surface* GPU_LoadSurface(const char* filename)
    SDL_Surface* GPU_LoadSurface_RW(SDL_RWops* rwops, GPU_bool free_rwops)
    GPU_bool GPU_SaveSurface(SDL_Surface* surface, const char* filename, GPU_FileFormatEnum format)
    GPU_bool GPU_SaveSurface_RW(SDL_Surface* surface, SDL_RWops* rwops, GPU_bool free_rwops, GPU_FileFormatEnum format)

    # ImageControls
    GPU_Image* GPU_CreateImage(Uint16 w, Uint16 h, GPU_FormatEnum format)
    GPU_Image* GPU_CreateImageUsingTexture(GPU_TextureHandle handle, GPU_bool take_ownership)
    GPU_Image* GPU_LoadImage(const char* filename)
    GPU_Image* GPU_LoadImage_RW(SDL_RWops* rwops, GPU_bool free_rwops)
    GPU_Image* GPU_CreateAliasImage(GPU_Image* image)
    GPU_Image* GPU_CopyImage(GPU_Image* image)
    void GPU_FreeImage(GPU_Image* image)
    void GPU_SetImageVirtualResolution(GPU_Image* image, Uint16 w, Uint16 h)
    void GPU_UnsetImageVirtualResolution(GPU_Image* image)
    void GPU_UpdateImage(GPU_Image* image, const GPU_Rect* image_rect, SDL_Surface* surface, const GPU_Rect* surface_rect)
    void GPU_UpdateImageBytes(GPU_Image* image, const GPU_Rect* image_rect, const unsigned char* bytes, int bytes_per_row)
    GPU_bool GPU_ReplaceImage(GPU_Image* image, SDL_Surface* surface, const GPU_Rect* surface_rect)
    GPU_bool GPU_SaveImage(GPU_Image* image, const char* filename, GPU_FileFormatEnum format)
    GPU_bool GPU_SaveImage_RW(GPU_Image* image, SDL_RWops* rwops, GPU_bool free_rwops, GPU_FileFormatEnum format)
    void GPU_GenerateMipmaps(GPU_Image* image)
    void GPU_SetColor(GPU_Image* image, SDL_Color color)
    void GPU_SetRGB(GPU_Image* image, Uint8 r, Uint8 g, Uint8 b)
    void GPU_SetRGBA(GPU_Image* image, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
    void GPU_UnsetColor(GPU_Image* image)
    GPU_bool GPU_GetBlending(GPU_Image* image)
    void GPU_SetBlending(GPU_Image* image, GPU_bool enable)
    void GPU_SetBlendFunction(GPU_Image* image, GPU_BlendFuncEnum source_color, GPU_BlendFuncEnum dest_color, GPU_BlendFuncEnum source_alpha, GPU_BlendFuncEnum dest_alpha)
    void GPU_SetBlendEquation(GPU_Image* image, GPU_BlendEqEnum color_equation, GPU_BlendEqEnum alpha_equation)
    void GPU_SetBlendMode(GPU_Image* image, GPU_BlendPresetEnum mode)
    void GPU_SetImageFilter(GPU_Image* image, GPU_FilterEnum filter)
    void GPU_SetAnchor(GPU_Image* image, float anchor_x, float anchor_y)
    void GPU_GetAnchor(GPU_Image* image, float* anchor_x, float* anchor_y)
    GPU_SnapEnum GPU_GetSnapMode(GPU_Image* image)
    void GPU_SetSnapMode(GPU_Image* image, GPU_SnapEnum mode)
    void GPU_SetWrapMode(GPU_Image* image, GPU_WrapEnum wrap_mode_x, GPU_WrapEnum wrap_mode_y)
    GPU_TextureHandle GPU_GetTextureHandle(GPU_Image* image)

    # Conversions
    GPU_Image* GPU_CopyImageFromSurface(SDL_Surface* surface)
    GPU_Image* GPU_CopyImageFromTarget(GPU_Target* target)
    SDL_Surface* GPU_CopySurfaceFromTarget(GPU_Target* target)
    SDL_Surface* GPU_CopySurfaceFromImage(GPU_Image* image)

    # Matrix
    # - Basic vector operations (3D)
    float GPU_VectorLength(const float* vec3)
    void GPU_VectorNormalize(float* vec3)
    float GPU_VectorDot(const float* A, const float* B)
    void GPU_VectorCross(float* result, const float* A, const float* B)
    void GPU_VectorCopy(float* result, const float* A)
    void GPU_VectorApplyMatrix(float* vec3, const float* matrix_4x4)
    void GPU_Vector4ApplyMatrix(float* vec4, const float* matrix_4x4)
    # - Basic matrix operations (4x4)
    void GPU_MatrixCopy(float* result, const float* A)
    void GPU_MatrixIdentity(float* result)
    void GPU_MatrixOrtho(float* result, float left, float right, float bottom, float top, float z_near, float z_far)
    void GPU_MatrixFrustum(float* result, float left, float right, float bottom, float top, float z_near, float z_far)
    void GPU_MatrixPerspective(float* result, float fovy, float aspect, float z_near, float z_far)
    void GPU_MatrixLookAt(float* matrix, float eye_x, float eye_y, float eye_z, float target_x, float target_y, float target_z, float up_x, float up_y, float up_z)
    void GPU_MatrixTranslate(float* result, float x, float y, float z)
    void GPU_MatrixScale(float* result, float sx, float sy, float sz)
    void GPU_MatrixRotate(float* result, float degrees, float x, float y, float z)
    void GPU_MatrixMultiply(float* result, const float* A, const float* B)
    void GPU_MultiplyAndAssign(float* result, const float* B)
    # - Matrix stack accessors
    const char* GPU_GetMatrixString(const float* A)
    float* GPU_GetCurrentMatrix()
    float* GPU_GetTopMatrix(GPU_MatrixStack* stack)
    float* GPU_GetModel()
    float* GPU_GetView()
    float* GPU_GetProjection()
    void GPU_GetModelViewProjection(float* result)
    # - Matrix stack manipulators
    GPU_MatrixStack* GPU_CreateMatrixStack()
    void GPU_FreeMatrixStack(GPU_MatrixStack* stack)
    void GPU_InitMatrixStack(GPU_MatrixStack* stack)
    void GPU_CopyMatrixStack(const GPU_MatrixStack* source, GPU_MatrixStack* dest)
    void GPU_ClearMatrixStack(GPU_MatrixStack* stack)
    void GPU_ResetProjection(GPU_Target* target)
    void GPU_MatrixMode(GPU_Target* target, int matrix_mode)
    void GPU_SetProjection(const float* A)
    void GPU_SetView(const float* A)
    void GPU_SetModel(const float* A)
    void GPU_SetProjectionFromStack(GPU_MatrixStack* stack)
    void GPU_SetViewFromStack(GPU_MatrixStack* stack)
    void GPU_SetModelFromStack(GPU_MatrixStack* stack)
    void GPU_PushMatrix()
    void GPU_PopMatrix()
    void GPU_LoadIdentity()
    void GPU_LoadMatrix(const float* matrix4x4)
    void GPU_Ortho(float left, float right, float bottom, float top, float z_near, float z_far)
    void GPU_Frustum(float left, float right, float bottom, float top, float z_near, float z_far)
    void GPU_Perspective(float fovy, float aspect, float z_near, float z_far)
    void GPU_LookAt(float eye_x, float eye_y, float eye_z, float target_x, float target_y, float target_z, float up_x, float up_y, float up_z)
    void GPU_Translate(float x, float y, float z)
    void GPU_Scale(float sx, float sy, float sz)
    void GPU_Rotate(float degrees, float x, float y, float z)
    void GPU_MultMatrix(const float* matrix4x4)

    # Rendering
    void GPU_Clear(GPU_Target* target)
    void GPU_ClearColor(GPU_Target* target, SDL_Color color)
    void GPU_ClearRGB(GPU_Target* target, Uint8 r, Uint8 g, Uint8 b)
    void GPU_ClearRGBA(GPU_Target* target, Uint8 r, Uint8 g, Uint8 b, Uint8 a)
    void GPU_Blit(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, float x, float y)
    void GPU_BlitRotate(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, float x, float y, float degrees)
    void GPU_BlitScale(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, float x, float y, float scaleX, float scaleY)
    void GPU_BlitTransform(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, float x, float y, float degrees, float scaleX, float scaleY)
    void GPU_BlitTransformX(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, float x, float y, float pivot_x, float pivot_y, float degrees, float scaleX, float scaleY)
    void GPU_BlitRect(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, GPU_Rect* dest_rect)
    void GPU_BlitRectX(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, GPU_Rect* dest_rect, float degrees, float pivot_x, float pivot_y, GPU_FlipEnum flip_direction)
    void GPU_TriangleBatch(GPU_Image* image, GPU_Target* target, unsigned short num_vertices, float* values, unsigned int num_indices, unsigned short* indices, GPU_BatchFlagEnum flags)
    void GPU_TriangleBatchX(GPU_Image* image, GPU_Target* target, unsigned short num_vertices, void* values, unsigned int num_indices, unsigned short* indices, GPU_BatchFlagEnum flags)
    void GPU_PrimitiveBatch(GPU_Image* image, GPU_Target* target, GPU_PrimitiveEnum primitive_type, unsigned short num_vertices, float* values, unsigned int num_indices, unsigned short* indices, GPU_BatchFlagEnum flags)
    void GPU_PrimitiveBatchV(GPU_Image* image, GPU_Target* target, GPU_PrimitiveEnum primitive_type, unsigned short num_vertices, void* values, unsigned int num_indices, unsigned short* indices, GPU_BatchFlagEnum flags)
    void GPU_FlushBlitBuffer()
    void GPU_Flip(GPU_Target* target)

    # Shapes
    void GPU_Pixel(GPU_Target* target, float x, float y, SDL_Color color)
    void GPU_Line(GPU_Target* target, float x1, float y1, float x2, float y2, SDL_Color color)
    void GPU_Arc(GPU_Target* target, float x, float y, float radius, float start_angle, float end_angle, SDL_Color color)
    void GPU_ArcFilled(GPU_Target* target, float x, float y, float radius, float start_angle, float end_angle, SDL_Color color)
    void GPU_Circle(GPU_Target* target, float x, float y, float radius, SDL_Color color)
    void GPU_CircleFilled(GPU_Target* target, float x, float y, float radius, SDL_Color color)
    void GPU_Ellipse(GPU_Target* target, float x, float y, float rx, float ry, float degrees, SDL_Color color)
    void GPU_EllipseFilled(GPU_Target* target, float x, float y, float rx, float ry, float degrees, SDL_Color color)
    void GPU_Sector(GPU_Target* target, float x, float y, float inner_radius, float outer_radius, float start_angle, float end_angle, SDL_Color color)
    void GPU_SectorFilled(GPU_Target* target, float x, float y, float inner_radius, float outer_radius, float start_angle, float end_angle, SDL_Color color)
    void GPU_Tri(GPU_Target* target, float x1, float y1, float x2, float y2, float x3, float y3, SDL_Color color)
    void GPU_TriFilled(GPU_Target* target, float x1, float y1, float x2, float y2, float x3, float y3, SDL_Color color)
    void GPU_Rectangle(GPU_Target* target, float x1, float y1, float x2, float y2, SDL_Color color)
    void GPU_Rectangle2(GPU_Target* target, GPU_Rect rect, SDL_Color color)
    void GPU_RectangleFilled(GPU_Target* target, float x1, float y1, float x2, float y2, SDL_Color color)
    void GPU_RectangleFilled2(GPU_Target* target, GPU_Rect rect, SDL_Color color)
    void GPU_RectangleRound(GPU_Target* target, float x1, float y1, float x2, float y2, float radius, SDL_Color color)
    void GPU_RectangleRound2(GPU_Target* target, GPU_Rect rect, float radius, SDL_Color color)
    void GPU_RectangleRoundFilled(GPU_Target* target, float x1, float y1, float x2, float y2, float radius, SDL_Color color)
    void GPU_RectangleRoundFilled2(GPU_Target* target, GPU_Rect rect, float radius, SDL_Color color)
    void GPU_Polygon(GPU_Target* target, unsigned int num_vertices, float* vertices, SDL_Color color)
    void GPU_Polyline(GPU_Target* target, unsigned int num_vertices, float* vertices, SDL_Color color, GPU_bool close_loop)
    void GPU_PolygonFilled(GPU_Target* target, unsigned int num_vertices, float* vertices, SDL_Color color)

    # ShaderInterface
    Uint32 GPU_CreateShaderProgram()
    void GPU_FreeShaderProgram(Uint32 program_object)
    Uint32 GPU_CompileShader_RW(GPU_ShaderEnum shader_type, SDL_RWops* shader_source, GPU_bool free_rwops)
    Uint32 GPU_CompileShader(GPU_ShaderEnum shader_type, const char* shader_source)
    Uint32 GPU_LoadShader(GPU_ShaderEnum shader_type, const char* filename)
    Uint32 GPU_LinkShaders(Uint32 shader_object1, Uint32 shader_object2)
    Uint32 GPU_LinkManyShaders(Uint32 *shader_objects, int count)
    void GPU_FreeShader(Uint32 shader_object)
    void GPU_AttachShader(Uint32 program_object, Uint32 shader_object)
    void GPU_DetachShader(Uint32 program_object, Uint32 shader_object)
    GPU_bool GPU_LinkShaderProgram(Uint32 program_object)
    Uint32 GPU_GetCurrentShaderProgram()
    GPU_bool GPU_IsDefaultShaderProgram(Uint32 program_object)
    void GPU_ActivateShaderProgram(Uint32 program_object, GPU_ShaderBlock* block)
    void GPU_DeactivateShaderProgram()
    const char* GPU_GetShaderMessage()
    int GPU_GetAttributeLocation(Uint32 program_object, const char* attrib_name)
    GPU_AttributeFormat GPU_MakeAttributeFormat(int num_elems_per_vertex, GPU_TypeEnum type, GPU_bool normalize, int stride_bytes, int offset_bytes)
    GPU_Attribute GPU_MakeAttribute(int location, void* values, GPU_AttributeFormat format)
    int GPU_GetUniformLocation(Uint32 program_object, const char* uniform_name)
    GPU_ShaderBlock GPU_LoadShaderBlock(Uint32 program_object, const char* position_name, const char* texcoord_name, const char* color_name, const char* modelViewMatrix_name)
    void GPU_SetShaderBlock(GPU_ShaderBlock block)
    GPU_ShaderBlock GPU_GetShaderBlock()
    void GPU_SetShaderImage(GPU_Image* image, int location, int image_unit)
    void GPU_GetUniformiv(Uint32 program_object, int location, int* values)
    void GPU_SetUniformi(int location, int value)
    void GPU_SetUniformiv(int location, int num_elements_per_value, int num_values, int* values)
    void GPU_GetUniformuiv(Uint32 program_object, int location, unsigned int* values)
    void GPU_SetUniformui(int location, unsigned int value)
    void GPU_SetUniformuiv(int location, int num_elements_per_value, int num_values, unsigned int* values)
    void GPU_GetUniformfv(Uint32 program_object, int location, float* values)
    void GPU_SetUniformf(int location, float value)
    void GPU_SetUniformfv(int location, int num_elements_per_value, int num_values, float* values)
    void GPU_GetUniformMatrixfv(Uint32 program_object, int location, float* values)
    void GPU_SetUniformMatrixfv(int location, int num_matrices, int num_rows, int num_columns, GPU_bool transpose, float* values)
    void GPU_SetAttributef(int location, float value)
    void GPU_SetAttributei(int location, int value)
    void GPU_SetAttributeui(int location, unsigned int value)
    void GPU_SetAttributefv(int location, int num_elements, float* value)
    void GPU_SetAttributeiv(int location, int num_elements, int* value)
    void GPU_SetAttributeuiv(int location, int num_elements, unsigned int* value)
    void GPU_SetAttributeSource(int num_values, GPU_Attribute source)
