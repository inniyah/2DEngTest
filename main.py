#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import test

#~ app = test.SDL2TestApplication()
app = test.TiledTestApplication()

gpu_test = test.SdlGpuTest()
gpu_test.printRenderers()
gpu_test.init()
gpu_test.printCurrentRenderer()
gpu_test.run()
gpu_test.quit()
