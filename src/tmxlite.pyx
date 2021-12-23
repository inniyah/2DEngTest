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
from enum import IntEnum

include "tmxlite.pxi"
