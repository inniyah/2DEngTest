#!/usr/bin/env python3
# -*- coding: utf-8 -*-

# See: http://www.pythonstuff.org/glsl/normalmaps_from_heightmaps.html

'''
from height2bump import readHeight2Bump
result = readHeight2Bump( heightfilename, bumpfilename, options="tqa" )

result is 4-band PIL-Image containing x,y,z,h

or (as __main__):

height2bump.py -<options> <input_file> <output_file>
   calculates a bumpmap (normalmap) from the "R"-Channel of the input_file.
   options:
       s use 5x5-Sobel-Filter instead of 5x5-Scharr
       t write output_file only if older than input_file
         (and ignore missing input_file)
       a put heightmap into the alpha channel
       v verbose
       q really quiet
'''
import os, sys, time
from math import sqrt
from PIL import Image, ImageFilter, ImageChops

def height2bump( heightBand, filter="Scharr" ): # normal[0..2] band-array
    global verbose

    if filter == "Sobel":
        a1=1; a2=2; a3=0
        b1=1; b2=4; b3=6
    elif filter == "Scharr":           # 5x5 opt Scharr Filter from
        a1=21.38; a2=85.24; a3=0       # http://nbn-resolving.de/urn/resolver.pl?urn=urn:nbn:de:bsz:16-opus-9622
        b1= 5.96; b2=61.81; b3=120.46
    else:
        raise ValueError( "Unknown 'filter' argument '" + filter + "'" )
    if verbose:
        print(f"Filter: {filter}")
    a4=-a2; a5=-a1
    b4=b2;  b5=b1
    kernel = []
    kernel.append((a1*b1, a2*b1, a3*b1, a4*b1, a5*b1,
                   a1*b2, a2*b2, a3*b2, a4*b2, a5*b2,
                   a1*b3, a2*b3, a3*b3, a4*b3, a5*b3,
                   a1*b4, a2*b4, a3*b4, a4*b4, a5*b4,
                   a1*b5, a2*b5, a3*b5, a4*b5, a5*b5)) # x
    kernel.append((b1*a1, b2*a1, b3*a1, b4*a1, b5*a1,
                   b1*a2, b2*a2, b3*a2, b4*a2, b5*a2,
                   b1*a3, b2*a3, b3*a3, b4*a3, b5*a3,
                   b1*a4, b2*a4, b3*a4, b4*a4, b5*a4,
                   b1*a5, b2*a5, b3*a5, b4*a5, b5*a5)) # y

    # to get the scale factor, we look at the extreme case: vertical fall from 255 to 0:
    scale = 0.0
    for i, val in enumerate( kernel[0] ):
        if i % 5 < 5//2:
            scale += 255.0 * val
    scale /= 128.0
    if verbose:
        print(f"Scale = {scale}")

    r = heightBand.filter(ImageFilter.Kernel((5,5), kernel[0], scale=scale, offset=128.0))
    g = heightBand.filter(ImageFilter.Kernel((5,5), kernel[1], scale=scale, offset=128.0))
    b = ImageChops.constant(g, 128)
    rr = r.load()
    gg = g.load()
    bb = b.load()
    for y in range( r.size[1] ):
        for x in range( r.size[0] ):
            op = 1.0 - (rr[x,y]*2.0/255.0 - 1.0)**2 - (gg[x,y]*2.0/255.0 - 1.0)**2
            if op > 0.0:
                bb[x,y] = (int(128.0 + 128.0 * sqrt(op)),)
            else:
                bb[x,y] = (128,)
    return([r, g, b])

def usage():
    sys.exit(''''
Usage: height2bump.py [-<options>] <input_file> <output_file>
   calculates a bumpmap (normalmap) from the "R"-Channel of the input_file.
   options:
       s use 5x5-Sobel-Filter instead of 5x5-Scharr
       t write output_file only if older than input_file
         (and ignore missing input_file)
       a put heightmap into the alpha channel
       v verbose
       q really quiet
''')

def readHeight2Bump( infn, outfn, options="tqa" ):
    global verbose
    if options.find("s") >= 0:
        usekernel="Sobel"
    else:
        usekernel="Scharr"
    checktime   = options.find("t") >= 0
    alphaheight = options.find("a") >= 0
    verbose     = options.find("v") >= 0
    quiet       = options.find("q") >= 0

    if outfn.find(".") < 0:
        outfn += ".png"     # default extension

    infile_stamp = 0
    outfile_stamp = 0
    if checktime:
        try:
            infile_stamp = os.path.getmtime(infn)
        except:
            infile_stamp = 0
        try:
            outfile_stamp = os.path.getmtime(outfn)
        except:
            outfile_stamp = 0
        if verbose:
            print(f"Infile Time: {time.strftime('%m/%d/%Y %I:%M:%S %p', time.localtime(infile_stamp))}, (Epoch: {infile_stamp})")
        if verbose:
            print(f"Outfile Time: {time.strftime('%m/%d/%Y %I:%M:%S %p', time.localtime(outfile_stamp))}, (Epoch: {outfile_stamp})")

        if infile_stamp < outfile_stamp:
            if __name__ == "__main__":
                if quiet:
                    sys.exit()
                else:
                    sys.exit( "Infile is older than outfile or does not exist - nothing done" )
            else: # lib call - return expected result
                im = Image.open( outfn )
                return( im )
        if infile_stamp == 0 and outfile_stamp == 0:
            raise IOError( "Neither infile nor outfile exist" )

    if verbose:
        print(f"Read {infn}...")
    try:
        im = Image.open(infn)
    except:
        sys.exit( "Could not open " + infn)
    height = im.split()[0]
    normal = height2bump( height, filter=usekernel )
    if alphaheight:
        normal.extend([height])
        im = Image.merge( "RGBA", normal )
    else:
        im = Image.merge( "RGB", normal )

    if verbose:
        print(f"Write {outfn}...")
    try:
        im.save(outfn)
    except:
        sys.exit( "Could not save " + outfn)
    if verbose:
        print("Function completed !")
    if __name__ != "__main__":
        return( im )

if __name__ == "__main__":
    options = "" # default: check file time
    if len(sys.argv) == 4: # program name + 3 Arguments
        if sys.argv[1][0] == "-": # options
            options = sys.argv[1][1:]
            infn    = sys.argv[2]
            outfn   = sys.argv[3]
        else:
            usage()
    elif len(sys.argv) == 3: # program name + 2 Arguments
        infn  = sys.argv[1]
        outfn = sys.argv[2]
    else:
        usage()

dummy = readHeight2Bump( infn, outfn, options=options )
