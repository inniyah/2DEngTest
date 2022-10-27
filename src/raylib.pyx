# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

from libc.stdint cimport int32_t, uint32_t, int16_t, uint16_t, int8_t, uint8_t
from libc.stdlib cimport calloc, malloc, free
from libcpp cimport bool
from libcpp.memory cimport unique_ptr, shared_ptr, make_shared, allocator
from libcpp.string cimport string
from libcpp.vector cimport vector
from libcpp.utility cimport pair
from cpython.ref cimport PyObject
from cython cimport view
cimport cpython.array
from cython.operator cimport dereference as deref
from cpython.pycapsule cimport PyCapsule_New, PyCapsule_IsValid, PyCapsule_GetPointer, PyCapsule_GetName
from enum import IntEnum

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cimport hub

def get():
    return hub.get_singleton()

def set(new_val):
    hub.set_singleton(new_val)

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cimport sdl2.SDL2 as SDL2
cimport sdl2.SDL2_gpu as SDL2_gpu

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cimport raylib.raylib as raylib
cimport raylib.raymath as raymath
cimport raylib.rlgl as rlgl

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

cdef class _test:
    def __cinit__(self):
        pass

    def __dealloc___(self):
        pass

    def reset(self):
        pass

    def run(self):
        raylib.InitWindow(800, 450, b"Raylib test")
        raylib.SetTargetFPS(60)

        cdef raylib.Camera3D camera
        camera.position = [18.0, 16.0, 18.0]
        camera.target = [0.0, 0.0, 0.0]
        camera.up = [0.0, 1.0, 0.0]
        camera.fovy = 45.0
        camera.projection = 0

        image = raylib.LoadImage(b"assets/heightmap.png")
        texture = raylib.LoadTextureFromImage(image)
        mesh = raylib.GenMeshHeightmap(image, [16, 8, 16])
        model = raylib.LoadModelFromMesh(mesh)
        #~ print(model.materials)  # SHOULD BE A pointer to a 'struct Material' but some is NULL pointer to 'Material' ?
        model.materials.maps[<int>raylib.MATERIAL_MAP_ALBEDO].texture = texture

        raylib.UnloadImage(image)
        raylib.SetCameraMode(camera, raylib.CAMERA_ORBITAL)

        cdef raylib.Vector3 vec = raylib.newVector3(-8.0, 0.0, -8.0)
        while not raylib.WindowShouldClose():
            raylib.UpdateCamera(&camera)
            raylib.BeginDrawing()
            raylib.ClearBackground(raylib.RAYWHITE)
            raylib.BeginMode3D(camera)
            raylib.DrawModel(model, vec, 1.0, raylib.RED)
            raylib.DrawGrid(20, 1.0)
            raylib.EndMode3D()
            raylib.DrawText(b"This mesh should be textured", 190, 200, 20, raylib.VIOLET)
            raylib.EndDrawing()
        raylib.CloseWindow()

class test(_test):
    def __init__(self):
        pass
