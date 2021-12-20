#!/usr/bin/env python3

import logging

import gonlet

class Game:
    def __init__(self):
        self.game_eng = gonlet.GameEngine()
        self.game_eng.setEventManager(self)
        self.game_eng.printRenderers()

    def __del__(self):
        self.game_eng.reset()
        self.game_eng = None

    def run(self):
        logging.info("Starting game!")
        self.game_eng.init()
        self.game_eng.printCurrentRenderer()

        img = gonlet.GameImage()
        img.load("img/small_test.png")

        width, height = self.game_eng.getScreenSize()
        self.pos_x = width // 2
        self.pos_y = height // 2

        while self.game_eng.processEvents():
            self.game_eng.clearScreen()
            img.blit(self.game_eng, self.pos_x, self.pos_y)
            self.game_eng.flipScreen()

        self.game_eng.quit()
        logging.info("Game finished!")

    def onKeyDown(self, event):
        sym = event.getKeysymSym()
        print(f"Key Down: {sym}")
        if sym == gonlet.SDLK_LEFT:
             self.pos_x -= 1
        if sym == gonlet.SDLK_RIGHT:
             self.pos_x += 1
        if sym == gonlet.SDLK_UP:
             self.pos_y -= 1
        if sym == gonlet.SDLK_DOWN:
             self.pos_y += 1

    def onKeyUp(self, event):
        sym = event.getKeysymSym()
        print(f"Key Up: {sym}")
