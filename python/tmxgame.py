#!/usr/bin/env python3

import logging

import gonlet
import ctmx

class TmxGame:
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

        #test = ctmx.test("assets/map/orthogonal-outside.tmx")
        test = ctmx.test("assets/map/VTiles1.tmx")
        test.putScreenCapsule(self.game_eng.getScreenCapsule())

        self.lasttimer = 0.0

        width, height = self.game_eng.getScreenSize()
        self.pos_x = width // 2
        self.pos_y = height // 2

        while self.game_eng.processEvents():
            timer=self.game_eng.getTicks()
            inc=timer-self.lasttimer
            self.lasttimer=timer

            self.game_eng.clearScreen()
            test.render_map()
            self.game_eng.flipScreen()

        self.game_eng.quit()
        logging.info("Game finished!")
    
    def onKeyDown(self, event):
        sym = event.getKeysymSym()
        print(f"Key Down: {sym}")

    def onKeyUp(self, event):
        sym = event.getKeysymSym()
        print(f"Key Up: {sym}")
