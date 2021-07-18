#include <vector>
#include <limits>
#include <iostream>
#include <cmath>
#include <sys/stat.h>
#include <libgen.h>

#include "image.h"
#include "model.h"
#include "geometry.h"
#include "render.h"

#include "inipp.h"
#include "arghelper.h"

#define SVPNG_LINKAGE static
#include "save_png.h"

#ifdef __cplusplus
extern "C" {
#endif

double str2dbl(const char *s);

#ifdef __cplusplus
}
#endif


Model *model = NULL;

static int width  = 350;
static int height = 600;

static Vec3f       eye(3,3,3);
static Vec3f    center(0,0,0);
static Vec3f        up(0,1,0);

static Vec3f light1_dir(1,3,2);
static Vec3f light2_dir(1,0,4);
static Vec3f light3_dir(4,0,2);

static double global_opacity = 1;
static double drawing_scale = 1;
static double viewport_zoom = 100;
static double viewport_aspect = 1;
static double viewport_offset_x = 0;
static double viewport_offset_y = 0;

static std::string input_filename, output_filename;

// Matrices

Matrix translationMatrix(Vec3f v) {
    Matrix Tr = Matrix::identity();
    Tr[0][3] = v.x;
    Tr[1][3] = v.y;
    Tr[2][3] = v.z;
    return Tr;
}

Matrix zoomMatrix(float factor) {
    Matrix Z = Matrix::identity();
    Z[0][0] = Z[1][1] = Z[2][2] = factor;
    return Z;
}

Matrix xRotationMatrix(float cosangle, float sinangle) {
    Matrix R = Matrix::identity();
    R[1][1] = R[2][2] = cosangle;
    R[1][2] = -sinangle;
    R[2][1] =  sinangle;
    return R;
}

Matrix yRotationMatrix(float cosangle, float sinangle) {
    Matrix R = Matrix::identity();
    R[0][0] = R[2][2] = cosangle;
    R[0][2] =  sinangle;
    R[2][0] = -sinangle;
    return R;
}

Matrix zRotationMatrix(float cosangle, float sinangle) {
    Matrix R = Matrix::identity();
    R[0][0] = R[1][1] = cosangle;
    R[0][1] = -sinangle;
    R[1][0] =  sinangle;
    return R;
}

// Rendering

struct Shader : public IShader {
    mat<2,3,float> varying_uv;  // triangle uv coordinates, written by the vertex shader, read by the fragment shader
    mat<4,3,float> varying_tri; // triangle coordinates (clip coordinates), written by VS, read by FS
    mat<3,3,float> varying_nrm; // normal per vertex to be interpolated by FS
    mat<3,3,float> ndc_tri;     // triangle in normalized device coordinates

    virtual Vec4f vertex(int iface, int nthvert) {
        varying_uv.set_col(nthvert,
            model->uv(iface, nthvert));
        varying_nrm.set_col(nthvert,
            proj<3>((Projection * ModelView).invert_transpose() * embed<4>(model->normal(iface, nthvert), 0.f)));

        Vec4f gl_Vertex = Projection * ModelView * embed<4>(model->vert(iface, nthvert));
        varying_tri.set_col(nthvert, gl_Vertex);
        ndc_tri.set_col(nthvert, proj<3>(gl_Vertex/gl_Vertex[3]));

        return gl_Vertex;
    }

    virtual bool fragment(Vec3f bar, ImageColor &color, Vec3f &normal) {
        color = model->ambient();

        Vec3f bn = (varying_nrm * bar).normalize();
        Vec2f uv = varying_uv * bar;

        mat<3,3,float> A;
        A[0] = ndc_tri.col(1) - ndc_tri.col(0);
        A[1] = ndc_tri.col(2) - ndc_tri.col(0);
        A[2] = bn;

        mat<3,3,float> AI = A.invert();

        Vec3f i = AI * Vec3f(varying_uv[0][1] - varying_uv[0][0], varying_uv[0][2] - varying_uv[0][0], 0);
        Vec3f j = AI * Vec3f(varying_uv[1][1] - varying_uv[1][0], varying_uv[1][2] - varying_uv[1][0], 0);

        mat<3,3,float> B;
        B.set_col(0, i.normalize());
        B.set_col(1, j.normalize());
        B.set_col(2, bn);

        Vec3f n = (B*model->normal(uv)).normalize();

        float diff_light1 = std::max(0.f, n * light1_dir);
        float diff_light2 = std::max(0.f, n * light2_dir);
        float diff_light3 = std::max(0.f, n * light3_dir);

        float diff = (diff_light1 + diff_light2 + diff_light3) * 0.5;
        ImageColor color_diff = (model->diffuse(uv) * diff);

        color.add(color_diff);

        normal = n;
        return false;
    }
};

// Configuration

static bool endsWith(const std::string& s, const std::string& suffix) {
    return s.size() >= suffix.size() && s.substr(s.size() - suffix.size()) == suffix;
}

static std::vector<std::string> split(const std::string & s, const std::string & delimiter, const bool & removeEmptyEntries = false) {
    std::vector<std::string> tokens;

    for (size_t start = 0, end; start < s.length(); start = end + delimiter.length()) {
         size_t position = s.find(delimiter, start);
         end = position != std::string::npos ? position : s.length();

         std::string token = s.substr(start, end - start);
         if (!removeEmptyEntries || !token.empty()) {
             tokens.push_back(token);
         }
    }

    if (!removeEmptyEntries && (s.empty() || endsWith(s, delimiter))) {
        tokens.push_back("");
    }

    return tokens;
}

static bool parseVec3f(const std::string str, Vec3f & v) {
    if (str.length()) {
        std::vector<std::string> subs = split(str, ",", false);
        int i = 0;
        for (auto & sub : subs) {
            v[i++] = str2dbl(sub.c_str());
        }
    }
    return true;
}

static void readConfig(const std::string filename) {
    inipp::Ini<char> ini;
    std::ifstream is(filename);
    ini.parse(is);

    ini.default_section(ini.sections["CONFIG"]);
    ini.interpolate();

    if (dsr::verbose) {
        std::cout << std::endl << "Config file:" << std::endl << std::endl;
        ini.generate(std::cout);
    }

    inipp::extract(ini.sections["CONFIG"]["width"], width);
    inipp::extract(ini.sections["CONFIG"]["height"], height);
    //~ std::cout << width;
    //~ std::cout << height;

    inipp::extract(ini.sections["CONFIG"]["scale"], drawing_scale);

    inipp::extract(ini.sections["CONFIG"]["zoom"], viewport_zoom);
    inipp::extract(ini.sections["CONFIG"]["aspect"], viewport_aspect);
    inipp::extract(ini.sections["CONFIG"]["offset_x"], viewport_offset_x);
    inipp::extract(ini.sections["CONFIG"]["offset_y"], viewport_offset_y);

    std::string str;

    inipp::extract(ini.sections["CONFIG"]["light1_dir"], str);
    parseVec3f(str, light1_dir);
    //~ std::cout << light1_dir;

    inipp::extract(ini.sections["CONFIG"]["light2_dir"], str);
    parseVec3f(str, light2_dir);
    //~ std::cout << light2_dir;

    inipp::extract(ini.sections["CONFIG"]["light3_dir"], str);
    parseVec3f(str, light3_dir);
    //~ std::cout << light3_dir;

    inipp::extract(ini.sections["CONFIG"]["eye_pos"], str);
    parseVec3f(str, eye);
    //~ std::cout << eye;

    inipp::extract(ini.sections["CONFIG"]["center_pos"], str);
    parseVec3f(str, center);
    //~ std::cout << center;

    inipp::extract(ini.sections["CONFIG"]["up_dir"], str);
    parseVec3f(str, up);
    //~ std::cout << up;
}

static inline bool file_exists(const std::string & name) {
    struct stat buffer;   
    return (stat (name.c_str(), &buffer) == 0); 
}

static int mkpath(const char * dir, mode_t mode = S_IRWXU) {
    struct stat sb;
    if (!dir) {
        errno = EINVAL;
        return 1;
    }
    if (!stat(dir, &sb))
        return 0;
    mkpath(dirname(strdupa(dir)), mode);
    return mkdir(dir, mode);
}

// Main program

int main (int argc, const char * const * argv, const char * const * envp) {
    std::string prgpath = "./";
    std::string prgname = std::string(argv[0]);
    size_t slash = prgname.find_last_of("/\\");
    if (slash != std::string::npos) {
        prgpath = prgname.substr(0, slash) + "/";
    }

    std::string zbuffer_output_filename;

    std::string cfgfile = prgpath + "/config.ini";

    dsr::ArgumentHelper ah;

    bool overwrite_output = false, reverse_pov = false, invert_normals = false;
    bool mirror_x = false, mirror_z = false, mirror_xz = false;
    double angle_y = 0;
    Matrix mod_matrix = Matrix::identity();

    ah.new_string("input_filename.obj", "The name of the input file", input_filename);
    ah.new_string("output_filename.png", "The name of the output file", output_filename);
    ah.new_flag('w', "overwrite", "Overwrite output", overwrite_output);
    ah.new_flag('x', "xmirror", "Mirror along the X plane", mirror_x);
    ah.new_flag('z', "zmirror", "Mirror along the Z plane", mirror_z);
    ah.new_flag('d', "dmirror", "Mirror along the diagonal XZ plane", mirror_xz);
    ah.new_flag('r', "reverse", "Reverse point of view", reverse_pov);
    ah.new_flag('i', "invertnormals", "Invert normals", invert_normals);
    ah.new_named_double('a', "angle", "angle in degrees", "Angle to rotate around the Y axis in degrees", angle_y);
    ah.new_named_double('o', "opacity", "opacity (0.0 - 1.0)", "opacity between 0.0 (transparent) and 1.0 (opaque)", global_opacity);
    ah.new_named_string('C', "config", "config.ini", "Use a certain config file", cfgfile);
    ah.new_named_string('Z', "zbuffer", "zbuffer_output.png", "Dump the zbuffer", zbuffer_output_filename);

    ah.set_description("Tiny Renderer");
    ah.set_author("Miriam Ruiz <miriam@debian.org>");
    ah.set_version(0.1f);
    ah.set_build_date(__DATE__);

    ah.process(argc, argv);
    if (dsr::verbose)
        ah.write_values(std::cout);

    if (!overwrite_output && file_exists(output_filename)) {
        return EXIT_FAILURE;
    }

    if (!overwrite_output && zbuffer_output_filename.length() && file_exists(zbuffer_output_filename)) {
        return EXIT_FAILURE;
    }

    if (global_opacity < 0.0) global_opacity = 0.0;
    if (global_opacity > 1.0) global_opacity = 1.0;

    readConfig(cfgfile);
    width = round(width * drawing_scale);
    height = round(height * drawing_scale);
    viewport_zoom = viewport_zoom * drawing_scale;
    viewport_offset_x = viewport_offset_x * drawing_scale;
    viewport_offset_y = viewport_offset_y * drawing_scale;

    float *zbuffer = new float[width*height];
    for (int i=width*height; i--; zbuffer[i] = -std::numeric_limits<float>::max());

    Vec3f *normals_buffer = new Vec3f[width*height];

    Image frame(width, height, Image::RGBA);
    lookat(eye, center, up);

    double viewport_aspect_sq = sqrt(fabs(viewport_aspect));
    viewport(
        width / 2. + viewport_offset_x,
        height / 2. + viewport_offset_y,
        viewport_zoom * viewport_aspect_sq,
        viewport_zoom / viewport_aspect_sq
    );

    projection(-1.f/(eye-center).norm());
    light1_dir = proj<3>((Projection*ModelView*embed<4>(light1_dir, 0.f))).normalize();
    light2_dir = proj<3>((Projection*ModelView*embed<4>(light2_dir, 0.f))).normalize();
    light3_dir = proj<3>((Projection*ModelView*embed<4>(light3_dir, 0.f))).normalize();

    if (mirror_x) {
        mod_matrix[0][0] = -1;
        mod_matrix[0][3] = 1;
    }

    if (mirror_z) {
        mod_matrix[2][2] = -1;
        mod_matrix[2][3] = 1;
    }

    if (mirror_x) {
        mod_matrix[0][0] = -1;
        mod_matrix[0][3] = 1;
    }

    if (mirror_xz) {
        mod_matrix[0][2] = mod_matrix[0][0];
        mod_matrix[2][0] = mod_matrix[2][2];
        mod_matrix[0][0] = mod_matrix[2][2] = 0;
    }

    mod_matrix = mod_matrix
        * translationMatrix(Vec3f(.5, 0, .5))
        * yRotationMatrix(cos(angle_y * M_PI / 180), sin(angle_y * M_PI / 180))
        * translationMatrix(Vec3f(-.5, 0, -.5));
    std::cout << mod_matrix;

    if (true) {
        model = new Model(input_filename.c_str());
        model->modify(mod_matrix);
        if (invert_normals) model->invert_normals();
        Shader shader;
        for (int i=0; i<model->nfaces(); i++) {
            for (int j=0; j<3; j++) {
                shader.vertex(i, j);
            }
            triangle(shader.varying_tri, shader, frame, zbuffer, reverse_pov, normals_buffer);
        }
        delete model;
    }

    if (global_opacity < 0.99) frame.modify_opacity(global_opacity);

    std::string output_path = "./";
    size_t output_last_slash = output_filename.find_last_of("/\\");
    if (output_last_slash != std::string::npos) {
        output_path = output_filename.substr(0, output_last_slash) + "/";
    }
    mkpath(output_path.c_str());

    ImageColor black(0, 0, 0);
    for (int y = 0; y < frame.get_height(); ++y) {
        for (int x = 0; x < frame.get_width(); ++x) {
            float z = zbuffer[width * y + x];
            Vec3f & n = normals_buffer[width * y + x];
            if (n[0] || n[1] || n[1]) {
                if (x > 0) {
                    if (n*normals_buffer[width * y + (x - 1)] < 0.1)
                        frame.set(x, y, black);
                    if (fabs(zbuffer[width * y + (x - 1)] - z) > 0.15)
                        frame.set(x, y, black);
                } else frame.set(x, y, black);
                if (x < frame.get_width() - 1) {
                    if (n*normals_buffer[width * y + (x + 1)] < 0.1)
                        frame.set(x, y, black);
                    if (fabs(zbuffer[width * y + (x + 1)] - z) > 0.15)
                        frame.set(x, y, black);
                } else frame.set(x, y, black);
                if (y > 0) {
                    if (n*normals_buffer[width * (y - 1) + x] < 0.1)
                        frame.set(x, y, black);
                    if (fabs(zbuffer[width * (y - 1) + x] - z) > 0.15)
                        frame.set(x, y, black);
                } else frame.set(x, y, black);
                if (y < frame.get_height() - 1) {
                    if (n*normals_buffer[width * (y + 1) + x] < 0.1)
                        frame.set(x, y, black);
                    if (fabs(zbuffer[width * (y + 1) + x] - z) > 0.15)
                        frame.set(x, y, black);
                } else frame.set(x, y, black);
            } else {
                if (x > 0 && normals_buffer[width * y + (x-1)].norm() > 0.1)
                    frame.set(x, y, black);
                if (x < frame.get_width() - 1 && normals_buffer[width * y + (x+1)].norm() > 0.1)
                    frame.set(x, y, black);
                if (y > 0 && normals_buffer[width * (y-1) + x].norm() > 0.1)
                    frame.set(x, y, black);
                if (y < frame.get_height() - 1 && normals_buffer[width * (y+1) + x].norm() > 0.1)
                    frame.set(x, y, black);
            }
        }
    }

    frame.flip_vertically(); // to place the origin in the bottom left corner of the image
    frame.write_to_file(output_filename.c_str());

    float zbuffer_min = INFINITY;
    float zbuffer_max = -INFINITY;
    for (int i = 0; i < (width * height); i++) {
        if (zbuffer[i] > zbuffer_max) zbuffer_max = zbuffer[i];
        if (zbuffer[i] < zbuffer_min) zbuffer_min = zbuffer[i];
    }
    std::cout << "Final Z-Buffer limits: " << zbuffer_min << " to " << zbuffer_max << std::endl;

#if 0
    if (zbuffer_output_filename.length()) {
        FILE* fp = fopen(zbuffer_output_filename.c_str(), "wb");
        unsigned long nbytes = width * height;
        unsigned char * data = new unsigned char[nbytes];

        for (unsigned int i = 0; i < nbytes; i++) {
            data[i] = static_cast<unsigned char>( 255. * (zbuffer[i] - zbuffer_min) / (zbuffer_max - zbuffer_min) );
        }
        svpng(fp, width, height, data, 0, 1);
        fclose(fp);
        if (data) delete [] data;
    }
#endif

    delete [] normals_buffer;
    delete [] zbuffer;
    return EXIT_SUCCESS;
}

