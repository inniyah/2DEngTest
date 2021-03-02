cimport SDL2

import sys

print("Hello World")

cdef class _SDL2TestApplication:
    cdef SDL2.SDL_Window* win
    cdef SDL2.SDL_Renderer* ren
    cdef SDL2.SDL_Surface* bmp
    cdef SDL2.SDL_Texture* tex

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
