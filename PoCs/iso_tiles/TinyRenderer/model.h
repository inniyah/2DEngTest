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

#ifndef MODEL_H_F3EC37E2_8881_11EA_90FB_10FEED04CD1C
#define MODEL_H_F3EC37E2_8881_11EA_90FB_10FEED04CD1C

#include <vector>
#include <string>

#include "geometry.h"
#include "image.h"

class Model {
private:
    std::vector<Vec3f> m_verts;
    std::vector<std::vector<Vec3i> > m_faces; // attention, this Vec3i means vertex/uv/normal
    std::vector<Vec3f> m_norms;
    std::vector<Vec2f> m_uv;
    Image m_diffusemap;
    Image m_normalmap;
    //~ Image m_specularmap;
    ImageColor m_ambient;

    void load_texture(std::string path, std::string texfile, Image &img, const ImageColor color);
    bool load_obj_model(std::string filename);

public:
    Model(const char *filename);
    ~Model();
    int nverts();
    int nfaces();
    Vec3f normal(int iface, int nthvert);
    Vec3f normal(Vec2f uv);
    Vec3f vert(int i);
    Vec3f vert(int iface, int nthvert);
    Vec2f uv(int iface, int nthvert);
    ImageColor ambient();
    ImageColor diffuse(Vec2f uv);
    //~ float specular(Vec2f uv);
    std::vector<int> face(int idx);
    void modify(const Matrix & m);
    void invert_normals();
};

#endif // MODEL_H_F3EC37E2_8881_11EA_90FB_10FEED04CD1C
