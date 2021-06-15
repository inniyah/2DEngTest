include "imports.pxi"
include "tmxlite.pxi"
include "random.pxi"

cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu

print("Hello World")

#  -----------------------------------------------------------------------------

cdef class _SdlGpuContext:
    cdef SDL2_gpu.GPU_Target * _screen

    def __cinit__(self):
        print("SdlGpuContext __cinit__()")
        self._screen = NULL

    def __dealloc__(self):
        print("SdlGpuContext __dealloc__()")
        if self._screen != NULL:
            self._screen = NULL
            SDL2_gpu.GPU_Quit()
            SDL2.SDL_Quit()

    def init(self):
        SDL2.SDL_Init(SDL2.SDL_INIT_VIDEO)
        SDL2_gpu.GPU_SetPreInitFlags(SDL2_gpu.GPU_INIT_DISABLE_VSYNC)
        self._screen = SDL2_gpu.GPU_Init(800, 600, SDL2_gpu.GPU_DEFAULT_INIT_FLAGS)
        if self._screen == NULL:
            SDL2_gpu.GPU_LogError("GPU_Init Failed!")
            return -1

    def quit(self):
        self._screen = NULL
        SDL2_gpu.GPU_Quit()
        SDL2.SDL_Quit()

    def printRenderers(self):
        cdef SDL2_gpu.SDL_version compiled = SDL2_gpu.GPU_GetCompiledVersion()
        cdef SDL2_gpu.SDL_version linked = SDL2_gpu.GPU_GetLinkedVersion()

        if compiled.major != linked.major or \
           compiled.minor != linked.minor or \
           compiled.patch != linked.patch:
                SDL2_gpu.GPU_LogInfo("SDL_gpu v%d.%d.%d (compiled with v%d.%d.%d)\n",
                     linked.major, linked.minor, linked.patch, \
                     compiled.major, compiled.minor, compiled.patch)
        else:
            SDL2_gpu.GPU_LogInfo("SDL_gpu v%d.%d.%d\n",
                linked.major, linked.minor, linked.patch)

        cdef SDL2_gpu.GPU_RendererID * renderers = \
            <SDL2_gpu.GPU_RendererID*>malloc(sizeof(SDL2_gpu.GPU_RendererID) \
                *SDL2_gpu.GPU_GetNumRegisteredRenderers())
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

    def test(self):
        cdef SDL2_gpu.GPU_Image * image = SDL2_gpu.GPU_LoadImage("img/small_test.png")
        if image == NULL:
            SDL2_gpu.GPU_LogError("GPU_LoadImage Failed!")
            return -1

        SDL2_gpu.GPU_SetSnapMode(image, SDL2_gpu.GPU_SNAP_NONE)

        cdef SDL2.Uint32 startTime = SDL2.SDL_GetTicks()
        cdef long frameCount = 0

        done = False
        cdef SDL2.SDL_Event event
        while not done:
            while SDL2.SDL_PollEvent(&event):
                if event.type == SDL2.SDL_QUIT:
                    done = True
                elif event.type == SDL2.SDL_KEYDOWN:
                    if event.key.keysym.sym == SDL2.SDLK_ESCAPE:
                        done = True

            SDL2_gpu.GPU_Clear(self._screen)

            SDL2_gpu.GPU_Blit(image, NULL, self._screen, 0, 0)

            SDL2_gpu.GPU_Flip(self._screen)

            frameCount += 1
            if SDL2.SDL_GetTicks() - startTime > 5000:
                SDL2_gpu.GPU_LogError("Average FPS: %.2f\n", 1000.0 * frameCount / (SDL2.SDL_GetTicks() - startTime))
                frameCount = 0
                startTime = SDL2.SDL_GetTicks()

class SdlGpuContext(_SdlGpuContext):
    pass

#  -----------------------------------------------------------------------------

cdef class _TestMapLayer(_TmxLayer):

    def __cinit__(self, _TmxMap tmx_map, size_t idx):
        print("TmxMapLayer __cinit__()")

        cdef tmxlite.Map * c_map = tmx_map.map
        cdef int map_orientation = <int>c_map.getOrientation()
        if map_orientation != <int>tmxlite.Orientation_Orthogonal:
            print("Map needs to have the orientation 'Orthogonal'")
            return

        cdef vector[tmxlite.Layer.Ptr] c_layers = c_map.getLayers()
        cdef int layer_type = <int>c_layers.at(idx).get().getType()
        if layer_type != <int>tmxlite.Layer_Type_Tile:
            print("Layer needs to be of type 'Tile'")
            return

        cdef tmxlite.TileLayer * c_tile_layer = &c_layers.at(idx).get().getLayerAs[tmxlite.TileLayer]()

        if idx >= c_layers.size():
            print("The layer index does not exist")
            return

        cdef float chunk_size_x = 512.0
        cdef float chunk_size_y = 512.0

        cdef tmxlite.Vector2u tile_size = c_map.getTileSize()
        chunk_size_x = floor(chunk_size_x / tile_size.x) * tile_size.x;
        chunk_size_y = floor(chunk_size_y / tile_size.y) * tile_size.y;

        cdef unsigned map_tile_size_x = c_map.getTileSize().x
        cdef unsigned map_tile_size_y = c_map.getTileSize().y

        cdef float global_bounds_width = c_map.getBounds().width
        cdef float global_bounds_height = c_map.getBounds().height

        self._createChunks(c_map, c_tile_layer)

    def __dealloc__(self):
        print("TmxMapLayer __dealloc__()")

    cdef _createChunks(self, tmxlite.Map * c_map, tmxlite.TileLayer * c_tile_layer):
        pass

class TiledTestApplication(_TiledTestApplication):
    def getLayer(self, size_t idx):
        return _TestMapLayer(self.map, idx)
