#!/usr/bin/env python3

import logging
import shaders
import math, random

import gonlet

class Lights:
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
        
        self.shad=shaders.LightShader()
        width, height = self.game_eng.getScreenSize()

        self.shad.init([width, height])
        self.shad.activate()
        #self.shad=shaders.shader()
        #self.shad.create("shaders/v1.vert", "shaders/light.frag")
        #self.shad.addVariable("tex0") #textura de los colores
        #self.shad.addVariable("tex1") #textura de las normales
        #self.shad.addVariable("tex2") #textura de las alturas
        #self.shad.addVariable("ambient") #va a ser una matriz con todas las variables ambientales (lightdir, lightcolor y ambientcolor)
        #self.shad.addVariable("lights") #va a ser una matriz (posiciones, colores de luces) 
        #self.shad.addVariable("screensize") #tamaño de la pantalla
        #self.shad.addVariable("TIME")

        self.shad.activate()
        #self.shad.SetUniformvec2("screensize", [width, height])

        
        # asignamos las variables ambientales
        self.shad.setSunLightDir([0.5, -0.0, -1.0])
        self.shad.setSunLightColor([0.5, 0.5, 0.5])
        self.shad.setAmbientColor([0.1, 0.1, 0.1])

        normal = gonlet.GameImage()
        normal.load("assets/VTiles1_Normals.png")
        heighttex = gonlet.GameImage()
        heighttex.load("assets/VTiles1_Depth.png")
        color = gonlet.GameImage()
        color.load("assets/VTiles1_Color.png")
        self.shad.setImgNormal(normal.getImageCapsule())
        self.shad.setImgDepth(heighttex.getImageCapsule())
        
        a=0.0
        centrox=width//2
        centroy=height//2
        radio=1

        #self.shad.setImgShader("tex1", normal.getImageCapsule())
        #self.shad.setImgShader("tex2", heighttex.getImageCapsule())

        while self.game_eng.processEvents():
            #ponemos la luz
            self.shad.activate()
            self.shad.setLightPos(0, [centrox+radio*math.cos(a), centroy+radio*math.sin(a), 70.0])
            self.shad.setLightColor(0, [5000.0, 2500.0, 2500.0])
            self.shad.setLightPos(1, [centrox + 100 +radio*math.cos(a), centroy + 100 +radio*math.sin(a), 70.0 ])
            self.shad.setLightColor(1, [0.0, 5000.0, 0.0])
            
            self.shad.setLightPos(2, [centrox - 100 +radio*math.cos(a), centroy - 100 +radio*math.sin(a), 70.0 ])
            self.shad.setLightColor(2, [0.0, 0.0, 5000.0])
            
            self.shad.setLightPos(3, [centrox - 100 +radio*math.cos(a), centroy + 100 +radio*math.sin(a), 70.0 ])
            self.shad.setLightColor(3, [0.0, 5000.0, 5000.0])
            
            self.shad.setLightPos(4, [centrox + 100 +radio*math.cos(a), centroy - 100 +radio*math.sin(a), 70.0 ])
            self.shad.setLightColor(4, [0.0, 5000.0, 5000.0])
            
            self.shad.sendDataShader()
            
            a+=0.001
            radio+=0.01
            
            #t=self.game_eng.getTicks()
            #self.shad.SetUniformi("TIME", t/200)
            self.game_eng.clearScreen()
            
            self.game_eng.setZ(1)
            
            color.blit(self.game_eng, width // 2, height // 2)
            
            self.shad.deactivate()
            self.game_eng.setZ(0)
            self.game_eng.drawCircle(centrox+radio*math.cos(a), centroy+radio*math.sin(a), 10, 255, 255, 255)
            self.game_eng.drawCircle(centrox+100+radio*math.cos(a), centroy+100+radio*math.sin(a), 10, 0, 255, 0)
            self.game_eng.drawCircle(centrox-100+radio*math.cos(a), centroy-100+radio*math.sin(a), 10, 0, 0, 255)
            self.game_eng.drawCircle(centrox-100+radio*math.cos(a), centroy+100+radio*math.sin(a), 10, 0, 255, 255)
            self.game_eng.drawCircle(centrox+100+radio*math.cos(a), centroy-100+radio*math.sin(a), 10, 0, 255, 255)
            self.shad.activate()
            
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
