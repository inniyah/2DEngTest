#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import logging
import math
import os
import sys

from funcs import printAsJson

if not sys.argv[0]:
    APP_DIR = os.path.abspath(os.path.join(os.path.dirname(__file__), os.pardir))
else:
    APP_DIR = os.path.abspath(os.path.join(os.path.dirname(sys.argv[0]), os.pardir))

logging.basicConfig(level=logging.INFO)

import tmxtest as test

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("-q", "--quiet", help="set logging to ERROR",
                        action="store_const", dest="loglevel",
                        const=logging.ERROR, default=logging.INFO)
    parser.add_argument("-d", "--debug", help="set logging to DEBUG",
                        action="store_const", dest="loglevel",
                        const=logging.DEBUG, default=logging.INFO)
    parser.add_argument("-t", "--test", dest="test", required=False, help="Test to run", default=None)
    args = parser.parse_args()

    if not args.test is None:
        logging.info(f"Running test: {args.test}")
        if  args.test == 'tmx':
            tmxapp = test.TiledTestApplication()
            lay1 = tmxapp.getLayer(0)
            lay1 = tmxapp.getLayer(1)
            lay1 = tmxapp.getLayer(2)
        elif args.test == 'gpu':
            gpu_test = test.SdlGpuContext()
            gpu_test.printRenderers()
            gpu_test.init()
            gpu_test.printCurrentRenderer()
            gpu_test.test()
            gpu_test.quit()

if __name__ == "__main__":
    main()
