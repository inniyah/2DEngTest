#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import sys
import os
import math
import csv

from PIL import Image

#~ import matplotlib.pyplot as plt
#~ from matplotlib.colors import ListedColormap

#~ # This import registers the 3D projection, but is otherwise unused.
#~ from mpl_toolkits.mplot3d import Axes3D

parser = argparse.ArgumentParser(description="Process obj 3d models")
parser.add_argument("-n", "--name", help="tiles name", default=None, required=True)
args = parser.parse_args()

if args.name is None:
    print("You must give a tles name")
    sys.exit(-1)

# --------------------------------------

src_base_w = 32
src_base_h = 32

# --------------------------------------

tiles_info = []
with open('landh/landh.csv', mode='r') as csv_file:
    csv_reader = csv.DictReader(csv_file)
    line_count = 0
    for row in csv_reader:
        if line_count == 0:
            #~ print(f'Column names are {", ".join(row)}')
            line_count += 1
        tiles_info.append(row)
        line_count += 1
    print(f'Processed {line_count} lines.')
    print(f'Found {len(tiles_info)} tiles.')

# --------------------------------------

img_filename = 'landh/landh.png'

im_v = Image.open(img_filename)

rgb_im_v = im_v.convert('RGBA')

pixels = rgb_im_v.load()
for sy in range(rgb_im_v.size[1]):
    for sx in range(rgb_im_v.size[0]):
        r, g, b, a = pixels[sx, sy] # Get Pixel Value
        v = max(r, g, b) # Convert to Grey
        if v <= 1:
            v = 0
        pixels[sx, sy] = (v, v, v, 255)

cols_im_v = set()
grey_im_v = set()
for sy in range(rgb_im_v.size[1]):
    for sx in range(rgb_im_v.size[0]):
        c = r, g, b, a = rgb_im_v.getpixel((sx, sy))
        cols_im_v.add(c)
        grey_im_v.add((r + g + b) // 3)

#print(cols_im_v)
print(sorted(grey_im_v))
max_v = max(grey_im_v)
print(max_v)

#~ plt.imshow(rgb_im_v)
#~ plt.show()

del pixels

# --------------------------------------

m = 2.
y0 = 0. - 0.05
y1 = 1. + 0.05

#cA = 4*(1. - m)
#cB = -3.*cA/2.
#cC = (cA + 2.)/2

cA = 4. * (y1 - y0 - m)
cB = 6. * (m + y0 - y1)
cC = 3. * (y1 - y0) - 2 * m

print(cA, cB, cC)

X = [x / 255. for x in range(256)]
Y = [(cA * x*x*x + cB * x*x + cC * x + y0) for x in X]

#print(X, Y)

#~ plt.plot(X, Y)
#~ plt.show()

adj_curve = [max(0, min(255, int(255.*y))) for y in Y]

#~ plt.plot(X, adj_curve)
#~ plt.show()

# --------------------------------------

def is_monochromatic_image(img):
    extr = img.getextrema()
    a = 0
    for i in extr:
        if isinstance(i, tuple):
            a += abs(i[0] - i[1])
        else:
            a = abs(extr[0] - extr[1])
            break
    return a == 0

tiles_ignored = set()

for tile_info in tiles_info:
    #~ print(tile_info)
    hpos, vpos = int(tile_info['XCoord']), int(tile_info['YCoord'])

    img = Image.new('L', (src_base_w, src_base_h), 0)
    pixels = img.load()
    
    for voff in range(src_base_h):
        for hoff in range(src_base_w):
            rmap, gmap, bmap, amap = rgb_im_v.getpixel((hpos * src_base_w + hoff, vpos * src_base_h + voff))
            grey = (rmap + gmap + bmap) // 3
            x = grey / 255.
            a = int( 255. * (cA * x*x*x + cB * x*x + cC * x + y0) )
            pixels[hoff, voff] = int(a)

    if is_monochromatic_image(img) and tile_info['TileName'] not in ['A1', 'A2']:
        tile_info['img'] = None
        tiles_ignored.add(tile_info['TileName'])
    else:
        tile_info['img'] = img

print("Ignoring: ", tiles_ignored)
del pixels

# --------------------------------------

ifname = f"{args.name}.png"
if not os.path.exists(ifname):
    ifname = f"{args.name}.jpg"
if not os.path.exists(ifname):
    print("Texture '{args.name}' not found")
    sys.exit(-1)

tx_h, tx_w = 64, 92
texture = Image.open(ifname).convert('RGBA').resize((tx_w, tx_h), Image.ANTIALIAS)

# --------------------------------------

ntiles = len(tiles_info) - len(tiles_ignored)
print(f"{len(tiles_info)} - {len(tiles_ignored)} = {ntiles}")
for n in range(1, ntiles-1):
    if n * tx_w > math.ceil(ntiles/n) * tx_h:
        break

m = math.ceil(ntiles/n)

def next_power_of_2(x):  
    return 1 if x == 0 else 2**(x - 1).bit_length()

tx_p2size = next_power_of_2(max(n * tx_w, m * tx_h))

print(f"a) {n} x {m} = {n*m} -> {n * tx_w} x {m * tx_h} -> {tx_p2size}")

nh = tx_p2size // tx_w ; mh = math.ceil(ntiles/nh)
print(f"b) {nh} x {mh} = {nh*mh} -> {nh * tx_w} x {mh * tx_h} -> {tx_p2size}")

mv = tx_p2size // tx_h ; nv = math.ceil(ntiles/mv)
print(f"c) {nv} x {mv} = {nv*mv} -> {nv * tx_w} x {mv * tx_h} -> {tx_p2size}")

# --------------------------------------

img = Image.new('RGBA', (n * tx_w, m * tx_h), (0, 0, 0, 0))
pixels = img.load()

tid = 0
for tile_info in tiles_info:
    hpos, vpos = int(tile_info['XCoord']), int(tile_info['YCoord'])
    tile_img = tile_info['img']
    if tile_info['img'] is None:
        continue
    
    thpos = tx_w * (tid % n) ; tvpos = tx_h * (tid // n)
    for tvoff in range(tx_h):
        for thoff in range(tx_w):
            r, g, b, a = texture.getpixel((thoff, tvoff))
            hoff = thoff * src_base_w / tx_w
            voff = tvoff * src_base_h / tx_h
            a = tile_img.getpixel((hoff, voff))
            pixels[thpos + thoff, tvpos + tvoff] = (r, g, b, a)
    tid += 1
    
#~ plt.imshow(img)
#~ plt.show()

os.makedirs("tiles", exist_ok=True)
img.save(f"tiles/{args.name}.floors.png")

del pixels
