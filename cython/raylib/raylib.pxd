# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libcpp cimport bool

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

cdef extern from "raylib.h":

    cdef struct Vector2:
        float x
        float y

    cdef struct Vector3:
        float x
        float y
        float z

    cdef struct Vector4:
        float x
        float y
        float z
        float w

    ctypedef Vector4 Quaternion

    cdef struct Matrix:
        float m0
        float m4
        float m8
        float m12
        float m1
        float m5
        float m9
        float m13
        float m2
        float m6
        float m10
        float m14
        float m3
        float m7
        float m11
        float m15

    cdef struct Color:
        unsigned char r
        unsigned char g
        unsigned char b
        unsigned char a

    cdef const Color LIGHTGRAY  "LIGHTGRAY"
    cdef const Color GRAY       "GRAY"
    cdef const Color DARKGRAY   "DARKGRAY"
    cdef const Color YELLOW     "YELLOW"
    cdef const Color GOLD       "GOLD"
    cdef const Color ORANGE     "ORANGE"
    cdef const Color PINK       "PINK"
    cdef const Color RED        "RED"
    cdef const Color MAROON     "MAROON"
    cdef const Color GREEN      "GREEN"
    cdef const Color LIME       "LIME"
    cdef const Color DARKGREEN  "DARKGREEN"
    cdef const Color SKYBLUE    "SKYBLUE"
    cdef const Color BLUE       "BLUE"
    cdef const Color DARKBLUE   "DARKBLUE"
    cdef const Color PURPLE     "PURPLE"
    cdef const Color VIOLET     "VIOLET"
    cdef const Color DARKPURPLE "DARKPURPLE"
    cdef const Color BEIGE      "BEIGE"
    cdef const Color BROWN      "BROWN"
    cdef const Color DARKBROWN  "DARKBROWN"

    cdef const Color WHITE      "WHITE"
    cdef const Color BLACK      "BLACK"
    cdef const Color BLANK      "BLANK"
    cdef const Color MAGENTA    "MAGENTA"
    cdef const Color RAYWHITE   "RAYWHITE"

    cdef struct Rectangle:
        float x
        float y
        float width
        float height

    cdef struct Image:
        void* data
        int width
        int height
        int mipmaps
        int format

    cdef struct Texture:
        unsigned int id
        int width
        int height
        int mipmaps
        int format

    ctypedef Texture Texture2D

    ctypedef Texture TextureCubemap

    cdef struct RenderTexture:
        unsigned int id
        Texture texture
        Texture depth

    ctypedef RenderTexture RenderTexture2D

    cdef struct NPatchInfo:
        Rectangle source
        int left
        int top
        int right
        int bottom
        int layout

    cdef struct GlyphInfo:
        int value
        int offsetX
        int offsetY
        int advanceX
        Image image

    cdef struct Font:
        int baseSize
        int glyphCount
        int glyphPadding
        Texture2D texture
        Rectangle* recs
        GlyphInfo* glyphs

    cdef struct Camera3D:
        Vector3 position
        Vector3 target
        Vector3 up
        float fovy
        int projection

    ctypedef Camera3D Camera

    cdef struct Camera2D:
        Vector2 offset
        Vector2 target
        float rotation
        float zoom

    cdef struct Mesh:
        int vertexCount
        int triangleCount
        float* vertices
        float* texcoords
        float* texcoords2
        float* normals
        float* tangents
        unsigned char* colors
        unsigned short* indices
        float* animVertices
        float* animNormals
        unsigned char* boneIds
        float* boneWeights
        unsigned int vaoId
        unsigned int* vboId

    cdef struct Shader:
        unsigned int id
        int* locs

    cdef struct MaterialMap:
        Texture2D texture
        Color color
        float value

    cdef struct Material:
        Shader shader
        MaterialMap* maps
        float params[4]

    cdef struct Transform:
        Vector3 translation
        Quaternion rotation
        Vector3 scale

    cdef struct BoneInfo:
        char name[32]
        int parent

    cdef struct Model:
        Matrix transform
        int meshCount
        int materialCount
        Mesh* meshes
        Material* materials
        int* meshMaterial
        int boneCount
        BoneInfo* bones
        Transform* bindPose

    cdef struct ModelAnimation:
        int boneCount
        int frameCount
        BoneInfo* bones
        Transform** framePoses

    cdef struct Ray:
        Vector3 position
        Vector3 direction

    cdef struct RayCollision:
        bool hit
        float distance
        Vector3 point
        Vector3 normal

    cdef struct BoundingBox:
        Vector3 min
        Vector3 max

    cdef struct Wave:
        unsigned int frameCount
        unsigned int sampleRate
        unsigned int sampleSize
        unsigned int channels
        void* data

    cdef struct rAudioBuffer:
        pass

    cdef struct rAudioProcessor:
        pass

    cdef struct AudioStream:
        rAudioBuffer* buffer
        rAudioProcessor* processor
        unsigned int sampleRate
        unsigned int sampleSize
        unsigned int channels

    cdef struct Sound:
        AudioStream stream
        unsigned int frameCount

    cdef struct Music:
        AudioStream stream
        unsigned int frameCount
        bool looping
        int ctxType
        void* ctxData

    cdef struct VrDeviceInfo:
        int hResolution
        int vResolution
        float hScreenSize
        float vScreenSize
        float vScreenCenter
        float eyeToScreenDistance
        float lensSeparationDistance
        float interpupillaryDistance
        float lensDistortionValues[4]
        float chromaAbCorrection[4]

    cdef struct VrStereoConfig:
        Matrix projection[2]
        Matrix viewOffset[2]
        float leftLensCenter[2]
        float rightLensCenter[2]
        float leftScreenCenter[2]
        float rightScreenCenter[2]
        float scale[2]
        float scaleIn[2]

    cdef struct FilePathList:
        unsigned int capacity
        unsigned int count
        char** paths

    ctypedef enum ConfigFlags:
        FLAG_VSYNC_HINT
        FLAG_FULLSCREEN_MODE
        FLAG_WINDOW_RESIZABLE
        FLAG_WINDOW_UNDECORATED
        FLAG_WINDOW_HIDDEN
        FLAG_WINDOW_MINIMIZED
        FLAG_WINDOW_MAXIMIZED
        FLAG_WINDOW_UNFOCUSED
        FLAG_WINDOW_TOPMOST
        FLAG_WINDOW_ALWAYS_RUN
        FLAG_WINDOW_TRANSPARENT
        FLAG_WINDOW_HIGHDPI
        FLAG_WINDOW_MOUSE_PASSTHROUGH
        FLAG_MSAA_4X_HINT
        FLAG_INTERLACED_HINT

    ctypedef enum TraceLogLevel:
        LOG_ALL
        LOG_TRACE
        LOG_DEBUG
        LOG_INFO
        LOG_WARNING
        LOG_ERROR
        LOG_FATAL
        LOG_NONE

    ctypedef enum KeyboardKey:
        KEY_NULL
        KEY_APOSTROPHE
        KEY_COMMA
        KEY_MINUS
        KEY_PERIOD
        KEY_SLASH
        KEY_ZERO
        KEY_ONE
        KEY_TWO
        KEY_THREE
        KEY_FOUR
        KEY_FIVE
        KEY_SIX
        KEY_SEVEN
        KEY_EIGHT
        KEY_NINE
        KEY_SEMICOLON
        KEY_EQUAL
        KEY_A
        KEY_B
        KEY_C
        KEY_D
        KEY_E
        KEY_F
        KEY_G
        KEY_H
        KEY_I
        KEY_J
        KEY_K
        KEY_L
        KEY_M
        KEY_N
        KEY_O
        KEY_P
        KEY_Q
        KEY_R
        KEY_S
        KEY_T
        KEY_U
        KEY_V
        KEY_W
        KEY_X
        KEY_Y
        KEY_Z
        KEY_LEFT_BRACKET
        KEY_BACKSLASH
        KEY_RIGHT_BRACKET
        KEY_GRAVE
        KEY_SPACE
        KEY_ESCAPE
        KEY_ENTER
        KEY_TAB
        KEY_BACKSPACE
        KEY_INSERT
        KEY_DELETE
        KEY_RIGHT
        KEY_LEFT
        KEY_DOWN
        KEY_UP
        KEY_PAGE_UP
        KEY_PAGE_DOWN
        KEY_HOME
        KEY_END
        KEY_CAPS_LOCK
        KEY_SCROLL_LOCK
        KEY_NUM_LOCK
        KEY_PRINT_SCREEN
        KEY_PAUSE
        KEY_F1
        KEY_F2
        KEY_F3
        KEY_F4
        KEY_F5
        KEY_F6
        KEY_F7
        KEY_F8
        KEY_F9
        KEY_F10
        KEY_F11
        KEY_F12
        KEY_LEFT_SHIFT
        KEY_LEFT_CONTROL
        KEY_LEFT_ALT
        KEY_LEFT_SUPER
        KEY_RIGHT_SHIFT
        KEY_RIGHT_CONTROL
        KEY_RIGHT_ALT
        KEY_RIGHT_SUPER
        KEY_KB_MENU
        KEY_KP_0
        KEY_KP_1
        KEY_KP_2
        KEY_KP_3
        KEY_KP_4
        KEY_KP_5
        KEY_KP_6
        KEY_KP_7
        KEY_KP_8
        KEY_KP_9
        KEY_KP_DECIMAL
        KEY_KP_DIVIDE
        KEY_KP_MULTIPLY
        KEY_KP_SUBTRACT
        KEY_KP_ADD
        KEY_KP_ENTER
        KEY_KP_EQUAL
        KEY_BACK
        KEY_MENU
        KEY_VOLUME_UP
        KEY_VOLUME_DOWN

    ctypedef enum MouseButton:
        MOUSE_BUTTON_LEFT
        MOUSE_BUTTON_RIGHT
        MOUSE_BUTTON_MIDDLE
        MOUSE_BUTTON_SIDE
        MOUSE_BUTTON_EXTRA
        MOUSE_BUTTON_FORWARD
        MOUSE_BUTTON_BACK

    ctypedef enum MouseCursor:
        MOUSE_CURSOR_DEFAULT
        MOUSE_CURSOR_ARROW
        MOUSE_CURSOR_IBEAM
        MOUSE_CURSOR_CROSSHAIR
        MOUSE_CURSOR_POINTING_HAND
        MOUSE_CURSOR_RESIZE_EW
        MOUSE_CURSOR_RESIZE_NS
        MOUSE_CURSOR_RESIZE_NWSE
        MOUSE_CURSOR_RESIZE_NESW
        MOUSE_CURSOR_RESIZE_ALL
        MOUSE_CURSOR_NOT_ALLOWED

    ctypedef enum GamepadButton:
        GAMEPAD_BUTTON_UNKNOWN
        GAMEPAD_BUTTON_LEFT_FACE_UP
        GAMEPAD_BUTTON_LEFT_FACE_RIGHT
        GAMEPAD_BUTTON_LEFT_FACE_DOWN
        GAMEPAD_BUTTON_LEFT_FACE_LEFT
        GAMEPAD_BUTTON_RIGHT_FACE_UP
        GAMEPAD_BUTTON_RIGHT_FACE_RIGHT
        GAMEPAD_BUTTON_RIGHT_FACE_DOWN
        GAMEPAD_BUTTON_RIGHT_FACE_LEFT
        GAMEPAD_BUTTON_LEFT_TRIGGER_1
        GAMEPAD_BUTTON_LEFT_TRIGGER_2
        GAMEPAD_BUTTON_RIGHT_TRIGGER_1
        GAMEPAD_BUTTON_RIGHT_TRIGGER_2
        GAMEPAD_BUTTON_MIDDLE_LEFT
        GAMEPAD_BUTTON_MIDDLE
        GAMEPAD_BUTTON_MIDDLE_RIGHT
        GAMEPAD_BUTTON_LEFT_THUMB
        GAMEPAD_BUTTON_RIGHT_THUMB

    ctypedef enum GamepadAxis:
        GAMEPAD_AXIS_LEFT_X
        GAMEPAD_AXIS_LEFT_Y
        GAMEPAD_AXIS_RIGHT_X
        GAMEPAD_AXIS_RIGHT_Y
        GAMEPAD_AXIS_LEFT_TRIGGER
        GAMEPAD_AXIS_RIGHT_TRIGGER

    ctypedef enum MaterialMapIndex:
        MATERIAL_MAP_ALBEDO
        MATERIAL_MAP_METALNESS
        MATERIAL_MAP_NORMAL
        MATERIAL_MAP_ROUGHNESS
        MATERIAL_MAP_OCCLUSION
        MATERIAL_MAP_EMISSION
        MATERIAL_MAP_HEIGHT
        MATERIAL_MAP_CUBEMAP
        MATERIAL_MAP_IRRADIANCE
        MATERIAL_MAP_PREFILTER
        MATERIAL_MAP_BRDF

    ctypedef enum ShaderLocationIndex:
        SHADER_LOC_VERTEX_POSITION
        SHADER_LOC_VERTEX_TEXCOORD01
        SHADER_LOC_VERTEX_TEXCOORD02
        SHADER_LOC_VERTEX_NORMAL
        SHADER_LOC_VERTEX_TANGENT
        SHADER_LOC_VERTEX_COLOR
        SHADER_LOC_MATRIX_MVP
        SHADER_LOC_MATRIX_VIEW
        SHADER_LOC_MATRIX_PROJECTION
        SHADER_LOC_MATRIX_MODEL
        SHADER_LOC_MATRIX_NORMAL
        SHADER_LOC_VECTOR_VIEW
        SHADER_LOC_COLOR_DIFFUSE
        SHADER_LOC_COLOR_SPECULAR
        SHADER_LOC_COLOR_AMBIENT
        SHADER_LOC_MAP_ALBEDO
        SHADER_LOC_MAP_METALNESS
        SHADER_LOC_MAP_NORMAL
        SHADER_LOC_MAP_ROUGHNESS
        SHADER_LOC_MAP_OCCLUSION
        SHADER_LOC_MAP_EMISSION
        SHADER_LOC_MAP_HEIGHT
        SHADER_LOC_MAP_CUBEMAP
        SHADER_LOC_MAP_IRRADIANCE
        SHADER_LOC_MAP_PREFILTER
        SHADER_LOC_MAP_BRDF

    ctypedef enum ShaderUniformDataType:
        SHADER_UNIFORM_FLOAT
        SHADER_UNIFORM_VEC2
        SHADER_UNIFORM_VEC3
        SHADER_UNIFORM_VEC4
        SHADER_UNIFORM_INT
        SHADER_UNIFORM_IVEC2
        SHADER_UNIFORM_IVEC3
        SHADER_UNIFORM_IVEC4
        SHADER_UNIFORM_SAMPLER2D

    ctypedef enum ShaderAttributeDataType:
        SHADER_ATTRIB_FLOAT
        SHADER_ATTRIB_VEC2
        SHADER_ATTRIB_VEC3
        SHADER_ATTRIB_VEC4

    ctypedef enum PixelFormat:
        PIXELFORMAT_UNCOMPRESSED_GRAYSCALE
        PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA
        PIXELFORMAT_UNCOMPRESSED_R5G6B5
        PIXELFORMAT_UNCOMPRESSED_R8G8B8
        PIXELFORMAT_UNCOMPRESSED_R5G5B5A1
        PIXELFORMAT_UNCOMPRESSED_R4G4B4A4
        PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
        PIXELFORMAT_UNCOMPRESSED_R32
        PIXELFORMAT_UNCOMPRESSED_R32G32B32
        PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
        PIXELFORMAT_COMPRESSED_DXT1_RGB
        PIXELFORMAT_COMPRESSED_DXT1_RGBA
        PIXELFORMAT_COMPRESSED_DXT3_RGBA
        PIXELFORMAT_COMPRESSED_DXT5_RGBA
        PIXELFORMAT_COMPRESSED_ETC1_RGB
        PIXELFORMAT_COMPRESSED_ETC2_RGB
        PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA
        PIXELFORMAT_COMPRESSED_PVRT_RGB
        PIXELFORMAT_COMPRESSED_PVRT_RGBA
        PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA
        PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA

    ctypedef enum TextureFilter:
        TEXTURE_FILTER_POINT
        TEXTURE_FILTER_BILINEAR
        TEXTURE_FILTER_TRILINEAR
        TEXTURE_FILTER_ANISOTROPIC_4X
        TEXTURE_FILTER_ANISOTROPIC_8X
        TEXTURE_FILTER_ANISOTROPIC_16X

    ctypedef enum TextureWrap:
        TEXTURE_WRAP_REPEAT
        TEXTURE_WRAP_CLAMP
        TEXTURE_WRAP_MIRROR_REPEAT
        TEXTURE_WRAP_MIRROR_CLAMP

    ctypedef enum CubemapLayout:
        CUBEMAP_LAYOUT_AUTO_DETECT
        CUBEMAP_LAYOUT_LINE_VERTICAL
        CUBEMAP_LAYOUT_LINE_HORIZONTAL
        CUBEMAP_LAYOUT_CROSS_THREE_BY_FOUR
        CUBEMAP_LAYOUT_CROSS_FOUR_BY_THREE
        CUBEMAP_LAYOUT_PANORAMA

    ctypedef enum FontType:
        FONT_DEFAULT
        FONT_BITMAP
        FONT_SDF

    ctypedef enum BlendMode:
        BLEND_ALPHA
        BLEND_ADDITIVE
        BLEND_MULTIPLIED
        BLEND_ADD_COLORS
        BLEND_SUBTRACT_COLORS
        BLEND_ALPHA_PREMULTIPLY
        BLEND_CUSTOM

    ctypedef enum Gesture:
        GESTURE_NONE
        GESTURE_TAP
        GESTURE_DOUBLETAP
        GESTURE_HOLD
        GESTURE_DRAG
        GESTURE_SWIPE_RIGHT
        GESTURE_SWIPE_LEFT
        GESTURE_SWIPE_UP
        GESTURE_SWIPE_DOWN
        GESTURE_PINCH_IN
        GESTURE_PINCH_OUT

    ctypedef enum CameraMode:
        CAMERA_CUSTOM
        CAMERA_FREE
        CAMERA_ORBITAL
        CAMERA_FIRST_PERSON
        CAMERA_THIRD_PERSON

    ctypedef enum CameraProjection:
        CAMERA_PERSPECTIVE
        CAMERA_ORTHOGRAPHIC

    ctypedef enum NPatchLayout:
        NPATCH_NINE_PATCH
        NPATCH_THREE_PATCH_VERTICAL
        NPATCH_THREE_PATCH_HORIZONTAL

    ctypedef void (*TraceLogCallback)(int logLevel, char* text, va_list args)

    ctypedef unsigned char* (*LoadFileDataCallback)(char* fileName, unsigned int* bytesRead)

    ctypedef bool (*SaveFileDataCallback)(char* fileName, void* data, unsigned int bytesToWrite)

    ctypedef char* (*LoadFileTextCallback)(char* fileName)

    ctypedef bool (*SaveFileTextCallback)(char* fileName, char* text)

    void InitWindow(int width, int height, char* title)

    bool WindowShouldClose()

    void CloseWindow()

    bool IsWindowReady()

    bool IsWindowFullscreen()

    bool IsWindowHidden()

    bool IsWindowMinimized()

    bool IsWindowMaximized()

    bool IsWindowFocused()

    bool IsWindowResized()

    bool IsWindowState(unsigned int flag)

    void SetWindowState(unsigned int flags)

    void ClearWindowState(unsigned int flags)

    void ToggleFullscreen()

    void MaximizeWindow()

    void MinimizeWindow()

    void RestoreWindow()

    void SetWindowIcon(Image image)

    void SetWindowTitle(char* title)

    void SetWindowPosition(int x, int y)

    void SetWindowMonitor(int monitor)

    void SetWindowMinSize(int width, int height)

    void SetWindowSize(int width, int height)

    void SetWindowOpacity(float opacity)

    void* GetWindowHandle()

    int GetScreenWidth()

    int GetScreenHeight()

    int GetRenderWidth()

    int GetRenderHeight()

    int GetMonitorCount()

    int GetCurrentMonitor()

    Vector2 GetMonitorPosition(int monitor)

    int GetMonitorWidth(int monitor)

    int GetMonitorHeight(int monitor)

    int GetMonitorPhysicalWidth(int monitor)

    int GetMonitorPhysicalHeight(int monitor)

    int GetMonitorRefreshRate(int monitor)

    Vector2 GetWindowPosition()

    Vector2 GetWindowScaleDPI()

    char* GetMonitorName(int monitor)

    void SetClipboardText(char* text)

    char* GetClipboardText()

    void EnableEventWaiting()

    void DisableEventWaiting()

    void SwapScreenBuffer()

    void PollInputEvents()

    void WaitTime(double seconds)

    void ShowCursor()

    void HideCursor()

    bool IsCursorHidden()

    void EnableCursor()

    void DisableCursor()

    bool IsCursorOnScreen()

    void ClearBackground(Color color)

    void BeginDrawing()

    void EndDrawing()

    void BeginMode2D(Camera2D camera)

    void EndMode2D()

    void BeginMode3D(Camera3D camera)

    void EndMode3D()

    void BeginTextureMode(RenderTexture2D target)

    void EndTextureMode()

    void BeginShaderMode(Shader shader)

    void EndShaderMode()

    void BeginBlendMode(int mode)

    void EndBlendMode()

    void BeginScissorMode(int x, int y, int width, int height)

    void EndScissorMode()

    void BeginVrStereoMode(VrStereoConfig config)

    void EndVrStereoMode()

    VrStereoConfig LoadVrStereoConfig(VrDeviceInfo device)

    void UnloadVrStereoConfig(VrStereoConfig config)

    Shader LoadShader(char* vsFileName, char* fsFileName)

    Shader LoadShaderFromMemory(char* vsCode, char* fsCode)

    int GetShaderLocation(Shader shader, char* uniformName)

    int GetShaderLocationAttrib(Shader shader, char* attribName)

    void SetShaderValue(Shader shader, int locIndex, void* value, int uniformType)

    void SetShaderValueV(Shader shader, int locIndex, void* value, int uniformType, int count)

    void SetShaderValueMatrix(Shader shader, int locIndex, Matrix mat)

    void SetShaderValueTexture(Shader shader, int locIndex, Texture2D texture)

    void UnloadShader(Shader shader)

    Ray GetMouseRay(Vector2 mousePosition, Camera camera)

    Matrix GetCameraMatrix(Camera camera)

    Matrix GetCameraMatrix2D(Camera2D camera)

    Vector2 GetWorldToScreen(Vector3 position, Camera camera)

    Vector2 GetScreenToWorld2D(Vector2 position, Camera2D camera)

    Vector2 GetWorldToScreenEx(Vector3 position, Camera camera, int width, int height)

    Vector2 GetWorldToScreen2D(Vector2 position, Camera2D camera)

    void SetTargetFPS(int fps)

    int GetFPS()

    float GetFrameTime()

    double GetTime()

    int GetRandomValue(int min, int max)

    void SetRandomSeed(unsigned int seed)

    void TakeScreenshot(char* fileName)

    void SetConfigFlags(unsigned int flags)

    void TraceLog(int logLevel, char* text)

    void SetTraceLogLevel(int logLevel)

    void* MemAlloc(int size)

    void* MemRealloc(void* ptr, int size)

    void MemFree(void* ptr)

    void OpenURL(char* url)

    void SetTraceLogCallback(TraceLogCallback callback)

    void SetLoadFileDataCallback(LoadFileDataCallback callback)

    void SetSaveFileDataCallback(SaveFileDataCallback callback)

    void SetLoadFileTextCallback(LoadFileTextCallback callback)

    void SetSaveFileTextCallback(SaveFileTextCallback callback)

    unsigned char* LoadFileData(char* fileName, unsigned int* bytesRead)

    void UnloadFileData(unsigned char* data)

    bool SaveFileData(char* fileName, void* data, unsigned int bytesToWrite)

    bool ExportDataAsCode(char* data, unsigned int size, char* fileName)

    char* LoadFileText(char* fileName)

    void UnloadFileText(char* text)

    bool SaveFileText(char* fileName, char* text)

    bool FileExists(char* fileName)

    bool DirectoryExists(char* dirPath)

    bool IsFileExtension(char* fileName, char* ext)

    int GetFileLength(char* fileName)

    char* GetFileExtension(char* fileName)

    char* GetFileName(char* filePath)

    char* GetFileNameWithoutExt(char* filePath)

    char* GetDirectoryPath(char* filePath)

    char* GetPrevDirectoryPath(char* dirPath)

    char* GetWorkingDirectory()

    char* GetApplicationDirectory()

    bool ChangeDirectory(char* dir)

    bool IsPathFile(char* path)

    FilePathList LoadDirectoryFiles(char* dirPath)

    FilePathList LoadDirectoryFilesEx(char* basePath, char* filter, bool scanSubdirs)

    void UnloadDirectoryFiles(FilePathList files)

    bool IsFileDropped()

    FilePathList LoadDroppedFiles()

    void UnloadDroppedFiles(FilePathList files)

    long GetFileModTime(char* fileName)

    unsigned char* CompressData(unsigned char* data, int dataSize, int* compDataSize)

    unsigned char* DecompressData(unsigned char* compData, int compDataSize, int* dataSize)

    char* EncodeDataBase64(unsigned char* data, int dataSize, int* outputSize)

    unsigned char* DecodeDataBase64(unsigned char* data, int* outputSize)

    bool IsKeyPressed(int key)

    bool IsKeyDown(int key)

    bool IsKeyReleased(int key)

    bool IsKeyUp(int key)

    void SetExitKey(int key)

    int GetKeyPressed()

    int GetCharPressed()

    bool IsGamepadAvailable(int gamepad)

    char* GetGamepadName(int gamepad)

    bool IsGamepadButtonPressed(int gamepad, int button)

    bool IsGamepadButtonDown(int gamepad, int button)

    bool IsGamepadButtonReleased(int gamepad, int button)

    bool IsGamepadButtonUp(int gamepad, int button)

    int GetGamepadButtonPressed()

    int GetGamepadAxisCount(int gamepad)

    float GetGamepadAxisMovement(int gamepad, int axis)

    int SetGamepadMappings(char* mappings)

    bool IsMouseButtonPressed(int button)

    bool IsMouseButtonDown(int button)

    bool IsMouseButtonReleased(int button)

    bool IsMouseButtonUp(int button)

    int GetMouseX()

    int GetMouseY()

    Vector2 GetMousePosition()

    Vector2 GetMouseDelta()

    void SetMousePosition(int x, int y)

    void SetMouseOffset(int offsetX, int offsetY)

    void SetMouseScale(float scaleX, float scaleY)

    float GetMouseWheelMove()

    Vector2 GetMouseWheelMoveV()

    void SetMouseCursor(int cursor)

    int GetTouchX()

    int GetTouchY()

    Vector2 GetTouchPosition(int index)

    int GetTouchPointId(int index)

    int GetTouchPointCount()

    void SetGesturesEnabled(unsigned int flags)

    bool IsGestureDetected(int gesture)

    int GetGestureDetected()

    float GetGestureHoldDuration()

    Vector2 GetGestureDragVector()

    float GetGestureDragAngle()

    Vector2 GetGesturePinchVector()

    float GetGesturePinchAngle()

    void SetCameraMode(Camera camera, int mode)

    void UpdateCamera(Camera* camera)

    void SetCameraPanControl(int keyPan)

    void SetCameraAltControl(int keyAlt)

    void SetCameraSmoothZoomControl(int keySmoothZoom)

    void SetCameraMoveControls(int keyFront, int keyBack, int keyRight, int keyLeft, int keyUp, int keyDown)

    void SetShapesTexture(Texture2D texture, Rectangle source)

    void DrawPixel(int posX, int posY, Color color)

    void DrawPixelV(Vector2 position, Color color)

    void DrawLine(int startPosX, int startPosY, int endPosX, int endPosY, Color color)

    void DrawLineV(Vector2 startPos, Vector2 endPos, Color color)

    void DrawLineEx(Vector2 startPos, Vector2 endPos, float thick, Color color)

    void DrawLineBezier(Vector2 startPos, Vector2 endPos, float thick, Color color)

    void DrawLineBezierQuad(Vector2 startPos, Vector2 endPos, Vector2 controlPos, float thick, Color color)

    void DrawLineBezierCubic(Vector2 startPos, Vector2 endPos, Vector2 startControlPos, Vector2 endControlPos, float thick, Color color)

    void DrawLineStrip(Vector2* points, int pointCount, Color color)

    void DrawCircle(int centerX, int centerY, float radius, Color color)

    void DrawCircleSector(Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color)

    void DrawCircleSectorLines(Vector2 center, float radius, float startAngle, float endAngle, int segments, Color color)

    void DrawCircleGradient(int centerX, int centerY, float radius, Color color1, Color color2)

    void DrawCircleV(Vector2 center, float radius, Color color)

    void DrawCircleLines(int centerX, int centerY, float radius, Color color)

    void DrawEllipse(int centerX, int centerY, float radiusH, float radiusV, Color color)

    void DrawEllipseLines(int centerX, int centerY, float radiusH, float radiusV, Color color)

    void DrawRing(Vector2 center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, Color color)

    void DrawRingLines(Vector2 center, float innerRadius, float outerRadius, float startAngle, float endAngle, int segments, Color color)

    void DrawRectangle(int posX, int posY, int width, int height, Color color)

    void DrawRectangleV(Vector2 position, Vector2 size, Color color)

    void DrawRectangleRec(Rectangle rec, Color color)

    void DrawRectanglePro(Rectangle rec, Vector2 origin, float rotation, Color color)

    void DrawRectangleGradientV(int posX, int posY, int width, int height, Color color1, Color color2)

    void DrawRectangleGradientH(int posX, int posY, int width, int height, Color color1, Color color2)

    void DrawRectangleGradientEx(Rectangle rec, Color col1, Color col2, Color col3, Color col4)

    void DrawRectangleLines(int posX, int posY, int width, int height, Color color)

    void DrawRectangleLinesEx(Rectangle rec, float lineThick, Color color)

    void DrawRectangleRounded(Rectangle rec, float roundness, int segments, Color color)

    void DrawRectangleRoundedLines(Rectangle rec, float roundness, int segments, float lineThick, Color color)

    void DrawTriangle(Vector2 v1, Vector2 v2, Vector2 v3, Color color)

    void DrawTriangleLines(Vector2 v1, Vector2 v2, Vector2 v3, Color color)

    void DrawTriangleFan(Vector2* points, int pointCount, Color color)

    void DrawTriangleStrip(Vector2* points, int pointCount, Color color)

    void DrawPoly(Vector2 center, int sides, float radius, float rotation, Color color)

    void DrawPolyLines(Vector2 center, int sides, float radius, float rotation, Color color)

    void DrawPolyLinesEx(Vector2 center, int sides, float radius, float rotation, float lineThick, Color color)

    bool CheckCollisionRecs(Rectangle rec1, Rectangle rec2)

    bool CheckCollisionCircles(Vector2 center1, float radius1, Vector2 center2, float radius2)

    bool CheckCollisionCircleRec(Vector2 center, float radius, Rectangle rec)

    bool CheckCollisionPointRec(Vector2 point, Rectangle rec)

    bool CheckCollisionPointCircle(Vector2 point, Vector2 center, float radius)

    bool CheckCollisionPointTriangle(Vector2 point, Vector2 p1, Vector2 p2, Vector2 p3)

    bool CheckCollisionLines(Vector2 startPos1, Vector2 endPos1, Vector2 startPos2, Vector2 endPos2, Vector2* collisionPoint)

    bool CheckCollisionPointLine(Vector2 point, Vector2 p1, Vector2 p2, int threshold)

    Rectangle GetCollisionRec(Rectangle rec1, Rectangle rec2)

    Image LoadImage(char* fileName)

    Image LoadImageRaw(char* fileName, int width, int height, int format, int headerSize)

    Image LoadImageAnim(char* fileName, int* frames)

    Image LoadImageFromMemory(char* fileType, unsigned char* fileData, int dataSize)

    Image LoadImageFromTexture(Texture2D texture)

    Image LoadImageFromScreen()

    void UnloadImage(Image image)

    bool ExportImage(Image image, char* fileName)

    bool ExportImageAsCode(Image image, char* fileName)

    Image GenImageColor(int width, int height, Color color)

    Image GenImageGradientV(int width, int height, Color top, Color bottom)

    Image GenImageGradientH(int width, int height, Color left, Color right)

    Image GenImageGradientRadial(int width, int height, float density, Color inner, Color outer)

    Image GenImageChecked(int width, int height, int checksX, int checksY, Color col1, Color col2)

    Image GenImageWhiteNoise(int width, int height, float factor)

    Image GenImageCellular(int width, int height, int tileSize)

    Image ImageCopy(Image image)

    Image ImageFromImage(Image image, Rectangle rec)

    Image ImageText(char* text, int fontSize, Color color)

    Image ImageTextEx(Font font, char* text, float fontSize, float spacing, Color tint)

    void ImageFormat(Image* image, int newFormat)

    void ImageToPOT(Image* image, Color fill)

    void ImageCrop(Image* image, Rectangle crop)

    void ImageAlphaCrop(Image* image, float threshold)

    void ImageAlphaClear(Image* image, Color color, float threshold)

    void ImageAlphaMask(Image* image, Image alphaMask)

    void ImageAlphaPremultiply(Image* image)

    void ImageResize(Image* image, int newWidth, int newHeight)

    void ImageResizeNN(Image* image, int newWidth, int newHeight)

    void ImageResizeCanvas(Image* image, int newWidth, int newHeight, int offsetX, int offsetY, Color fill)

    void ImageMipmaps(Image* image)

    void ImageDither(Image* image, int rBpp, int gBpp, int bBpp, int aBpp)

    void ImageFlipVertical(Image* image)

    void ImageFlipHorizontal(Image* image)

    void ImageRotateCW(Image* image)

    void ImageRotateCCW(Image* image)

    void ImageColorTint(Image* image, Color color)

    void ImageColorInvert(Image* image)

    void ImageColorGrayscale(Image* image)

    void ImageColorContrast(Image* image, float contrast)

    void ImageColorBrightness(Image* image, int brightness)

    void ImageColorReplace(Image* image, Color color, Color replace)

    Color* LoadImageColors(Image image)

    Color* LoadImagePalette(Image image, int maxPaletteSize, int* colorCount)

    void UnloadImageColors(Color* colors)

    void UnloadImagePalette(Color* colors)

    Rectangle GetImageAlphaBorder(Image image, float threshold)

    Color GetImageColor(Image image, int x, int y)

    void ImageClearBackground(Image* dst, Color color)

    void ImageDrawPixel(Image* dst, int posX, int posY, Color color)

    void ImageDrawPixelV(Image* dst, Vector2 position, Color color)

    void ImageDrawLine(Image* dst, int startPosX, int startPosY, int endPosX, int endPosY, Color color)

    void ImageDrawLineV(Image* dst, Vector2 start, Vector2 end, Color color)

    void ImageDrawCircle(Image* dst, int centerX, int centerY, int radius, Color color)

    void ImageDrawCircleV(Image* dst, Vector2 center, int radius, Color color)

    void ImageDrawRectangle(Image* dst, int posX, int posY, int width, int height, Color color)

    void ImageDrawRectangleV(Image* dst, Vector2 position, Vector2 size, Color color)

    void ImageDrawRectangleRec(Image* dst, Rectangle rec, Color color)

    void ImageDrawRectangleLines(Image* dst, Rectangle rec, int thick, Color color)

    void ImageDraw(Image* dst, Image src, Rectangle srcRec, Rectangle dstRec, Color tint)

    void ImageDrawText(Image* dst, char* text, int posX, int posY, int fontSize, Color color)

    void ImageDrawTextEx(Image* dst, Font font, char* text, Vector2 position, float fontSize, float spacing, Color tint)

    Texture2D LoadTexture(char* fileName)

    Texture2D LoadTextureFromImage(Image image)

    TextureCubemap LoadTextureCubemap(Image image, int layout)

    RenderTexture2D LoadRenderTexture(int width, int height)

    void UnloadTexture(Texture2D texture)

    void UnloadRenderTexture(RenderTexture2D target)

    void UpdateTexture(Texture2D texture, void* pixels)

    void UpdateTextureRec(Texture2D texture, Rectangle rec, void* pixels)

    void GenTextureMipmaps(Texture2D* texture)

    void SetTextureFilter(Texture2D texture, int filter)

    void SetTextureWrap(Texture2D texture, int wrap)

    void DrawTexture(Texture2D texture, int posX, int posY, Color tint)

    void DrawTextureV(Texture2D texture, Vector2 position, Color tint)

    void DrawTextureEx(Texture2D texture, Vector2 position, float rotation, float scale, Color tint)

    void DrawTextureRec(Texture2D texture, Rectangle source, Vector2 position, Color tint)

    void DrawTextureQuad(Texture2D texture, Vector2 tiling, Vector2 offset, Rectangle quad, Color tint)

    void DrawTextureTiled(Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, float scale, Color tint)

    void DrawTexturePro(Texture2D texture, Rectangle source, Rectangle dest, Vector2 origin, float rotation, Color tint)

    void DrawTextureNPatch(Texture2D texture, NPatchInfo nPatchInfo, Rectangle dest, Vector2 origin, float rotation, Color tint)

    void DrawTexturePoly(Texture2D texture, Vector2 center, Vector2* points, Vector2* texcoords, int pointCount, Color tint)

    Color Fade(Color color, float alpha)

    int ColorToInt(Color color)

    Vector4 ColorNormalize(Color color)

    Color ColorFromNormalized(Vector4 normalized)

    Vector3 ColorToHSV(Color color)

    Color ColorFromHSV(float hue, float saturation, float value)

    Color ColorAlpha(Color color, float alpha)

    Color ColorAlphaBlend(Color dst, Color src, Color tint)

    Color GetColor(unsigned int hexValue)

    Color GetPixelColor(void* srcPtr, int format)

    void SetPixelColor(void* dstPtr, Color color, int format)

    int GetPixelDataSize(int width, int height, int format)

    Font GetFontDefault()

    Font LoadFont(char* fileName)

    Font LoadFontEx(char* fileName, int fontSize, int* fontChars, int glyphCount)

    Font LoadFontFromImage(Image image, Color key, int firstChar)

    Font LoadFontFromMemory(char* fileType, unsigned char* fileData, int dataSize, int fontSize, int* fontChars, int glyphCount)

    GlyphInfo* LoadFontData(unsigned char* fileData, int dataSize, int fontSize, int* fontChars, int glyphCount, int type)

    Image GenImageFontAtlas(GlyphInfo* chars, Rectangle** recs, int glyphCount, int fontSize, int padding, int packMethod)

    void UnloadFontData(GlyphInfo* chars, int glyphCount)

    void UnloadFont(Font font)

    bool ExportFontAsCode(Font font, char* fileName)

    void DrawFPS(int posX, int posY)

    void DrawText(char* text, int posX, int posY, int fontSize, Color color)

    void DrawTextEx(Font font, char* text, Vector2 position, float fontSize, float spacing, Color tint)

    void DrawTextPro(Font font, char* text, Vector2 position, Vector2 origin, float rotation, float fontSize, float spacing, Color tint)

    void DrawTextCodepoint(Font font, int codepoint, Vector2 position, float fontSize, Color tint)

    void DrawTextCodepoints(Font font, int* codepoints, int count, Vector2 position, float fontSize, float spacing, Color tint)

    int MeasureText(char* text, int fontSize)

    Vector2 MeasureTextEx(Font font, char* text, float fontSize, float spacing)

    int GetGlyphIndex(Font font, int codepoint)

    GlyphInfo GetGlyphInfo(Font font, int codepoint)

    Rectangle GetGlyphAtlasRec(Font font, int codepoint)

    int* LoadCodepoints(char* text, int* count)

    void UnloadCodepoints(int* codepoints)

    int GetCodepointCount(char* text)

    int GetCodepoint(char* text, int* bytesProcessed)

    char* CodepointToUTF8(int codepoint, int* byteSize)

    char* TextCodepointsToUTF8(int* codepoints, int length)

    int TextCopy(char* dst, char* src)

    bool TextIsEqual(char* text1, char* text2)

    unsigned int TextLength(char* text)

    char* TextFormat(char* text)

    char* TextSubtext(char* text, int position, int length)

    char* TextReplace(char* text, char* replace, char* by_)

    char* TextInsert(char* text, char* insert, int position)

    char* TextJoin(char** textList, int count, char* delimiter)

    char** TextSplit(char* text, char delimiter, int* count)

    void TextAppend(char* text, char* append, int* position)

    int TextFindIndex(char* text, char* find)

    char* TextToUpper(char* text)

    char* TextToLower(char* text)

    char* TextToPascal(char* text)

    int TextToInteger(char* text)

    void DrawLine3D(Vector3 startPos, Vector3 endPos, Color color)

    void DrawPoint3D(Vector3 position, Color color)

    void DrawCircle3D(Vector3 center, float radius, Vector3 rotationAxis, float rotationAngle, Color color)

    void DrawTriangle3D(Vector3 v1, Vector3 v2, Vector3 v3, Color color)

    void DrawTriangleStrip3D(Vector3* points, int pointCount, Color color)

    void DrawCube(Vector3 position, float width, float height, float length, Color color)

    void DrawCubeV(Vector3 position, Vector3 size, Color color)

    void DrawCubeWires(Vector3 position, float width, float height, float length, Color color)

    void DrawCubeWiresV(Vector3 position, Vector3 size, Color color)

    void DrawCubeTexture(Texture2D texture, Vector3 position, float width, float height, float length, Color color)

    void DrawCubeTextureRec(Texture2D texture, Rectangle source, Vector3 position, float width, float height, float length, Color color)

    void DrawSphere(Vector3 centerPos, float radius, Color color)

    void DrawSphereEx(Vector3 centerPos, float radius, int rings, int slices, Color color)

    void DrawSphereWires(Vector3 centerPos, float radius, int rings, int slices, Color color)

    void DrawCylinder(Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color)

    void DrawCylinderEx(Vector3 startPos, Vector3 endPos, float startRadius, float endRadius, int sides, Color color)

    void DrawCylinderWires(Vector3 position, float radiusTop, float radiusBottom, float height, int slices, Color color)

    void DrawCylinderWiresEx(Vector3 startPos, Vector3 endPos, float startRadius, float endRadius, int sides, Color color)

    void DrawPlane(Vector3 centerPos, Vector2 size, Color color)

    void DrawRay(Ray ray, Color color)

    void DrawGrid(int slices, float spacing)

    Model LoadModel(char* fileName)

    Model LoadModelFromMesh(Mesh mesh)

    void UnloadModel(Model model)

    void UnloadModelKeepMeshes(Model model)

    BoundingBox GetModelBoundingBox(Model model)

    void DrawModel(Model model, Vector3 position, float scale, Color tint)

    void DrawModelEx(Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint)

    void DrawModelWires(Model model, Vector3 position, float scale, Color tint)

    void DrawModelWiresEx(Model model, Vector3 position, Vector3 rotationAxis, float rotationAngle, Vector3 scale, Color tint)

    void DrawBoundingBox(BoundingBox box, Color color)

    void DrawBillboard(Camera camera, Texture2D texture, Vector3 position, float size, Color tint)

    void DrawBillboardRec(Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector2 size, Color tint)

    void DrawBillboardPro(Camera camera, Texture2D texture, Rectangle source, Vector3 position, Vector3 up, Vector2 size, Vector2 origin, float rotation, Color tint)

    void UploadMesh(Mesh* mesh, bool dynamic)

    void UpdateMeshBuffer(Mesh mesh, int index, void* data, int dataSize, int offset)

    void UnloadMesh(Mesh mesh)

    void DrawMesh(Mesh mesh, Material material, Matrix transform)

    void DrawMeshInstanced(Mesh mesh, Material material, Matrix* transforms, int instances)

    bool ExportMesh(Mesh mesh, char* fileName)

    BoundingBox GetMeshBoundingBox(Mesh mesh)

    void GenMeshTangents(Mesh* mesh)

    Mesh GenMeshPoly(int sides, float radius)

    Mesh GenMeshPlane(float width, float length, int resX, int resZ)

    Mesh GenMeshCube(float width, float height, float length)

    Mesh GenMeshSphere(float radius, int rings, int slices)

    Mesh GenMeshHemiSphere(float radius, int rings, int slices)

    Mesh GenMeshCylinder(float radius, float height, int slices)

    Mesh GenMeshCone(float radius, float height, int slices)

    Mesh GenMeshTorus(float radius, float size, int radSeg, int sides)

    Mesh GenMeshKnot(float radius, float size, int radSeg, int sides)

    Mesh GenMeshHeightmap(Image heightmap, Vector3 size)

    Mesh GenMeshCubicmap(Image cubicmap, Vector3 cubeSize)

    Material* LoadMaterials(char* fileName, int* materialCount)

    Material LoadMaterialDefault()

    void UnloadMaterial(Material material)

    void SetMaterialTexture(Material* material, int mapType, Texture2D texture)

    void SetModelMeshMaterial(Model* model, int meshId, int materialId)

    ModelAnimation* LoadModelAnimations(char* fileName, unsigned int* animCount)

    void UpdateModelAnimation(Model model, ModelAnimation anim, int frame)

    void UnloadModelAnimation(ModelAnimation anim)

    void UnloadModelAnimations(ModelAnimation* animations, unsigned int count)

    bool IsModelAnimationValid(Model model, ModelAnimation anim)

    bool CheckCollisionSpheres(Vector3 center1, float radius1, Vector3 center2, float radius2)

    bool CheckCollisionBoxes(BoundingBox box1, BoundingBox box2)

    bool CheckCollisionBoxSphere(BoundingBox box, Vector3 center, float radius)

    RayCollision GetRayCollisionSphere(Ray ray, Vector3 center, float radius)

    RayCollision GetRayCollisionBox(Ray ray, BoundingBox box)

    RayCollision GetRayCollisionMesh(Ray ray, Mesh mesh, Matrix transform)

    RayCollision GetRayCollisionTriangle(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3)

    RayCollision GetRayCollisionQuad(Ray ray, Vector3 p1, Vector3 p2, Vector3 p3, Vector3 p4)

    ctypedef void (*AudioCallback)(void* bufferData, unsigned int frames)

    void InitAudioDevice()

    void CloseAudioDevice()

    bool IsAudioDeviceReady()

    void SetMasterVolume(float volume)

    Wave LoadWave(char* fileName)

    Wave LoadWaveFromMemory(char* fileType, unsigned char* fileData, int dataSize)

    Sound LoadSound(char* fileName)

    Sound LoadSoundFromWave(Wave wave)

    void UpdateSound(Sound sound, void* data, int sampleCount)

    void UnloadWave(Wave wave)

    void UnloadSound(Sound sound)

    bool ExportWave(Wave wave, char* fileName)

    bool ExportWaveAsCode(Wave wave, char* fileName)

    void PlaySound(Sound sound)

    void StopSound(Sound sound)

    void PauseSound(Sound sound)

    void ResumeSound(Sound sound)

    void PlaySoundMulti(Sound sound)

    void StopSoundMulti()

    int GetSoundsPlaying()

    bool IsSoundPlaying(Sound sound)

    void SetSoundVolume(Sound sound, float volume)

    void SetSoundPitch(Sound sound, float pitch)

    void SetSoundPan(Sound sound, float pan)

    Wave WaveCopy(Wave wave)

    void WaveCrop(Wave* wave, int initSample, int finalSample)

    void WaveFormat(Wave* wave, int sampleRate, int sampleSize, int channels)

    float* LoadWaveSamples(Wave wave)

    void UnloadWaveSamples(float* samples)

    Music LoadMusicStream(char* fileName)

    Music LoadMusicStreamFromMemory(char* fileType, unsigned char* data, int dataSize)

    void UnloadMusicStream(Music music)

    void PlayMusicStream(Music music)

    bool IsMusicStreamPlaying(Music music)

    void UpdateMusicStream(Music music)

    void StopMusicStream(Music music)

    void PauseMusicStream(Music music)

    void ResumeMusicStream(Music music)

    void SeekMusicStream(Music music, float position)

    void SetMusicVolume(Music music, float volume)

    void SetMusicPitch(Music music, float pitch)

    void SetMusicPan(Music music, float pan)

    float GetMusicTimeLength(Music music)

    float GetMusicTimePlayed(Music music)

    AudioStream LoadAudioStream(unsigned int sampleRate, unsigned int sampleSize, unsigned int channels)

    void UnloadAudioStream(AudioStream stream)

    void UpdateAudioStream(AudioStream stream, void* data, int frameCount)

    bool IsAudioStreamProcessed(AudioStream stream)

    void PlayAudioStream(AudioStream stream)

    void PauseAudioStream(AudioStream stream)

    void ResumeAudioStream(AudioStream stream)

    bool IsAudioStreamPlaying(AudioStream stream)

    void StopAudioStream(AudioStream stream)

    void SetAudioStreamVolume(AudioStream stream, float volume)

    void SetAudioStreamPitch(AudioStream stream, float pitch)

    void SetAudioStreamPan(AudioStream stream, float pan)

    void SetAudioStreamBufferSizeDefault(int size)

    void SetAudioStreamCallback(AudioStream stream, AudioCallback callback)

    void AttachAudioStreamProcessor(AudioStream stream, AudioCallback processor)

    void DetachAudioStreamProcessor(AudioStream stream, AudioCallback processor)

cdef extern from *:
    """
    static void setVector2(struct Vector2 &v, float x, float y) {
        v.x = x; v.y = y;
    }
    static struct Vector2 newVector2(float x, float y) {
        struct Vector2 v; v.x = x; v.y = y; return v;
    }
    static void setVector3(struct Vector3 &v, float x, float y, float z) {
        v.x = x; v.y = y; v.z = z;
    }
    static struct Vector3 newVector3(float x, float y, float z) {
        struct Vector3 v; v.x = x; v.y = y; v.z = z; return v;
    }
    """
    void setVector2(Vector2 &v, float x, float y)
    Vector2 newVector2(float x, float y)
    void setVector3(Vector3 &v, float x, float y, float z)
    Vector3 newVector3(float x, float y, float z)
