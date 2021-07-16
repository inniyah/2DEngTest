#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import os
import sys
import argparse

from PyTexturePacker import Packer

def main():
    parser = argparse.ArgumentParser(description='Texture Packer')
    parser.add_argument('-v', '--verbose', action="store_true", help="verbose output" )
    args = parser.parse_args()

    if args.verbose:
        print("~ Verbose!")
    else:
        print("~ Not so verbose")

    packer = Packer.create(max_width=2048, max_height=2048, bg_color=0xffffff00)
    packer.pack("test_image/", "test_image%d", "")

if __name__ == '__main__':
    main()
