#!/usr/bin/env python3

import argparse
import logging
import os
import sys
import shaders
import gonlet

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))
sys.path.append(os.path.abspath(os.path.join(MY_PATH, 'python')))


MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))

logging.basicConfig(level=logging.INFO)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

class runShader():
    
    def __init__(self):
        print("probando shaders")
        #inicializamos el engine
        self.game_eng = gonlet.GameEngine()
        self.game_eng.printRenderers()
        self.game_eng.init()
        width, height = self.game_eng.getScreenSize()
        self.shad=shaders.shader()
        self.shad.create(b"rain", b"shaders/v1.vert", b"shaders/rain.frag")
        self.img=gonlet.GameImage()
        self.img.load("assets/field.png")
        self.shad.addVariable("tex0")
        self.shad.addImg("assets/channel0.psd")
        self.shad.addVariable("tex1")
        self.shad.addVariable("globalTime")
        self.shad.addVariable("resolution")

    def run(self):
        while self.game_eng.processEvents():
            self.game_eng.clearScreen()
            self.shad.activate()
            #self.timer=game_eng.getTicks()
            self.shad.setdatashader()
            self.img.blit(self.game_eng, 0, 0)
            self.game_eng.flipScreen()
            self.shad.deactivate()
        self.shad.freeImg()

