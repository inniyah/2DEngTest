#!/usr/bin/make -f

CURDIR:=$(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
BASEDIR:=$(CURDIR)/../..

PACKAGES= python3-embed zlib libzstd libxml-2.0 sdl2 SDL2_image SDL2_gpu

CC= gcc
CXX= g++
RM= rm --force --verbose

PYTHON= python3
CYTHON= cython3

PKGCONFIG= pkg-config

ifndef PACKAGES
PKG_CONFIG_CFLAGS=
PKG_CONFIG_LDFLAGS=
PKG_CONFIG_LIBS=
else
PKG_CONFIG_CFLAGS=`pkg-config --cflags $(PACKAGES)`
PKG_CONFIG_LDFLAGS=`pkg-config --libs-only-L $(PACKAGES)`
PKG_CONFIG_LIBS=`pkg-config --libs-only-l $(PACKAGES)`
endif

CFLAGS= \
	-Wall \
	-fwrapv \
	-fstack-protector-strong \
	-Wall \
	-Wformat \
	-Werror=format-security \
	-Wdate-time \
	-D_FORTIFY_SOURCE=2 \
	-fPIC

LDFLAGS= \
	-Wl,-O1 \
	-Wl,-Bsymbolic-functions \
	-Wl,-z,relro \
	-Wl,--as-needed \
	-Wl,--no-undefined \
	-Wl,--no-allow-shlib-undefined \
	-Wl,-Bsymbolic-functions \
	-Wl,--dynamic-list-cpp-new \
	-Wl,--dynamic-list-cpp-typeinfo

CYFLAGS= \
	-3 \
	--cplus \
	-X language_level=3 \
	-X boundscheck=False

CSTD=-std=c17
CPPSTD=-std=c++17

OPTS= -O2 -g

DEFS= \
	-DWANT_ZLIB \
	-DWANT_ZSTD \
	-DMINIZ_NO_STDIO \
	-DNDEBUG

INCS= \
	-I "$(BASEDIR)/src/tmxlite"

CYINCS= \
	-I "$(BASEDIR)/src/cython"

LIBS=

all: tmxtest.so

PYX_SRCS= \
	tmxtest.pyx

C_SRCS= \
	$(BASEDIR)/src/tmxlite/detail/miniz.c

CPP_SRCS= \
	$(BASEDIR)/src/tmxlite/FreeFuncs.cpp \
	$(BASEDIR)/src/tmxlite/LayerGroup.cpp \
	$(BASEDIR)/src/tmxlite/ObjectGroup.cpp \
	$(BASEDIR)/src/tmxlite/TileLayer.cpp \
	$(BASEDIR)/src/tmxlite/ImageLayer.cpp \
	$(BASEDIR)/src/tmxlite/Map.cpp \
	$(BASEDIR)/src/tmxlite/Object.cpp \
	$(BASEDIR)/src/tmxlite/ObjectTypes.cpp \
	$(BASEDIR)/src/tmxlite/Property.cpp \
	$(BASEDIR)/src/tmxlite/Tileset.cpp \
	$(BASEDIR)/src/tmxlite/detail/pugixml.cpp

PYX_CPPS= $(subst .pyx,.cpp,$(PYX_SRCS))
PYX_OBJS= $(subst .pyx,.o,$(PYX_SRCS))

OBJS= $(PYX_OBJS) $(subst .c,.o,$(C_SRCS)) $(subst .cpp,.o,$(CPP_SRCS))

test: $(OBJS)
	$(CXX) $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

tmxtest.so: $(OBJS)
	$(CXX) -shared $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

%.o: %.cpp
	$(CXX) $(CPPSTD) $(OPTS) -o $@ -c $< $(DEFS) $(INCS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.o: %.c
	$(CC) $(CSTD) $(OPTS) -o $@ -c $< $(DEFS) $(INCS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.cpp: %.pyx
	$(CYTHON) $(CYFLAGS) $(CYINCS) -o $@ $<

clean:
	$(RM) $(OBJS)
	$(RM) $(subst .pyx,.cpp,$(PYX_SRCS))
	$(RM) $(subst .pyx,_api.cpp,$(PYX_SRCS))
	$(RM) $(subst .pyx,.h,$(PYX_SRCS))
	$(RM) $(subst .pyx,_api.h,$(PYX_SRCS))
	@find . -name '*.o' -exec $(RM) {} +
	@find . -name '*.a' -exec $(RM) {} +
	@find . -name '*.so' -exec $(RM) {} +
	@find . -name '*.pyc' -exec $(RM) {} +
	@find . -name '*.pyo' -exec $(RM) {} +
	@find . -name '*.bak' -exec $(RM) {} +
	@find . -name '*~' -exec $(RM) {} +
	@$(RM) --verbose core
	@$(RM) --verbose --recursive __pycache__

.PHONY: all clean
