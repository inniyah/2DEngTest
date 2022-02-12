# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

# See: https://stackoverflow.com/questions/63875206/how-to-share-a-c-singleton-between-multiple-c-extensions
# See: https://stackoverflow.com/questions/58155766/loading-vs-linking-in-cython-modules/58162089#58162089

cdef int get_singleton()
cdef void set_singleton(int new_value)
