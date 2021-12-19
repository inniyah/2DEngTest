#!/usr/bin/env python3

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

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

import gonlet
from game import Game

def run_game():
    g = Game()
    g.run()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

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

    if args.test is None:
        tests = [ 'game' ]
    else:
        tests = [ args.test ]

    for test in tests:
        logging.info(f"Running test: {test}")
        if test == 'game':
            run_game()

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

if __name__ == "__main__":
    main()
