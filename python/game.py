#!/usr/bin/env python3

import logging

import gonlet

class Game:
    def __init__(self):
        self.game_eng = gonlet.GameEngine()
        self.game_eng.setEventManager(self)
        self.game_eng.printRenderers()
        #keys
        self.down=False
        self.up=False
        self.left=False
        self.right=False

    def __del__(self):
        self.game_eng.reset()
        self.game_eng = None

    def run(self):
        logging.info("Starting game!")
        self.game_eng.init()
        self.game_eng.printCurrentRenderer()

        img = gonlet.GameImage()
        img.load("img/small_test.png")
        chart=gonlet.Chart()
        chart.load("assets/CharTemplate.json")
        s=chart.getSprite('5-1')

        width, height = self.game_eng.getScreenSize()
        self.pos_x = width // 2
        self.pos_y = height // 2

        while self.game_eng.processEvents():
            self.moveplayer()
            self.game_eng.clearScreen()
            img.blit(self.game_eng, self.pos_x, self.pos_y)
            s.blit(self.game_eng, 100, 100)
            self.game_eng.flipScreen()

        self.game_eng.quit()
        logging.info("Game finished!")

    def moveplayer(self):
        if self.left:
            self.pos_x -= 1
        if self.right:
            self.pos_x += 1
        if self.up:
            self.pos_y -= 1
        if self.down:
            self.pos_y += 1
    
    def onKeyDown(self, event):
        sym = event.getKeysymSym()
        print(f"Key Down: {sym}")
        if sym == gonlet.SDLK_LEFT:
             self.left=True
        if sym == gonlet.SDLK_RIGHT:
             self.right=True
        if sym == gonlet.SDLK_UP:
             self.up=True
        if sym == gonlet.SDLK_DOWN:
             self.down=True

    def onKeyUp(self, event):
        sym = event.getKeysymSym()
        print(f"Key Up: {sym}")
        if sym == gonlet.SDLK_LEFT:
             self.left=False
        if sym == gonlet.SDLK_RIGHT:
             self.right=False
        if sym == gonlet.SDLK_UP:
             self.up=False
        if sym == gonlet.SDLK_DOWN:
             self.down=False
