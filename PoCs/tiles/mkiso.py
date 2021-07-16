#!/usr/bin/python3
# -*- coding: utf-8 -*-

import glob
import os

from PIL import Image

iso_base_w = 128
iso_base_h = iso_base_w // 2

for n in ['1', '2', '3', '4']:
	for filename in glob.iglob('tiles/0/*.png', recursive=True):
		basename = os.path.basename(filename)
		print(basename)

		img = Image.new( 'RGBA', (iso_base_w, iso_base_h * 2), (0, 0, 0, 0))
		pixels = img.load()

		im = Image.open('tiles/{}/{}'.format(n, basename))
		rgb_im = im.convert('RGB')

		im_v = Image.open('tiles/0/{}'.format(basename))
		rgb_im_v = im_v.convert('RGB')

		def convert_coords(x, y):
			x = max(0, min(iso_base_w - 1, x))
			y = max(0, min(iso_base_h - 1, y))
			u = (2 * x - iso_base_w) / iso_base_w
			v = (2 * y - iso_base_h) / iso_base_h
			r = max(-1, min(1, u - v))
			s = max(-1, min(1, u + v))
			sx = max(0, min(rgb_im.width - 1, (r + 1) * rgb_im.width / 2))
			sy = max(0, min(rgb_im.height - 1, (s + 1) * rgb_im.height / 2))
			rv, gv, bv = rgb_im_v.getpixel((sx, sy))
			v = int(iso_base_h * (rv + gv + bv) / (3 * 255) / 2)
			return sx, sy, v

		for y in range(img.size[1]):
			for x in range(img.size[0]):
				if abs((iso_base_w - 1) / 2 - x) < (iso_base_h + 1) - abs(iso_base_h - 1 -2*y):
					sx, sy, v = convert_coords(x, y)
					r, g, b = rgb_im.getpixel((sx, sy))
					rv, gv, bv = rgb_im_v.getpixel((sx, sy))
					for i in range(0, v):
						pixels[x, iso_base_h + y - i] = (int(r/2), int(g/2), int(b/2), 255)

					sx, sy, v = convert_coords(x, y)
					r, g, b = rgb_im.getpixel((sx, sy))
					pixels[x, iso_base_h + y - v] = (r, g, b, 255)

		#img.show()
		try:
			os.makedirs('tiles/iso/{}'.format(n))
		except:
			pass
		img.save('tiles/iso/{}/{}'.format(n, basename))

	os.system('convert $(ls tiles/iso/{}/*.png | sort) -append iso_{}.png'.format(n, n))

	tsx_lines = [
		'<?xml version="1.0" encoding="UTF-8"?>',
		'<tileset name="img{}" tilewidth="64" tileheight="64" tilecount="104" columns="1">'.format(n),
		' <image source="img{}.png" width="64" height="6656"/>'.format(n),
		'</tileset>',
	]

	with open('map{}.tsx'.format(n), 'w') as out_file:
		for tsx_line in tsx_lines:
			out_file.write(tsx_line + '\n')
