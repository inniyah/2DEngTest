#include <iostream>
#include <fstream>
#include <string.h>
#include <time.h>
#include <math.h>

#include "image.h"

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define SVPNG_LINKAGE static
#include "save_png.h"

Image::Image() : data(NULL), width(0), height(0), bytespp(0) {}

Image::Image(int w, int h, int bpp) : data(NULL), width(w), height(h), bytespp(bpp) {
    unsigned long nbytes = width*height*bytespp;
    data = new unsigned char[nbytes];
    memset(data, 0, nbytes);
}

Image::Image(const Image &img) : data(NULL), width(img.width), height(img.height), bytespp(img.bytespp) {
    unsigned long nbytes = width*height*bytespp;
    data = new unsigned char[nbytes];
    memcpy(data, img.data, nbytes);
}

Image::~Image() {
    if (data) delete [] data;
}

Image & Image::operator =(const Image &img) {
    if (this != &img) {
        if (data) delete [] data;
        width  = img.width;
        height = img.height;
        bytespp = img.bytespp;
        unsigned long nbytes = width*height*bytespp;
        data = new unsigned char[nbytes];
        memcpy(data, img.data, nbytes);
    }
    return *this;
}

ImageColor Image::get(int x, int y) {
    if (!data || x<0 || y<0 || x>=width || y>=height) {
        return ImageColor();
    }
    return ImageColor(data+(x+y*width)*bytespp, bytespp);
}

bool Image::set(int x, int y, ImageColor &c) {
    if (!data || x<0 || y<0 || x>=width || y>=height) {
        return false;
    }
    memcpy(data+(x+y*width)*bytespp, c.rgba, bytespp);
    if (bytespp==4 && c.bytespp<4) {
        data[(x+y*width)*bytespp+3] = 255;
    }
    return true;
}

bool Image::set(int x, int y, const ImageColor &c) {
    if (!data || x<0 || y<0 || x>=width || y>=height) {
        return false;
    }
    memcpy(data+(x+y*width)*bytespp, c.rgba, bytespp);
    return true;
}

int Image::get_bytespp() {
    return bytespp;
}

int Image::get_width() {
    return width;
}

int Image::get_height() {
    return height;
}

bool Image::flip_horizontally() {
    if (!data) return false;
    int half = width>>1;
    for (int i=0; i<half; i++) {
        for (int j=0; j<height; j++) {
            ImageColor c1 = get(i, j);
            ImageColor c2 = get(width-1-i, j);
            set(i, j, c2);
            set(width-1-i, j, c1);
        }
    }
    return true;
}

bool Image::flip_vertically() {
    if (!data) return false;
    unsigned long bytes_per_line = width*bytespp;
    unsigned char *line = new unsigned char[bytes_per_line];
    int half = height>>1;
    for (int j=0; j<half; j++) {
        unsigned long l1 = j*bytes_per_line;
        unsigned long l2 = (height-1-j)*bytes_per_line;
        memmove((void *)line,      (void *)(data+l1), bytes_per_line);
        memmove((void *)(data+l1), (void *)(data+l2), bytes_per_line);
        memmove((void *)(data+l2), (void *)line,      bytes_per_line);
    }
    delete [] line;
    return true;
}

unsigned char *Image::buffer() {
    return data;
}

void Image::clear() {
    memset((void *)data, 0, width*height*bytespp);
}

bool Image::scale(int w, int h) {
    if (w<=0 || h<=0 || !data) return false;
    unsigned char *tdata = new unsigned char[w*h*bytespp];
    int nscanline = 0;
    int oscanline = 0;
    int erry = 0;
    unsigned long nlinebytes = w*bytespp;
    unsigned long olinebytes = width*bytespp;
    for (int j=0; j<height; j++) {
        int errx = width-w;
        int nx   = -bytespp;
        int ox   = -bytespp;
        for (int i=0; i<width; i++) {
            ox += bytespp;
            errx += w;
            while (errx>=(int)width) {
                errx -= width;
                nx += bytespp;
                memcpy(tdata+nscanline+nx, data+oscanline+ox, bytespp);
            }
        }
        erry += h;
        oscanline += olinebytes;
        while (erry>=(int)height) {
            if (erry>=(int)height<<1) // it means we jump over a scanline
                memcpy(tdata+nscanline+nlinebytes, tdata+nscanline, nlinebytes);
            erry -= height;
            nscanline += nlinebytes;
        }
    }
    delete [] data;
    data = tdata;
    width = w;
    height = h;
    return true;
}

bool Image::modify_opacity(double opacity) {
    if (bytespp != RGBA) {
        return false;
    }
    for (int i=0; i<width; i++) {
        for (int j=0; j<height; j++) {
            ImageColor c = get(i, j);
            c.rgba[3] = (unsigned char)(double(c.rgba[3]) * opacity);
            set(i, j, c);
        }
    }
    return true;
}

void Image::set_to_color(const ImageColor color) {
    if (data) delete [] data;
    width = height = 1;
    bytespp = color.bytespp;
    unsigned long nbytes = bytespp * width * height;
    data = new unsigned char[nbytes];
    memcpy(data, color.rgba, nbytes);
}

static const char hex_digits[] = "0123456789ABCDEF";

bool Image::read_from_file(const char *filename) {
    if (data) delete [] data;
    data = NULL;
    width = height = bytespp = 0;

    unsigned char *pixel_data = stbi_load(filename, &width, &height, &bytespp, 0);

    if (!pixel_data || (bytespp!=GRAYSCALE && bytespp!=RGB && bytespp!=RGBA)) {
        return false;
    }
    //~ puts("\n");

    unsigned long nbytes = bytespp * width * height;
    data = new unsigned char[nbytes];
    memcpy(data, pixel_data, nbytes);

    //~ for (unsigned int n = 0; n < 32; n++) {
    //~     unsigned char c = data[n];
    //~     putc(hex_digits[c >> 4], stdout);
    //~     putc(hex_digits[c & 15], stdout);
    //~     putc(' ', stdout);
    //~ }
    //~ puts("\n");

    stbi_image_free(pixel_data);

    //~ std::cerr << width << "x" << height << "/" << bytespp*8 << "\n";
    return true;
}

bool Image::write_to_file(const char *filename) {
    if (!data || (bytespp!=RGB && bytespp!=RGBA)) {
        return false;
    }

    FILE* fp = fopen(filename, "wb");
    if (bytespp == RGB) {
        svpng(fp, width, height, data, 0);
    } else if (bytespp == RGBA) {
        svpng(fp, width, height, data, 1);
    }
    fclose(fp);

    return true;
}