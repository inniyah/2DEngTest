cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu
#cimport cython.opengl.opengl as GL
from opengl.opengl cimport GLfloat


include "sdl2_constants.pxi"
from libc.stdint cimport uint32_t, uint16_t, uint8_t
from libc.stdlib cimport calloc, malloc, free
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, make_shared, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair

import gonlet

cdef class _shader:

    cdef  SDL2_gpu.GPU_Image * img
    cdef SDL2_gpu.GPU_ShaderBlock block
    cdef uint32_t v
    cdef uint32_t f
    cdef uint32_t p
    cdef float resolution[2]
    
    def __cinit__(self):
        self.variables={}
        self.resolution=[1920.,1080.]
        #self.id=string()
        #self.v, self.f, self.p=Uint32(),Uint32(),Uint32()
        #self.variables=NULL
        #self.block=NULL
        #vector[string,Uint32] self.variables
        #GPU_ShaderBlock self.block
        pass
    
    def __dealloc___(self):
        self.freeImg()
    
    
    def create(self,string id,string v_str,string f_str):
        v=SDL2_gpu.GPU_LoadShader(SDL2_gpu.GPU_VERTEX_SHADER, v_str.c_str())
        
        if not v:
            print ("Failed to load vertex shader: {}".format(SDL2_gpu.GPU_GetShaderMessage()))
        
        f=SDL2_gpu.GPU_LoadShader(SDL2_gpu.GPU_FRAGMENT_SHADER, f_str.c_str())
        
        if not f:
            print ("Failed to load fragment shader: {}".format(SDL2_gpu.GPU_GetShaderMessage()))
        
        self.p=SDL2_gpu.GPU_LinkShaders(v, f)
        
        if not self.p:
            print ("Failed to link shader: {}".format(SDL2_gpu.GPU_GetShaderMessage()))
        
        self.block = SDL2_gpu.GPU_LoadShaderBlock(self.p, "gpu_Vertex", "gpu_TexCoord", NULL, "gpu_ModelViewProjectionMatrix")

        #debe cambiarse por una imagen del gonlet
    
    def addImg(self,path : str):
        print ("loading: {}".format(path))
        self.img = SDL2_gpu.GPU_LoadImage(path.encode('utf8'))
        SDL2_gpu.GPU_SetSnapMode(self.img, SDL2_gpu.GPU_SNAP_NONE)
        SDL2_gpu.GPU_SetWrapMode(self.img, SDL2_gpu.GPU_WRAP_REPEAT, SDL2_gpu.GPU_WRAP_REPEAT)
    
    def freeImg(self):
        SDL2_gpu.GPU_FreeImage(self.img)
    
    def setImgShader(self):
        SDL2_gpu.GPU_SetShaderImage(self.img, self.getVar("tex1"), 1)

    
    def addVariable(self,idV: str):
        location = SDL2_gpu.GPU_GetUniformLocation(self.p, idV.encode('utf8'))
        self.variables[idV]=location
    
    def getVar(self,idV:str):
        return self.variables[idV]
    
    def getId(self):
        return id
    
    def activate(self):
        SDL2_gpu.GPU_ActivateShaderProgram(self.p, &self.block)
    
    def setdatashader(self):
        time = <GLfloat> SDL2.SDL_GetTicks()
        SDL2_gpu.GPU_SetUniformf(self.getVar("globalTime"), time)
        self.setImgShader()
        SDL2_gpu.GPU_SetUniformfv(self.getVar("resolution"),2,1,self.resolution)
        print (self.resolution)
    
    def deactivate(self):
        SDL2_gpu.GPU_DeactivateShaderProgram()


class shader(_shader):
    pass
    
