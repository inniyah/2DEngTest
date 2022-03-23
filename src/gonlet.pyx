# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libc.stdint cimport uint32_t, uint16_t, uint8_t
from libc.stdlib cimport calloc, malloc, free
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, make_shared, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair
from cpython.ref cimport PyObject
from cython.operator cimport dereference as deref
from cpython.pycapsule cimport PyCapsule_New, PyCapsule_IsValid, PyCapsule_GetPointer, PyCapsule_GetName
from enum import IntEnum

cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu

import json

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cimport hub

def get():
    return hub.get_singleton()

def set(new_val):
    hub.set_singleton(new_val)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

include "sdl2_constants.pxi"

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

# Thread-safe solution using c++11
# See: https://stackoverflow.com/questions/40976880/canonical-way-to-generate-random-numbers-in-cython
cdef extern from "<random>" namespace "std":
    cdef cppclass mt19937:
        mt19937() # we need to define this constructor to stack allocate classes in Cython
        mt19937(unsigned int seed) # not worrying about matching the exact int type for seed
    cdef cppclass uniform_real_distribution[T]:
        uniform_real_distribution()
        uniform_real_distribution(T a, T b)
        T operator()(mt19937 gen) # ignore the possibility of using other classes for "gen"
    cdef cppclass discrete_distribution[T]:
        discrete_distribution()
        # The following constructor is really a more generic template class
        # but tell Cython it only accepts vector iterators
        discrete_distribution(vector.iterator first, vector.iterator last)
        T operator()(mt19937 gen)

import sys

print("Hello, Gonlet!")

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cdef class _Event:
    # https://wiki.libsdl.org/SDL_Event
    cdef SDL2.SDL_Event * _event

    def __cinit__(self):
        self._event = NULL

    @staticmethod
    cdef create(SDL2.SDL_Event * event):
        cdef _Event e = _Event()
        e._event = event
        return e

    # https://wiki.libsdl.org/SDL_KeyboardEvent
    #   https://wiki.libsdl.org/SDL_Keysym
    #     https://wiki.libsdl.org/SDL_Scancode
    def getKeysymScancode(self):
        return self._event.key.keysym.scancode

    # https://wiki.libsdl.org/SDL_KeyboardEvent
    #   https://wiki.libsdl.org/SDL_Keysym
    #     https://wiki.libsdl.org/SDL_Keycode
    def getKeysymSym(self):
        return self._event.key.keysym.sym

    # https://wiki.libsdl.org/SDL_KeyboardEvent
    #   https://wiki.libsdl.org/SDL_Keysym
    #     https://wiki.libsdl.org/SDL_Keymod
    def getKeysymMod(self):
        return self._event.key.keysym.mod


#~ cdef void free_ptr(object cap):
#~    # This should probably have some error checking in
#~    # or at very least clear any errors raised once it's done
#~    free(PyCapsule_GetPointer(cap, PyCapsule_GetName(cap)))

cdef class _GameEngine:
    cdef SDL2_gpu.GPU_Target * _screen

    def __cinit__(self):
        self._screen = NULL
        self._event_manager = self

    def __dealloc___(self):
        if self._screen == NULL:
            SDL2_gpu.GPU_FreeTarget(self._screen)

    def reset(self):
        if self._screen == NULL:
            SDL2_gpu.GPU_FreeTarget(self._screen)
        self._screen = NULL
        self._event_manager = self

    def getScreenCapsule(self):
        cdef const char *name = "SDL2_gpu.GPU_Target"
        return PyCapsule_New(<void *>self._screen, name, NULL)

    def setEventManager(self, event_manager):
        self._event_manager = event_manager

    def printRenderers(self):
        cdef SDL2_gpu.SDL_version compiled = SDL2_gpu.GPU_GetCompiledVersion()
        cdef SDL2_gpu.SDL_version linked = SDL2_gpu.GPU_GetLinkedVersion()

        if compiled.major != linked.major or compiled.minor != linked.minor or compiled.patch != linked.patch:
            SDL2_gpu.GPU_LogInfo("SDL_gpu v%d.%d.%d (compiled with v%d.%d.%d)\n",
                 linked.major, linked.minor, linked.patch, compiled.major, compiled.minor, compiled.patch)
        else:
            SDL2_gpu.GPU_LogInfo("SDL_gpu v%d.%d.%d\n",
                linked.major, linked.minor, linked.patch)

        cdef SDL2_gpu.GPU_RendererID * renderers = \
            <SDL2_gpu.GPU_RendererID*>malloc(sizeof(SDL2_gpu.GPU_RendererID) *SDL2_gpu.GPU_GetNumRegisteredRenderers())
        SDL2_gpu.GPU_GetRegisteredRendererList(renderers)
        SDL2_gpu.GPU_LogInfo("\nAvailable renderers:\n")
        for i in range(SDL2_gpu.GPU_GetNumRegisteredRenderers()):
            SDL2_gpu.GPU_LogInfo("* %s (%d.%d)\n",
                renderers[i].name, renderers[i].major_version, renderers[i].minor_version)

        cdef SDL2_gpu.GPU_RendererID order[SDL2_gpu.GPU_RENDERER_ORDER_MAX]
        cdef int order_size = 0
        SDL2_gpu.GPU_GetRendererOrder(&order_size, order)
        SDL2_gpu.GPU_LogInfo("Renderer init order:\n")
        for i in range(order_size):
            SDL2_gpu.GPU_LogInfo("%d) %s (%d.%d)\n",
                <int>(i+1), order[i].name, order[i].major_version, order[i].minor_version)
        SDL2_gpu.GPU_LogInfo("\n")

        free(renderers)

    def printCurrentRenderer(self):
        cdef SDL2_gpu.GPU_Renderer* renderer = SDL2_gpu.GPU_GetCurrentRenderer()
        cdef SDL2_gpu.GPU_RendererID id = renderer.id
        SDL2_gpu.GPU_LogInfo("Using renderer: %s (%d.%d)\n",
            id.name, id.major_version, id.minor_version)
        SDL2_gpu.GPU_LogInfo(" Shader versions supported: %d to %d\n\n",
            renderer.min_shader_version, renderer.max_shader_version)

    @staticmethod
    def getTicks():
        return SDL2.SDL_GetTicks()

    def setZ(self, z:float):
        #SDL2_gpu.GPU_MatrixMode(self._screen,SDL2_gpu.GPU_MODEL)
        #SDL2_gpu.GPU_PushMatrix()
        #SDL2_gpu.GPU_Translate(0, 0, z)
        
        #Set z in camera
        cdef SDL2_gpu.GPU_Camera camera = SDL2_gpu.GPU_GetCamera(self._screen)
        camera.z=z
        SDL2_gpu.GPU_SetCamera(self._screen, &camera)

    def getScreenSize(self):
        return self._screen.w, self._screen.h

    def clearScreen(self):
        SDL2_gpu.GPU_Clear(self._screen)

    def flipScreen(self):
        SDL2_gpu.GPU_Flip(self._screen)

    def init(self, width : int = 800, height : int = 600, renderer: int = SDL2_gpu.GPU_RENDERER_UNKNOWN):
        SDL2_gpu.GPU_SetPreInitFlags(SDL2_gpu.GPU_INIT_DISABLE_VSYNC)
        if renderer == SDL2_gpu.GPU_RENDERER_UNKNOWN:
            self._screen = SDL2_gpu.GPU_Init(width, height, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        else:
            self._screen = SDL2_gpu.GPU_InitRenderer(<SDL2_gpu.GPU_RendererEnum>renderer, width, height, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        if self._screen == NULL:
            SDL2_gpu.GPU_LogError("GPU_Init Failed!")
            return -1

        SDL2_gpu.GPU_SetDepthFunction(self._screen,SDL2_gpu.GPU_LESS)
        SDL2_gpu.GPU_AddDepthBuffer(self._screen)
        SDL2_gpu.GPU_SetDepthTest(self._screen,SDL2_gpu.GPU_TRUE)
        SDL2_gpu.GPU_SetDepthWrite(self._screen,SDL2_gpu.GPU_TRUE)
        SDL2_gpu.GPU_EnableCamera(self._screen, SDL2_gpu.GPU_TRUE)
    
    def drawRect(self,x1:float,y1:float,x2:float,y2:float):
        cdef SDL2_gpu.SDL_Color color=SDL2_gpu.GPU_MakeColor(0,255,0,255)
        SDL2_gpu.GPU_RectangleFilled(self._screen, x1, y1, x2, y2, color)
    
    def drawCircle(self,x:float,y:float,radius:float,r:int,g:int,b:int):
        cdef SDL2_gpu.SDL_Color color=SDL2_gpu.GPU_MakeColor(r,g,b,255)
        SDL2_gpu.GPU_CircleFilled(self._screen, x, y, radius, color)


    def quit(self):
        SDL2_gpu.GPU_Quit()

    def onKeyDown(self, event):
        sym = event.getKeysymSym()
        scancode = event.getKeysymScancode()
        mod = event.getKeysymMod()
        print(f"Key Down: {sym} / {scancode} / {mod}")

    def onKeyUp(self, event):
        sym = event.getKeysymSym()
        scancode = event.getKeysymScancode()
        mod = event.getKeysymMod()
        print(f"Key Up: {sym} / {scancode} / {mod}")

    def processEvents(self):
        cdef SDL2.SDL_Event sdl_event
        cdef bint done = False

        while SDL2.SDL_PollEvent(&sdl_event):
            event = _Event.create(&sdl_event)
            if sdl_event.type == SDL2.SDL_QUIT:
                done = True
            elif sdl_event.type == SDL2.SDL_KEYDOWN:
                if sdl_event.key.keysym.sym == SDL2.SDLK_ESCAPE:
                    done = True
                else:
                    self._event_manager.onKeyDown(event)
            elif sdl_event.type == SDL2.SDL_KEYUP:
                self._event_manager.onKeyUp(event)

        return not done

cdef class _GameImage:
    cdef SDL2_gpu.GPU_Image * _image

    def __cinit__(self):
        self._image = NULL

    def __dealloc___(self):
        if self._image == NULL:
            SDL2_gpu.GPU_FreeImage(self._image)

    def reset(self):
        if self._image == NULL:
            SDL2_gpu.GPU_FreeImage(self._image)
        self._image = NULL

    def load(self, filename : str):
        self.reset()

        self._image = SDL2_gpu.GPU_LoadImage(filename.encode('utf8'))
        if self._image == NULL:
            SDL2_gpu.GPU_LogError("GPU_LoadImage Failed!")
            return -1

        SDL2_gpu.GPU_SetSnapMode(self._image, SDL2_gpu.GPU_SNAP_NONE)

    def createnew(self,width,height):
       self._image= SDL2_gpu.GPU_CreateImage(width, height, SDL2_gpu.GPU_FORMAT_RGBA)

    def clear(self):
        SDL2_gpu.GPU_Clear(self._image.target)

    def loadtarget(self):
        SDL2_gpu.GPU_LoadTarget(self._image)
    
    def blitontarget(self,_GameImage target,pos_x,pos_y):
        cdef SDL2_gpu.GPU_Target *  screen= target._image.target
        SDL2_gpu.GPU_Blit(self._image, NULL, screen, pos_x, pos_y)
    
    def getImageCapsule(self):
        cdef const char *name = "SDL2_gpu.GPU_Image"
        return PyCapsule_New(<void *>self._image, name, NULL)

    def blit(self, _GameEngine eng, pos_x, pos_y):
        cdef SDL2_gpu.GPU_Target * screen = eng._screen
        SDL2_gpu.GPU_Blit(self._image, NULL, screen, pos_x, pos_y)
    
    #def blitrect(self,_GameEngine eng,
    #    GPU_BlitRect(GPU_Image* image, GPU_Rect* src_rect, GPU_Target* target, GPU_Rect* dest_rect)

    def test(self, _GameEngine eng):
        cdef SDL2_gpu.GPU_Target * screen = eng._screen

        cdef int maxSprites = 50000
        cdef int numSprites = 101
        cdef float dt = 0.010

        cdef mt19937 dice_gen = mt19937(5)
        cdef vector[double] dice_values = [1, 2, 3, 4, 5, 6] # autoconvert vector from Python list
        cdef discrete_distribution[int] dd = discrete_distribution[int](dice_values.begin(), dice_values.end())
        print("Dice: ", dd(dice_gen))

        cdef float * x = <float*>malloc(sizeof(float) * maxSprites)
        cdef float * y = <float*>malloc(sizeof(float) * maxSprites)
        cdef float * velx = <float*>malloc(sizeof(float) * maxSprites)
        cdef float * vely = <float*>malloc(sizeof(float) * maxSprites)

        cdef SDL2_gpu.GPU_Image * image = SDL2_gpu.GPU_LoadImage("img/small_test.png")
        if image == NULL:
            SDL2_gpu.GPU_LogError("GPU_LoadImage Failed!")
            return -1

        SDL2_gpu.GPU_SetSnapMode(image, SDL2_gpu.GPU_SNAP_NONE)

        cdef mt19937 gen = mt19937(5)
        cdef uniform_real_distribution[double] dist = uniform_real_distribution[double](0.0, 1.0)

        cdef SDL2.Uint32 startTime = SDL2.SDL_GetTicks()
        cdef long frameCount = 0
        for i in range(maxSprites):
            x[i] = dist(gen) * screen.w
            y[i] = dist(gen) * screen.h
            velx[i] = dist(gen) * screen.w / 10.0 - screen.w / 20.0
            vely[i] = dist(gen) * screen.h / 10.0 - screen.h / 20.0

        for i in range(numSprites):
            x[i] += velx[i] * dt
            y[i] += vely[i] * dt
            if x[i] < 0:
                x[i] = 0
                velx[i] = -velx[i]
            elif x[i] > screen.w:
                x[i] = screen.w
                velx[i] = -velx[i]
            if y[i] < 0:
                y[i] = 0
                vely[i] = -vely[i]
            elif y[i]> screen.h:
                y[i] = screen.h
                vely[i] = -vely[i]

        SDL2_gpu.GPU_Clear(screen)

        for i in range(numSprites):
            SDL2_gpu.GPU_Blit(image, NULL, screen, x[i], y[i])

        SDL2_gpu.GPU_Flip(screen)

cdef class _Sprite:
    cdef SDL2_gpu.GPU_Rect Rect
    cdef SDL2_gpu.GPU_Image * _image
    
    def __cinit__(self):
        self._image = NULL
    
    cdef create (self, SDL2_gpu.GPU_Image *image, x,y,w,h):
        self._image = image
        self.Rect.x=x
        self.Rect.y=y
        self.Rect.h=h
        self.Rect.w=w
    
    cdef setimg(self,_GameImage img):
        cdef _image=self.img._image
    
    
    def blit(self, _GameEngine eng, pos_x, pos_y):
        cdef SDL2_gpu.GPU_Target * screen = eng._screen
        #cdef SDL2_gpu.GPU_Rect target
        #target.x=pos_x
        #target.y=pos_y
        #target.h=self.Rect.h
        #target.w=self.Rect.w
        SDL2_gpu.GPU_Blit(self._image, &self.Rect, screen, pos_x, pos_y)
        
        #SDL2_gpu.GPU_BlitRect(self._image, &self.Rect, screen, &target)

cdef class _Chart:
    
    cdef SDL2_gpu.GPU_Image * _image

    def __cinit__(self):
        self._image = NULL
        self.rects={}
    
    def __dealloc___(self):
        if self._image == NULL:
            SDL2_gpu.GPU_FreeImage(self._image)

    def reset(self):
        if self._image == NULL:
            SDL2_gpu.GPU_FreeImage(self._image)
        self._image = NULL

    def loadimg(self, filename : str):
        self.reset()

        self._image = SDL2_gpu.GPU_LoadImage(filename.encode('utf8'))
        if self._image == NULL:
            SDL2_gpu.GPU_LogError("GPU_LoadImage Failed!")
            return -1

        SDL2_gpu.GPU_SetSnapMode(self._image, SDL2_gpu.GPU_SNAP_NONE)
        SDL2_gpu.GPU_SetBlendMode(self._image,SDL2_gpu.GPU_BLEND_NORMAL_ADD_ALPHA)
        SDL2_gpu.GPU_SetImageFilter( self._image, SDL2_gpu.GPU_FILTER_NEAREST )
        #SDL2_gpu.GPU_SetBlendFunction(self._image, SDL2_gpu.GPU_FUNC_SRC_ALPHA, SDL2_gpu.GPU_FUNC_ONE_MINUS_SRC_ALPHA, SDL2_gpu.GPU_FUNC_ONE, SDL2_gpu.GPU_FUNC_ZERO )
    
    def load(self, filename : str):
        with open(filename) as f:
            data=json.load(f)
        
        dir=filename[0:filename.rfind('/')+1]
        #Cargamos la imagen
        self.loadimg(dir+data['master'])
        del data['master']
        
        for i in data:
            self.rects[i]=SDL2_gpu.GPU_Rect(data[i][0],data[i][1],data[i][2],data[i][3])
    
    cdef _getSprite(self, name : str):
        Sprite= _Sprite()
        Sprite.Rect=self.rects[name]
        Sprite._image=self._image
        return Sprite
    
    def getSprite(self, name : str):
        return self._getSprite(name)


class Sprite(_Sprite):
    pass

class Chart(_Chart):
    pass

class GameEngine(_GameEngine):
    pass

class GameImage(_GameImage):
    pass

