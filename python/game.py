#!/usr/bin/env python3

import logging

import gonlet

class Game:
    def __init__(self):
        self.game_eng = gonlet.GameEngine()
        self.game_eng.printRenderers()

    def __del__(self):
        pass

    def run(self):
        logging.info("Starting game!")
        self.game_eng.init()
        self.game_eng.printCurrentRenderer()

        self.game_eng.clearScreen()
        self.game_eng.flipScreen()
        self.game_eng.processEvents()

        self.game_eng.quit()
        logging.info("Game finished!")
