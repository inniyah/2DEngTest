# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

cdef int get_singleton()
cdef void set_singleton(int new_value)
