# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libcpp cimport bool

cdef extern from "rlgl.h":

    ctypedef enum rlGlVersion:
        OPENGL_11
        OPENGL_21
        OPENGL_33
        OPENGL_43
        OPENGL_ES_20

    ctypedef enum rlFramebufferAttachType:
        RL_ATTACHMENT_COLOR_CHANNEL0
        RL_ATTACHMENT_COLOR_CHANNEL1
        RL_ATTACHMENT_COLOR_CHANNEL2
        RL_ATTACHMENT_COLOR_CHANNEL3
        RL_ATTACHMENT_COLOR_CHANNEL4
        RL_ATTACHMENT_COLOR_CHANNEL5
        RL_ATTACHMENT_COLOR_CHANNEL6
        RL_ATTACHMENT_COLOR_CHANNEL7
        RL_ATTACHMENT_DEPTH
        RL_ATTACHMENT_STENCIL

    ctypedef enum rlFramebufferAttachTextureType:
        RL_ATTACHMENT_CUBEMAP_POSITIVE_X
        RL_ATTACHMENT_CUBEMAP_NEGATIVE_X
        RL_ATTACHMENT_CUBEMAP_POSITIVE_Y
        RL_ATTACHMENT_CUBEMAP_NEGATIVE_Y
        RL_ATTACHMENT_CUBEMAP_POSITIVE_Z
        RL_ATTACHMENT_CUBEMAP_NEGATIVE_Z
        RL_ATTACHMENT_TEXTURE2D
        RL_ATTACHMENT_RENDERBUFFER

    cdef struct rlVertexBuffer:
        int elementCount
        float* vertices
        float* texcoords
        unsigned char* colors
        unsigned int* indices
        unsigned int vaoId
        unsigned int vboId[4]

    cdef struct rlDrawCall:
        int mode
        int vertexCount
        int vertexAlignment
        unsigned int textureId

    cdef struct rlRenderBatch:
        int bufferCount
        int currentBuffer
        rlVertexBuffer* vertexBuffer
        rlDrawCall* draws
        int drawCounter
        float currentDepth

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

    ctypedef enum rlTraceLogLevel:
        RL_LOG_ALL
        RL_LOG_TRACE
        RL_LOG_DEBUG
        RL_LOG_INFO
        RL_LOG_WARNING
        RL_LOG_ERROR
        RL_LOG_FATAL
        RL_LOG_NONE

    ctypedef enum rlPixelFormat:
        RL_PIXELFORMAT_UNCOMPRESSED_GRAYSCALE
        RL_PIXELFORMAT_UNCOMPRESSED_GRAY_ALPHA
        RL_PIXELFORMAT_UNCOMPRESSED_R5G6B5
        RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8
        RL_PIXELFORMAT_UNCOMPRESSED_R5G5B5A1
        RL_PIXELFORMAT_UNCOMPRESSED_R4G4B4A4
        RL_PIXELFORMAT_UNCOMPRESSED_R8G8B8A8
        RL_PIXELFORMAT_UNCOMPRESSED_R32
        RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32
        RL_PIXELFORMAT_UNCOMPRESSED_R32G32B32A32
        RL_PIXELFORMAT_COMPRESSED_DXT1_RGB
        RL_PIXELFORMAT_COMPRESSED_DXT1_RGBA
        RL_PIXELFORMAT_COMPRESSED_DXT3_RGBA
        RL_PIXELFORMAT_COMPRESSED_DXT5_RGBA
        RL_PIXELFORMAT_COMPRESSED_ETC1_RGB
        RL_PIXELFORMAT_COMPRESSED_ETC2_RGB
        RL_PIXELFORMAT_COMPRESSED_ETC2_EAC_RGBA
        RL_PIXELFORMAT_COMPRESSED_PVRT_RGB
        RL_PIXELFORMAT_COMPRESSED_PVRT_RGBA
        RL_PIXELFORMAT_COMPRESSED_ASTC_4x4_RGBA
        RL_PIXELFORMAT_COMPRESSED_ASTC_8x8_RGBA

    ctypedef enum rlTextureFilter:
        RL_TEXTURE_FILTER_POINT
        RL_TEXTURE_FILTER_BILINEAR
        RL_TEXTURE_FILTER_TRILINEAR
        RL_TEXTURE_FILTER_ANISOTROPIC_4X
        RL_TEXTURE_FILTER_ANISOTROPIC_8X
        RL_TEXTURE_FILTER_ANISOTROPIC_16X

    ctypedef enum rlBlendMode:
        RL_BLEND_ALPHA
        RL_BLEND_ADDITIVE
        RL_BLEND_MULTIPLIED
        RL_BLEND_ADD_COLORS
        RL_BLEND_SUBTRACT_COLORS
        RL_BLEND_ALPHA_PREMULTIPLY
        RL_BLEND_CUSTOM

    ctypedef enum rlShaderLocationIndex:
        RL_SHADER_LOC_VERTEX_POSITION
        RL_SHADER_LOC_VERTEX_TEXCOORD01
        RL_SHADER_LOC_VERTEX_TEXCOORD02
        RL_SHADER_LOC_VERTEX_NORMAL
        RL_SHADER_LOC_VERTEX_TANGENT
        RL_SHADER_LOC_VERTEX_COLOR
        RL_SHADER_LOC_MATRIX_MVP
        RL_SHADER_LOC_MATRIX_VIEW
        RL_SHADER_LOC_MATRIX_PROJECTION
        RL_SHADER_LOC_MATRIX_MODEL
        RL_SHADER_LOC_MATRIX_NORMAL
        RL_SHADER_LOC_VECTOR_VIEW
        RL_SHADER_LOC_COLOR_DIFFUSE
        RL_SHADER_LOC_COLOR_SPECULAR
        RL_SHADER_LOC_COLOR_AMBIENT
        RL_SHADER_LOC_MAP_ALBEDO
        RL_SHADER_LOC_MAP_METALNESS
        RL_SHADER_LOC_MAP_NORMAL
        RL_SHADER_LOC_MAP_ROUGHNESS
        RL_SHADER_LOC_MAP_OCCLUSION
        RL_SHADER_LOC_MAP_EMISSION
        RL_SHADER_LOC_MAP_HEIGHT
        RL_SHADER_LOC_MAP_CUBEMAP
        RL_SHADER_LOC_MAP_IRRADIANCE
        RL_SHADER_LOC_MAP_PREFILTER
        RL_SHADER_LOC_MAP_BRDF

    ctypedef enum rlShaderUniformDataType:
        RL_SHADER_UNIFORM_FLOAT
        RL_SHADER_UNIFORM_VEC2
        RL_SHADER_UNIFORM_VEC3
        RL_SHADER_UNIFORM_VEC4
        RL_SHADER_UNIFORM_INT
        RL_SHADER_UNIFORM_IVEC2
        RL_SHADER_UNIFORM_IVEC3
        RL_SHADER_UNIFORM_IVEC4
        RL_SHADER_UNIFORM_SAMPLER2D

    ctypedef enum rlShaderAttributeDataType:
        RL_SHADER_ATTRIB_FLOAT
        RL_SHADER_ATTRIB_VEC2
        RL_SHADER_ATTRIB_VEC3
        RL_SHADER_ATTRIB_VEC4

    void rlMatrixMode(int mode)

    void rlPushMatrix()

    void rlPopMatrix()

    void rlLoadIdentity()

    void rlTranslatef(float x, float y, float z)

    void rlRotatef(float angle, float x, float y, float z)

    void rlScalef(float x, float y, float z)

    void rlMultMatrixf(float* matf)

    void rlFrustum(double left, double right, double bottom, double top, double znear, double zfar)

    void rlOrtho(double left, double right, double bottom, double top, double znear, double zfar)

    void rlViewport(int x, int y, int width, int height)

    void rlBegin(int mode)

    void rlEnd()

    void rlVertex2i(int x, int y)

    void rlVertex2f(float x, float y)

    void rlVertex3f(float x, float y, float z)

    void rlTexCoord2f(float x, float y)

    void rlNormal3f(float x, float y, float z)

    void rlColor4ub(unsigned char r, unsigned char g, unsigned char b, unsigned char a)

    void rlColor3f(float x, float y, float z)

    void rlColor4f(float x, float y, float z, float w)

    bool rlEnableVertexArray(unsigned int vaoId)

    void rlDisableVertexArray()

    void rlEnableVertexBuffer(unsigned int id)

    void rlDisableVertexBuffer()

    void rlEnableVertexBufferElement(unsigned int id)

    void rlDisableVertexBufferElement()

    void rlEnableVertexAttribute(unsigned int index)

    void rlDisableVertexAttribute(unsigned int index)

    void rlActiveTextureSlot(int slot)

    void rlEnableTexture(unsigned int id)

    void rlDisableTexture()

    void rlEnableTextureCubemap(unsigned int id)

    void rlDisableTextureCubemap()

    void rlTextureParameters(unsigned int id, int param, int value)

    void rlEnableShader(unsigned int id)

    void rlDisableShader()

    void rlEnableFramebuffer(unsigned int id)

    void rlDisableFramebuffer()

    void rlActiveDrawBuffers(int count)

    void rlEnableColorBlend()

    void rlDisableColorBlend()

    void rlEnableDepthTest()

    void rlDisableDepthTest()

    void rlEnableDepthMask()

    void rlDisableDepthMask()

    void rlEnableBackfaceCulling()

    void rlDisableBackfaceCulling()

    void rlEnableScissorTest()

    void rlDisableScissorTest()

    void rlScissor(int x, int y, int width, int height)

    void rlEnableWireMode()

    void rlDisableWireMode()

    void rlSetLineWidth(float width)

    float rlGetLineWidth()

    void rlEnableSmoothLines()

    void rlDisableSmoothLines()

    void rlEnableStereoRender()

    void rlDisableStereoRender()

    bool rlIsStereoRenderEnabled()

    void rlClearColor(unsigned char r, unsigned char g, unsigned char b, unsigned char a)

    void rlClearScreenBuffers()

    void rlCheckErrors()

    void rlSetBlendMode(int mode)

    void rlSetBlendFactors(int glSrcFactor, int glDstFactor, int glEquation)

    void rlglInit(int width, int height)

    void rlglClose()

    void rlLoadExtensions(void* loader)

    int rlGetVersion()

    void rlSetFramebufferWidth(int width)

    int rlGetFramebufferWidth()

    void rlSetFramebufferHeight(int height)

    int rlGetFramebufferHeight()

    unsigned int rlGetTextureIdDefault()

    unsigned int rlGetShaderIdDefault()

    int* rlGetShaderLocsDefault()

    rlRenderBatch rlLoadRenderBatch(int numBuffers, int bufferElements)

    void rlUnloadRenderBatch(rlRenderBatch batch)

    void rlDrawRenderBatch(rlRenderBatch* batch)

    void rlSetRenderBatchActive(rlRenderBatch* batch)

    void rlDrawRenderBatchActive()

    bool rlCheckRenderBatchLimit(int vCount)

    void rlSetTexture(unsigned int id)

    unsigned int rlLoadVertexArray()

    unsigned int rlLoadVertexBuffer(void* buffer, int size, bool dynamic)

    unsigned int rlLoadVertexBufferElement(void* buffer, int size, bool dynamic)

    void rlUpdateVertexBuffer(unsigned int bufferId, void* data, int dataSize, int offset)

    void rlUpdateVertexBufferElements(unsigned int id, void* data, int dataSize, int offset)

    void rlUnloadVertexArray(unsigned int vaoId)

    void rlUnloadVertexBuffer(unsigned int vboId)

    void rlSetVertexAttribute(unsigned int index, int compSize, int type, bool normalized, int stride, void* pointer)

    void rlSetVertexAttributeDivisor(unsigned int index, int divisor)

    void rlSetVertexAttributeDefault(int locIndex, void* value, int attribType, int count)

    void rlDrawVertexArray(int offset, int count)

    void rlDrawVertexArrayElements(int offset, int count, void* buffer)

    void rlDrawVertexArrayInstanced(int offset, int count, int instances)

    void rlDrawVertexArrayElementsInstanced(int offset, int count, void* buffer, int instances)

    unsigned int rlLoadTexture(void* data, int width, int height, int format, int mipmapCount)

    unsigned int rlLoadTextureDepth(int width, int height, bool useRenderBuffer)

    unsigned int rlLoadTextureCubemap(void* data, int size, int format)

    void rlUpdateTexture(unsigned int id, int offsetX, int offsetY, int width, int height, int format, void* data)

    void rlGetGlTextureFormats(int format, unsigned int* glInternalFormat, unsigned int* glFormat, unsigned int* glType)

    char* rlGetPixelFormatName(unsigned int format)

    void rlUnloadTexture(unsigned int id)

    void rlGenTextureMipmaps(unsigned int id, int width, int height, int format, int* mipmaps)

    void* rlReadTexturePixels(unsigned int id, int width, int height, int format)

    unsigned char* rlReadScreenPixels(int width, int height)

    unsigned int rlLoadFramebuffer(int width, int height)

    void rlFramebufferAttach(unsigned int fboId, unsigned int texId, int attachType, int texType, int mipLevel)

    bool rlFramebufferComplete(unsigned int id)

    void rlUnloadFramebuffer(unsigned int id)

    unsigned int rlLoadShaderCode(char* vsCode, char* fsCode)

    unsigned int rlCompileShader(char* shaderCode, int type)

    unsigned int rlLoadShaderProgram(unsigned int vShaderId, unsigned int fShaderId)

    void rlUnloadShaderProgram(unsigned int id)

    int rlGetLocationUniform(unsigned int shaderId, char* uniformName)

    int rlGetLocationAttrib(unsigned int shaderId, char* attribName)

    void rlSetUniform(int locIndex, void* value, int uniformType, int count)

    void rlSetUniformMatrix(int locIndex, Matrix mat)

    void rlSetUniformSampler(int locIndex, unsigned int textureId)

    void rlSetShader(unsigned int id, int* locs)

    unsigned int rlLoadComputeShaderProgram(unsigned int shaderId)

    void rlComputeShaderDispatch(unsigned int groupX, unsigned int groupY, unsigned int groupZ)

    unsigned int rlLoadShaderBuffer(unsigned long long size, void* data, int usageHint)

    void rlUnloadShaderBuffer(unsigned int ssboId)

    void rlUpdateShaderBufferElements(unsigned int id, void* data, unsigned long long dataSize, unsigned long long offset)

    unsigned long long rlGetShaderBufferSize(unsigned int id)

    void rlReadShaderBufferElements(unsigned int id, void* dest, unsigned long long count, unsigned long long offset)

    void rlBindShaderBuffer(unsigned int id, unsigned int index)

    void rlCopyBuffersElements(unsigned int destId, unsigned int srcId, unsigned long long destOffset, unsigned long long srcOffset, unsigned long long count)

    void rlBindImageTexture(unsigned int id, unsigned int index, unsigned int format, int readonly_)

    Matrix rlGetMatrixModelview()

    Matrix rlGetMatrixProjection()

    Matrix rlGetMatrixTransform()

    Matrix rlGetMatrixProjectionStereo(int eye)

    Matrix rlGetMatrixViewOffsetStereo(int eye)

    void rlSetMatrixProjection(Matrix proj)

    void rlSetMatrixModelview(Matrix view)

    void rlSetMatrixProjectionStereo(Matrix right, Matrix left)

    void rlSetMatrixViewOffsetStereo(Matrix right, Matrix left)

    void rlLoadDrawCube()

    void rlLoadDrawQuad()
