cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu
cimport tmxlite.tmxlite as tmxlite

from libc.stdint cimport uint32_t, uint16_t, uint8_t
from libc.stdlib cimport calloc, malloc, free
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, make_shared, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair
from cpython.ref cimport PyObject
from cython.operator cimport dereference as deref
from enum import IntEnum

include "tmxlite.pxi"
include "sdl2_constants.pxi"

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


cdef class _GameEngine:
    cdef SDL2_gpu.GPU_Target * _screen

    def __cinit__(self):
        self._screen = NULL
        self._event_manager = self

    def reset(self):
        if self._screen == NULL:
            SDL2_gpu.GPU_FreeTarget(self._screen)
        self._screen = NULL
        self._event_manager = self

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

    def blit(self, _GameEngine eng, pos_x, pos_y):
        cdef SDL2_gpu.GPU_Target * screen = eng._screen
        SDL2_gpu.GPU_Blit(self._image, NULL, screen, pos_x, pos_y)

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


class GameEngine(_GameEngine):
    pass

class GameImage(_GameImage):
    pass

