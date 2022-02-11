# cython: profile=False
# cython: embedsignature = True
# cython: language_level = 3
# distutils: language = c++

# See: https://stackoverflow.com/questions/63875206/how-to-share-a-c-singleton-between-multiple-c-extensions
# See: https://stackoverflow.com/questions/58155766/loading-vs-linking-in-cython-modules/58162089#58162089

cdef extern from "hub_core.h":
	int c_get_singleton "get_singleton" ()
	void c_set_singleton "set_singleton" (int new_val)

cdef int get_singleton():
	return c_get_singleton()

cdef void set_singleton(int new_val):
	c_set_singleton(new_val)

def get():
	return c_get_singleton()

def set(new_val):
	c_set_singleton(new_val)
