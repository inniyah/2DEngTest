#!/usr/bin/env python3

import logging
import shaders

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
        
        self.shad=shaders.shader()

        self.shad.create("shaders/v1.vert", "shaders/s1.frag")
        self.shad.addVariable("tex0")
        self.shad.activate()
        #self.shad.deactivate()

        #img = gonlet.GameImage()
        #img.load("img/small_test.png")
        self.pos=0
        self.lasttimer=0.0
        chart=gonlet.Chart()
        chart.load("assets/CharTemplate.json")
        s=chart.getSprite('5-1')
        self.imgdown=[chart.getSprite('0-0'), chart.getSprite('1-0'), chart.getSprite('0-0'), chart.getSprite('2-0')]
        self.imgleft=[chart.getSprite('0-1'), chart.getSprite('1-1'),chart.getSprite('0-1'),  chart.getSprite('2-1')]
        self.imgright=[chart.getSprite('0-2'), chart.getSprite('1-2'),chart.getSprite('0-2'),  chart.getSprite('2-2')]
        self.imgup=[chart.getSprite('0-3'), chart.getSprite('1-3'),chart.getSprite('0-3'),  chart.getSprite('2-3')]
        self.img=self.imgdown

        width, height = self.game_eng.getScreenSize()
        self.pos_x = width // 2
        self.pos_y = height // 2

        while self.game_eng.processEvents():
            self.moveplayer()
            self.game_eng.clearScreen()

            self.game_eng.setZ(1)
            self.img[int(self.pos)].blit(self.game_eng, self.pos_x, self.pos_y)

            self.game_eng.setZ(-1)
            s.blit(self.game_eng, 100, 100)

            self.game_eng.setZ(2)
            s.blit(self.game_eng, 200, 200)

            self.game_eng.flipScreen()

        self.game_eng.quit()
        logging.info("Game finished!")

    def moveplayer(self):
        timer=self.game_eng.getTicks()
        inc=timer-self.lasttimer
        self.lasttimer=timer
    
        if self.left:
            self.pos_x -= inc*.1
            self.pos+=inc*.007
            self.img=self.imgleft
        if self.right:
            self.pos_x += inc*.1
            self.pos+=inc*.007
            self.img=self.imgright
        if self.up:
            self.pos_y -= inc*.1
            self.pos+=inc*.007
            self.img=self.imgup
        if self.down:
            self.pos_y += inc*.1
            self.pos+=inc*.007
            self.img=self.imgdown
        
        if self.pos>=3:
            self.pos=0
    
    def onKeyDown(self, event):
        sym = event.getKeysymSym()
        #print(f"Key Down: {sym}")
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
        #print(f"Key Up: {sym}")
        if sym == gonlet.SDLK_LEFT:
             self.left=False
        if sym == gonlet.SDLK_RIGHT:
             self.right=False
        if sym == gonlet.SDLK_UP:
             self.up=False
        if sym == gonlet.SDLK_DOWN:
             self.down=False
