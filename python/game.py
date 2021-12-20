#!/usr/bin/env python3

import logging

import gonlet

class GameEngine(gonlet.GameEngine):
    def onKeyDown(self, event):
        sym = event.getKeysymSym()
        print(f"Key Down: {sym}")

    def onKeyUp(self, event):
        sym = event.getKeysymSym()
        print(f"Key Up: {sym}")

class Game:
    def __init__(self):
        self.game_eng = GameEngine()
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

        while self.game_eng.processEvents():
            self.game_eng.clearScreen()
            img.blit(self.game_eng)
            self.game_eng.flipScreen()

        self.game_eng.quit()
        logging.info("Game finished!")
