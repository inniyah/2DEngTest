cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu
#cimport cython.opengl.opengl as GL
from opengl.opengl cimport GLfloat
from cpython.pycapsule cimport PyCapsule_New, PyCapsule_IsValid, PyCapsule_GetPointer, PyCapsule_GetName


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
    
    
    def create(self,v_str : str,f_str : str):
        v=SDL2_gpu.GPU_LoadShader(SDL2_gpu.GPU_VERTEX_SHADER, v_str.encode('utf8'))
        
        if not v:
            print ("Failed to load vertex shader: {}".format(SDL2_gpu.GPU_GetShaderMessage()))
        
        f=SDL2_gpu.GPU_LoadShader(SDL2_gpu.GPU_FRAGMENT_SHADER, f_str.encode('utf8'))
        
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
    
    def setImgShader(self,var:str,capsule):
        cdef const char *name = "SDL2_gpu.GPU_Image"
        cdef SDL2_gpu.GPU_Image * img = <SDL2_gpu.GPU_Image *> PyCapsule_GetPointer (capsule,name) 
        SDL2_gpu.GPU_SetShaderImage(img, self.getVar(var), 1)

    
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
    
    def SetUniformi(self,var:str,int b):
        SDL2_gpu.GPU_SetUniformi(self.getVar(var),b)
    
    def SetUniformf(self,var:str,float b):
        SDL2_gpu.GPU_SetUniformf(self.getVar(var),b)
    
    def SetUniformvec2(self,var:str,data):
        cdef float v[2] 
        v=data
        SDL2_gpu.GPU_SetUniformfv(self.getVar(var),2,1,v)

    def SetUniformvec3(self,var:str,data):
        cdef float v[3] 
        v=data
        SDL2_gpu.GPU_SetUniformfv(self.getVar(var),3,1,v)
    
    def SetUniformambient(self,var:str,data):
        cdef float v[9] 
        v = data
        SDL2_gpu.GPU_SetUniformfv(self.getVar(var),3,3,v)
    
    def SetUniformlights(self,var:str,data):
        cdef float v[6] 
        v = data
        SDL2_gpu.GPU_SetUniformfv(self.getVar(var),3,2,v)
    
    def deactivate(self):
        SDL2_gpu.GPU_DeactivateShaderProgram()


class shader(_shader):
    pass
    
