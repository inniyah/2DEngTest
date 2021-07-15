cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu

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

cdef class _SDL2TestApplication:
    cdef SDL2.SDL_Window * win
    cdef SDL2.SDL_Renderer * ren
    cdef SDL2.SDL_Surface * bmp
    cdef SDL2.SDL_Texture * tex

    def __cinit__(self):
        if (SDL2.SDL_Init(SDL2.SDL_INIT_EVERYTHING) != 0):
            raise SystemExit(f"SDL_Init Error: {SDL2.SDL_GetError()}")

        self.win = SDL2.SDL_CreateWindow("Hello World!", 100, 100, 620, 387, SDL2.SDL_WINDOW_SHOWN)
        if not self.win:
            raise SystemExit(f"SDL_CreateWindow Error: {SDL2.SDL_GetError()}")

        self.ren = SDL2.SDL_CreateRenderer(self.win, -1, SDL2.SDL_RENDERER_ACCELERATED | SDL2.SDL_RENDERER_PRESENTVSYNC)
        if not self.ren:
            errmsg = f"SDL_CreateRenderer Error: {SDL2.SDL_GetError()}"
            if self.win:
                SDL2.SDL_DestroyWindow(self.win)
            SDL2.SDL_Quit()
            raise SystemExit(errmsg)

        self.bmp = SDL2.SDL_LoadBMP("img/grumpy-cat.bmp")
        if not self.bmp:
            errmsg = f"SDL_LoadBMP Error: {SDL2.SDL_GetError()}"
            if self.ren:
                SDL2.SDL_DestroyRenderer(self.ren)
            if self.win:
                SDL2.SDL_DestroyWindow(self.win)
            SDL2.SDL_Quit()
            raise SystemExit(errmsg)

        self.tex = SDL2.SDL_CreateTextureFromSurface(self.ren, self.bmp)
        if not self.tex:
            errmsg = f"SDL_CreateTextureFromSurface Error: {SDL2.SDL_GetError()}"
            if self.bmp:
                SDL2.SDL_FreeSurface(self.bmp)
            if self.ren:
                SDL2.SDL_DestroyRenderer(self.ren)
            if self.win:
                SDL2.SDL_DestroyWindow(self.win)
            SDL2.SDL_Quit()
            raise SystemExit(errmsg)

        SDL2.SDL_FreeSurface(self.bmp)

        for i in range(20):
            SDL2.SDL_RenderClear(self.ren)
            SDL2.SDL_RenderCopy(self.ren, self.tex, NULL, NULL)
            SDL2.SDL_RenderPresent(self.ren)
            SDL2.SDL_Delay(100)

        SDL2.SDL_DestroyTexture(self.tex)
        SDL2.SDL_DestroyRenderer(self.ren)
        SDL2.SDL_DestroyWindow(self.win)
        SDL2.SDL_Quit()

class SDL2TestApplication(_SDL2TestApplication):
    pass

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cdef class _SdlGpuTest:
    cdef SDL2_gpu.GPU_Target * _screen

    def __cinit__(self):
        self._screen = NULL

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

    def init(self):
        SDL2_gpu.GPU_SetPreInitFlags(SDL2_gpu.GPU_INIT_DISABLE_VSYNC)
        self._screen = SDL2_gpu.GPU_Init(800, 600, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        if self._screen == NULL:
            SDL2_gpu.GPU_LogError("GPU_Init Failed!")
            return -1

    def quit(self):
        SDL2_gpu.GPU_Quit()

    def test01(self):
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
            x[i] = dist(gen) * self._screen.w
            y[i] = dist(gen) * self._screen.h
            velx[i] = dist(gen) * self._screen.w / 10.0 - self._screen.w / 20.0
            vely[i] = dist(gen) * self._screen.h / 10.0 - self._screen.h / 20.0

        done = False
        cdef SDL2.SDL_Event event
        while not done:
            while SDL2.SDL_PollEvent(&event):
                if event.type == SDL2.SDL_QUIT:
                    done = True
                elif event.type == SDL2.SDL_KEYDOWN:
                    if event.key.keysym.sym == SDL2.SDLK_ESCAPE:
                        done = True
                    elif event.key.keysym.sym == SDL2.SDLK_EQUALS or event.key.keysym.sym == SDL2.SDLK_PLUS:
                        if numSprites < maxSprites:
                            numSprites += 100
                        SDL2_gpu.GPU_LogError("Sprites: %d\n", numSprites)
                        frameCount = 0
                        startTime = SDL2.SDL_GetTicks()
                    elif event.key.keysym.sym == SDL2.SDLK_MINUS:
                        if numSprites > 1:
                            numSprites -= 100
                        if numSprites < 1:
                            numSprites = 1
                        SDL2_gpu.GPU_LogError("Sprites: %d\n", numSprites)
                        frameCount = 0
                        startTime = SDL2.SDL_GetTicks()

            for i in range(numSprites):
                x[i] += velx[i] * dt
                y[i] += vely[i] * dt
                if x[i] < 0:
                    x[i] = 0
                    velx[i] = -velx[i]
                elif x[i] > self._screen.w:
                    x[i] = self._screen.w
                    velx[i] = -velx[i]
                if y[i] < 0:
                    y[i] = 0
                    vely[i] = -vely[i]
                elif y[i]> self._screen.h:
                    y[i] = self._screen.h
                    vely[i] = -vely[i]

            SDL2_gpu.GPU_Clear(self._screen)

            for i in range(numSprites):
                SDL2_gpu.GPU_Blit(image, NULL, self._screen, x[i], y[i])

            SDL2_gpu.GPU_Flip(self._screen)

            frameCount += 1
            if SDL2.SDL_GetTicks() - startTime > 5000:
                SDL2_gpu.GPU_LogError("Average FPS: %.2f\n", 1000.0 * frameCount / (SDL2.SDL_GetTicks() - startTime))
                frameCount = 0
                startTime = SDL2.SDL_GetTicks()

    # See: https://glusoft.com/tutorials/sdl2/sprite-animations
    def test02(self):
        SDL2.SDL_Init(SDL2.SDL_INIT_VIDEO)
        cdef SDL2_gpu.GPU_Target * window = SDL2_gpu.GPU_InitRenderer(SDL2_gpu.GPU_RENDERER_OPENGL_3, 200, 200, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        cdef SDL2_gpu.GPU_Image * hero = SDL2_gpu.GPU_LoadImage("img/adventurer-sheet.png")

        cdef vector[SDL2_gpu.GPU_Rect] rects
        cdef size_t nbRow = 11
        cdef size_t nbCol = 7
        cdef size_t widthSpr = 50
        cdef size_t heightSpr = 37

        for i in range(nbRow):
            for j in range(nbCol):
                rects.push_back(SDL2_gpu.GPU_Rect(<float> (j * widthSpr), <float> (i * heightSpr), <float> widthSpr, <float> heightSpr))

        idle1   = [ (0, 0), (0, 1), (0, 2), (0, 3) ]
        crouch  = [ (0, 4), (0, 5), (0, 6), (1, 0) ]
        run     = [ (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6) ]
        jump    = [ (2, 0), (2, 1), (2, 2), (2, 3) ]
        mid     = [ (2, 4), (2, 5), (2, 6), (3, 0) ]
        fall    = [ (3, 1), (3, 2) ]
        slide   = [ (3, 3), (3, 4), (3, 5), (3, 6), (4, 0) ]
        grab    = [ (4, 1), (4, 2), (4, 3), (4, 4) ]
        climb   = [ (4, 5), (4, 6), (5, 0), (5, 1), (5, 2) ]
        idle2   = [ (5, 3), (5, 4), (5, 5), (5, 6) ]
        attack1 = [ (6, 0), (6, 1), (6, 2), (6, 3), (6, 4) ]
        attack2 = [ (6, 5), (6, 6), (7, 0), (7, 1), (7, 2), (7, 3) ]
        attack3 = [ (7, 4), (7, 5), (7, 6), (8, 0), (8, 1), (8, 2) ]
        hurt    = [ (8, 3), (8, 4), (8, 5) ]
        die     = [ (8, 6), (9, 0), (9, 1), (9, 2), (9, 3), (9, 4), (9, 5) ]
        jump2   = [ (9, 6), (10, 0), (10, 1) ]

        current = idle1
        cdef int current_index = 0

        cdef double maxDuration = 150
        cdef double timeBuffer = 0
        cdef double timeElapsed = 0
        cdef SDL2.SDL_Event event

        done = False

        cdef SDL2.Uint32 startTime = SDL2.SDL_GetTicks()
        while not done:
            while SDL2.SDL_PollEvent(&event):
                if event.type == SDL2.SDL_QUIT:
                    done = True
                elif event.type == SDL2.SDL_KEYDOWN:
                    if event.key.keysym.sym == SDL2.SDLK_ESCAPE:
                        done = True
                    if event.key.keysym.scancode == SDL2.SDL_SCANCODE_Q:
                        current = idle1
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_W:
                        current = crouch
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_E:
                        current = run
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_R:
                        current = jump
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_T:
                        current = mid
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_Y:
                        current = fall
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_U:
                        current = slide
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_I:
                        current = grab
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_O:
                        current = climb
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_P:
                        current = idle2
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_A:
                        current = attack1
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_S:
                        current = attack2
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_D:
                        current = attack3
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_F:
                        current = hurt
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_G:
                        current = die
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_H:
                        current = jump
                    current_index = 0

            SDL2_gpu.GPU_Clear(window)
            currentPair = current[current_index]
            position = currentPair[0] + currentPair[1] * nbCol
            SDL2_gpu.GPU_BlitTransformX(hero, &rects[position], window, 75, 75, 0, 0, 0, 1, 1)
            SDL2_gpu.GPU_Flip(window)

            if SDL2.SDL_GetTicks() > startTime + maxDuration:
                startTime = SDL2.SDL_GetTicks()
                current_index += 1
                if current_index >= len(current):
                    current_index = 0

        SDL2_gpu.GPU_FreeImage(hero)
        SDL2_gpu.GPU_FreeTarget(window)
        SDL2_gpu.GPU_Quit()
        SDL2.SDL_Quit()

class SdlGpuTest(_SdlGpuTest):
    pass

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cdef class _GameEngine:
    cdef SDL2_gpu.GPU_Target * _screen

    def __cinit__(self):
        self._screen = NULL

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

    def init(self):
        SDL2_gpu.GPU_SetPreInitFlags(SDL2_gpu.GPU_INIT_DISABLE_VSYNC)
        self._screen = SDL2_gpu.GPU_Init(800, 600, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        if self._screen == NULL:
            SDL2_gpu.GPU_LogError("GPU_Init Failed!")
            return -1

    def quit(self):
        SDL2_gpu.GPU_Quit()

    def test01(self):
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
            x[i] = dist(gen) * self._screen.w
            y[i] = dist(gen) * self._screen.h
            velx[i] = dist(gen) * self._screen.w / 10.0 - self._screen.w / 20.0
            vely[i] = dist(gen) * self._screen.h / 10.0 - self._screen.h / 20.0

        done = False
        cdef SDL2.SDL_Event event
        while not done:
            while SDL2.SDL_PollEvent(&event):
                if event.type == SDL2.SDL_QUIT:
                    done = True
                elif event.type == SDL2.SDL_KEYDOWN:
                    if event.key.keysym.sym == SDL2.SDLK_ESCAPE:
                        done = True
                    elif event.key.keysym.sym == SDL2.SDLK_EQUALS or event.key.keysym.sym == SDL2.SDLK_PLUS:
                        if numSprites < maxSprites:
                            numSprites += 100
                        SDL2_gpu.GPU_LogError("Sprites: %d\n", numSprites)
                        frameCount = 0
                        startTime = SDL2.SDL_GetTicks()
                    elif event.key.keysym.sym == SDL2.SDLK_MINUS:
                        if numSprites > 1:
                            numSprites -= 100
                        if numSprites < 1:
                            numSprites = 1
                        SDL2_gpu.GPU_LogError("Sprites: %d\n", numSprites)
                        frameCount = 0
                        startTime = SDL2.SDL_GetTicks()

            for i in range(numSprites):
                x[i] += velx[i] * dt
                y[i] += vely[i] * dt
                if x[i] < 0:
                    x[i] = 0
                    velx[i] = -velx[i]
                elif x[i] > self._screen.w:
                    x[i] = self._screen.w
                    velx[i] = -velx[i]
                if y[i] < 0:
                    y[i] = 0
                    vely[i] = -vely[i]
                elif y[i]> self._screen.h:
                    y[i] = self._screen.h
                    vely[i] = -vely[i]

            SDL2_gpu.GPU_Clear(self._screen)

            for i in range(numSprites):
                SDL2_gpu.GPU_Blit(image, NULL, self._screen, x[i], y[i])

            SDL2_gpu.GPU_Flip(self._screen)

            frameCount += 1
            if SDL2.SDL_GetTicks() - startTime > 5000:
                SDL2_gpu.GPU_LogError("Average FPS: %.2f\n", 1000.0 * frameCount / (SDL2.SDL_GetTicks() - startTime))
                frameCount = 0
                startTime = SDL2.SDL_GetTicks()

    # See: https://glusoft.com/tutorials/sdl2/sprite-animations
    def test02(self):
        SDL2.SDL_Init(SDL2.SDL_INIT_VIDEO)
        cdef SDL2_gpu.GPU_Target * window = SDL2_gpu.GPU_InitRenderer(SDL2_gpu.GPU_RENDERER_OPENGL_3, 200, 200, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        cdef SDL2_gpu.GPU_Image * hero = SDL2_gpu.GPU_LoadImage("img/adventurer-sheet.png")

        cdef vector[SDL2_gpu.GPU_Rect] rects
        cdef size_t nbRow = 11
        cdef size_t nbCol = 7
        cdef size_t widthSpr = 50
        cdef size_t heightSpr = 37

        for i in range(nbRow):
            for j in range(nbCol):
                rects.push_back(SDL2_gpu.GPU_Rect(<float> (j * widthSpr), <float> (i * heightSpr), <float> widthSpr, <float> heightSpr))

        idle1   = [ (0, 0), (0, 1), (0, 2), (0, 3) ]
        crouch  = [ (0, 4), (0, 5), (0, 6), (1, 0) ]
        run     = [ (1, 1), (1, 2), (1, 3), (1, 4), (1, 5), (1, 6) ]
        jump    = [ (2, 0), (2, 1), (2, 2), (2, 3) ]
        mid     = [ (2, 4), (2, 5), (2, 6), (3, 0) ]
        fall    = [ (3, 1), (3, 2) ]
        slide   = [ (3, 3), (3, 4), (3, 5), (3, 6), (4, 0) ]
        grab    = [ (4, 1), (4, 2), (4, 3), (4, 4) ]
        climb   = [ (4, 5), (4, 6), (5, 0), (5, 1), (5, 2) ]
        idle2   = [ (5, 3), (5, 4), (5, 5), (5, 6) ]
        attack1 = [ (6, 0), (6, 1), (6, 2), (6, 3), (6, 4) ]
        attack2 = [ (6, 5), (6, 6), (7, 0), (7, 1), (7, 2), (7, 3) ]
        attack3 = [ (7, 4), (7, 5), (7, 6), (8, 0), (8, 1), (8, 2) ]
        hurt    = [ (8, 3), (8, 4), (8, 5) ]
        die     = [ (8, 6), (9, 0), (9, 1), (9, 2), (9, 3), (9, 4), (9, 5) ]
        jump2   = [ (9, 6), (10, 0), (10, 1) ]

        current = idle1
        cdef int current_index = 0

        cdef double maxDuration = 150
        cdef double timeBuffer = 0
        cdef double timeElapsed = 0
        cdef SDL2.SDL_Event event

        done = False

        cdef SDL2.Uint32 startTime = SDL2.SDL_GetTicks()
        while not done:
            while SDL2.SDL_PollEvent(&event):
                if event.type == SDL2.SDL_QUIT:
                    done = True
                elif event.type == SDL2.SDL_KEYDOWN:
                    if event.key.keysym.sym == SDL2.SDLK_ESCAPE:
                        done = True
                    if event.key.keysym.scancode == SDL2.SDL_SCANCODE_Q:
                        current = idle1
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_W:
                        current = crouch
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_E:
                        current = run
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_R:
                        current = jump
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_T:
                        current = mid
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_Y:
                        current = fall
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_U:
                        current = slide
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_I:
                        current = grab
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_O:
                        current = climb
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_P:
                        current = idle2
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_A:
                        current = attack1
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_S:
                        current = attack2
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_D:
                        current = attack3
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_F:
                        current = hurt
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_G:
                        current = die
                    elif event.key.keysym.scancode == SDL2.SDL_SCANCODE_H:
                        current = jump
                    current_index = 0

            SDL2_gpu.GPU_Clear(window)
            currentPair = current[current_index]
            position = currentPair[0] + currentPair[1] * nbCol
            SDL2_gpu.GPU_BlitTransformX(hero, &rects[position], window, 75, 75, 0, 0, 0, 1, 1)
            SDL2_gpu.GPU_Flip(window)

            if SDL2.SDL_GetTicks() > startTime + maxDuration:
                startTime = SDL2.SDL_GetTicks()
                current_index += 1
                if current_index >= len(current):
                    current_index = 0

        SDL2_gpu.GPU_FreeImage(hero)
        SDL2_gpu.GPU_FreeTarget(window)
        SDL2_gpu.GPU_Quit()
        SDL2.SDL_Quit()

class GameEngine(_GameEngine):
    pass
