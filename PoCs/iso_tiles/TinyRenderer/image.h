/*
 * Tiny Renderer, https://github.com/ssloy/tinyrenderer
 * Copyright Dmitry V. Sokolov
 * zlib license
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 * 1. The origin of this software must not be misrepresented; you must not
 *    claim that you wrote the original software. If you use this software
 *    in a product, an acknowledgment in the product documentation would be
 *    appreciated but is not required.
 *
 * 2. Altered source versions must be plainly marked as such, and must not
 *    be misrepresented as being the original software.
 *
 * 3. This notice may not be removed or altered from any source distribution.
 */

#pragma once

#ifndef IMAGE_H_F3EC386E_8881_11EA_90FD_10FEED04CD1C
#define IMAGE_H_F3EC386E_8881_11EA_90FD_10FEED04CD1C

#include <fstream>

struct ImageColor {
    unsigned char rgba[4];
    unsigned char bytespp;

    ImageColor() : rgba(), bytespp(1) {
        for (int i=0; i<4; i++) {
            rgba[i] = 0;
        }
    }

    ImageColor(unsigned char R, unsigned char G, unsigned char B, unsigned char A=255) : rgba(), bytespp(4) {
        rgba[0] = R;
        rgba[1] = G;
        rgba[2] = B;
        rgba[3] = A;
    }

    ImageColor(unsigned char v) : rgba(), bytespp(1) {
        for (int i=0; i<4; i++) {
            rgba[i] = 0;
        }
        rgba[0] = v;
    }

    ImageColor(const unsigned char *p, unsigned char bpp) : rgba(), bytespp(bpp) {
        for (int i=0; i<(int)bpp; i++) {
            rgba[i] = p[i];
        }
        for (int i=bpp; i<4; i++) {
            rgba[i] = 0;
        }
    }

    unsigned char& operator[](const int i) { return rgba[i]; }

    ImageColor operator *(float intensity) const {
        ImageColor res = *this;
        intensity = ( intensity > 1.f ? 1.f : (intensity < 0.f ? 0.f : intensity) );
        for (int i=0; i<4; i++) {
            res.rgba[i] = rgba[i]*intensity;
        }
        return res;
    }

    void add(ImageColor color) {
        for (int i=0; i<3; i++) {
            int c = int(rgba[i]) + int(color.rgba[i]);
            rgba[i] = (c < 256 ? c : 255);
        }
    }

};

class Image {
protected:
    unsigned char* data;
    int width;
    int height;
    int bytespp;

public:
    enum Format {
        GRAYSCALE=1, RGB=3, RGBA=4
    };

    Image();
    Image(int w, int h, int bpp);
    Image(const Image &img);

    bool read_from_file(const char *filename);
    bool write_to_file(const char *filename);

    void set_to_color(const ImageColor color);

    bool flip_horizontally();
    bool flip_vertically();
    bool scale(int w, int h);
    bool modify_opacity(double opacity);
    ImageColor get(int x, int y);
    bool set(int x, int y, ImageColor &c);
    bool set(int x, int y, const ImageColor &c);
    ~Image();
    Image & operator =(const Image &img);
    int get_width();
    int get_height();
    int get_bytespp();
    unsigned char *buffer();
    void clear();
};

#endif // IMAGE_H_F3EC386E_8881_11EA_90FD_10FEED04CD1C
