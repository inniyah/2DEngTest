#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import logging
import os
import json
import sys

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))
sys.path.append(os.path.abspath(os.path.join(MY_PATH, 'python')))

from funcs import printAsJson

MY_PATH = os.path.normpath(os.path.abspath(os.path.dirname(__file__)))

logging.basicConfig(level=logging.INFO)

import gonlet

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
        if args.test == 'sdl2':
            app = gonlet.SDL2TestApplication()
        elif args.test == 'gpu1':
            gpu_test = gonlet.SdlGpuTest()
            gpu_test.printRenderers()
            gpu_test.init()
            gpu_test.printCurrentRenderer()
            gpu_test.test01()
            gpu_test.quit()
        elif args.test == 'gpu2':
            gpu_test = gonlet.SdlGpuTest()
            gpu_test.test02()

if __name__ == "__main__":
    main()
