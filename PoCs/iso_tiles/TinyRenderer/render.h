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

#ifndef RENDER_H_F3EC3828_8881_11EA_90FC_10FEED04CD1C
#define RENDER_H_F3EC3828_8881_11EA_90FC_10FEED04CD1C

#include "image.h"
#include "geometry.h"

extern Matrix ModelView;
extern Matrix Projection;

void viewport(int center_x, int center_y, int zoom_x, int zoom_y);
void projection(float coeff=0.f); // coeff = -1/c
void lookat(Vec3f eye, Vec3f center, Vec3f up);

struct IShader {
    virtual ~IShader();
    virtual Vec4f vertex(int iface, int nthvert) = 0;
    virtual bool fragment(Vec3f bar, ImageColor &color, Vec3f &normal) = 0;
};

void triangle(mat<4,3,float> &pts, IShader &shader, Image &image, float *zbuffer, bool reverse_pov = false, Vec3f *normals_buffer = nullptr);

#endif // RENDER_H_F3EC3828_8881_11EA_90FC_10FEED04CD1C
