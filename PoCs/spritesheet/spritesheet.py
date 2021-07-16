#!/usr/bin/python3
# -*- coding: utf-8 -*-

# https://github.com/CCThomas/Sprite-Sheet-Maker/
#
# MIT License
#
# Copyright (c) 2017 Christopher Thomas
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

from PIL import Image

import os
import csv

# Finds next power of two for n. If n itself is a power of two then returns n
# https://www.geeksforgeeks.org/smallest-power-of-2-greater-than-or-equal-to-n/
def nextPowerOf2(n):
    p = 1
    if n and not (n & (n - 1)):
        return n
    while (p < n):
        p <<= 1
    return p

class SpriteSheet:
    """
    Sprite Sheet Class

    Note: PNG are the only File type Supported. If Implementing other file types...
          ... look at: Image.new("RGBA", (max_width, max_height)) in create_sprite_sheet()
    """

    def __init__(self):
        self.spritesheet = None
        self.sprites = []
        self.file_name = None
        self.csv_file_name = None
        self.max_row = 0
        self.max_col = 0

        """
        Determines if the Sprite Sheet uses a constant Width and Height for all Rows and Columns
        """
        self.constant_cell_width = 0
        self.constant_cell_height = 0

        """
        spritesheet_width & spritesheet_height are used to find the Max Width & Height.
        note: the row or column with the highest count may not have the max size
        ex:
        - 5 small sprites with width 1 in row 0: Total Width = 5
        - 3 large sprites withttps://github.com/CCThomas/Sprite-Sheet-Maker/h width 10 in row 1: Total Width = 30
        """
        self.spritesheet_row_widths = []
        self.spritesheet_col_heights = []

    def add_image(self, image_location, row, col):
        """
        Add Image to Sprite Sheet
        :param image_location:
        :param row: Row Number in Sprite Sheet
        :param col: Column Number in Sprite Sheet
        """
        if type(row) is not int:
            row = int(row)
        if type(col) is not int:
            col = int(col)

        # Extend the size of row_widths and col_height array,
        # if they are not long enough for the row/col param
        while len(self.spritesheet_row_widths) <= row:
            self.spritesheet_row_widths.append([])
        while len(self.spritesheet_col_heights) <= col:
            self.spritesheet_col_heights.append([])

        image = Image.open(image_location)

        # Increment the width and height of a row/col with the size of the image
        width, height = image.size
        self.spritesheet_row_widths[row].append(width)
        self.spritesheet_col_heights[col].append(height)

        self.sprites.append({
            "path": image_location,
            "image": image,
            "row_number": row,
            "column_number": col
        })

    def create_spritesheet(self, power_of_two=False, square=False):
        """Create Sprite Sheet"""

        cell_width = 0
        cell_height = 0
        if self.constant_cell_width == 1:
            cell_width = max([max(row_in) for row_in in self.spritesheet_row_widths])
            sum_width = cell_width * len(max(self.spritesheet_row_widths, key=len))
        else:
            sum_width = max([sum(row_in) for row_in in self.spritesheet_row_widths])

        if self.constant_cell_height == 1:
            cell_height = max([max(row_in) for row_in in self.spritesheet_col_heights])
            sum_height = cell_height * len(max(self.spritesheet_col_heights, key=len))
        else:
            sum_height = max([sum(row_in) for row_in in self.spritesheet_col_heights])

        if power_of_two:
            sum_width = nextPowerOf2(sum_width)
            sum_height = nextPowerOf2(sum_height)
        if square:
            if sum_width > sum_height:
                sum_height = sum_width
            else:
                sum_width = sum_height
        self.spritesheet = Image.new("RGBA", (sum_width, sum_height))  # RGBA is for PNG, Will not allow saving of GIF

        for sprite_info in self.sprites:
            image = sprite_info["image"]
            row_number = sprite_info["row_number"]
            column_number = sprite_info["column_number"]

            width, height = image.size

            if self.constant_cell_width == 1:
                left = cell_width * column_number
            else:
                left = self.sum_prev_cols_heights(row_number, column_number)
            if self.constant_cell_height == 1:
                upper = cell_height * row_number
            else:
                upper = self.sum_prev_rows_widths(row_number, column_number)
            right = left + width
            lower = upper + height

            box = (left, upper, right, lower)
            sprite_info["box"] = box
            self.spritesheet.paste(image, box)

    def save(self):
        """
        Saves the Spritesheet to self.file_name.
        """
        file_parts = self.file_name.split(".")
        file_extension = file_parts[len(file_parts)-1]
        if file_extension.lower() == "png":
            self.spritesheet.save(self.file_name, file_extension)
        else:
            print("File Extension", file_extension, "Not Supported")

        if self.csv_file_name:
            csv.register_dialect('SpritesheetDialect', quoting=csv.QUOTE_ALL, skipinitialspace=True)
            with open(self.csv_file_name, 'w') as f:
                writer = csv.writer(f, dialect='SpritesheetDialect')
                writer.writerow(['Name', 'Left', 'Upper', 'Width', 'Height']) # Headers
                for sprite_info in self.sprites:
                    name = '.'.join(os.path.basename(sprite_info["path"]).split('.')[0:-1])
                    left, upper, right, lower = sprite_info["box"]
                    row = sprite_info["row_number"]
                    column = sprite_info["column_number"]
                    writer.writerow([name, left, upper, right-left, lower-upper])

    def set_save_file(self, file_name):
        """Set File Name for Sprite Sheet"""
        self.file_name = file_name

    def set_save_csv_file(self, file_name):
        """Set CSV File Name for Sprite Sheet"""
        self.csv_file_name = file_name

    def set_constant_cell_height(self, constant_cell_height):
        """Set whether the Sprite Sheet will have a Constant Height"""
        self.constant_cell_height = constant_cell_height

    def set_constant_cell_width(self, constant_cell_width):
        """Set whether the Sprite Sheet will have a Constant Width"""
        self.constant_cell_width = constant_cell_width

    def sum_prev_rows_widths(self, row_number, column_number):
        """Sum the Previous Row Widths in a Col"""
        row_number = row_number - 1
        sum_prev_row = 0
        while row_number >= 0:
            sum_prev_row = sum_prev_row + self.spritesheet_col_heights[column_number][row_number]
            row_number = row_number - 1
        return sum_prev_row

    def sum_prev_cols_heights(self, row_number, column_number):
        """Sum the Previous Column Heights in a Row"""
        column_number = column_number - 1
        sum_prev_col = 0
        while column_number >= 0:
            sum_prev_col = sum_prev_col + self.spritesheet_row_widths[row_number][column_number]
            column_number = column_number - 1
        return sum_prev_col

import os
import sys
import math
import time
import argparse

FRAME_WIDTH = 96
FRAME_HEIGHT = 192

SPRITESHEET_WIDTH = 2048
SPRITESHEET_COLS = SPRITESHEET_WIDTH // FRAME_WIDTH

def main():
    parser = argparse.ArgumentParser(description='World Demo')
    parser.add_argument('-v', '--verbose', action="store_true", help="verbose output" )
    args = parser.parse_args()

    if args.verbose:
        print("~ Verbose!")
    else:
        print("~ Not so verbose")

    files = os.listdir("frames/")
    files.sort()
    print(files)

    frames_info = []
    index = 0
    for file in files :
        try:
            with Image.open("frames/" + file) as im :
                data = im.getdata()
                width = data.size[0]
                assert(width == FRAME_WIDTH)
                height = data.size[1]
                assert(height == FRAME_HEIGHT)

                row = index // SPRITESHEET_COLS
                col = index % SPRITESHEET_COLS

                frames_info.append((index, file, width, height, col, row))
                index += 1
        except:
            print(current_file + " is not a valid image")

    spritesheet = SpriteSheet()
    spritesheet.set_save_file("avatars.png")
    spritesheet.set_save_csv_file("avatars.csv")

    for (index, filename, width, height, col, row) in frames_info:
        print("#{}: '{}' ({}x{}) -> ({}, {})".format(index, filename, width, height, col, row))
        spritesheet.add_image("frames/" + filename, row, col)

    spritesheet.create_spritesheet(power_of_two=True, square=True)
    spritesheet.save()

if __name__ == '__main__':
    main()
