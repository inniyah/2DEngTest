#!/usr/bin/make -f

# sudo apt install pkg-config cython3 libpython3-dev libsdl2-dev libsdl2-image-dev libzstd-dev
# Also install: libsdl2-gpu-dev libtmxlite-dev

PACKAGES= python3-embed sdl2 SDL2_image SDL2_gpu tmxlite zlib libxml-2.0

NUMCPUS=$(shell grep -c '^processor' /proc/cpuinfo)

TRGT=

CC   = $(TRGT)gcc
CXX  = $(TRGT)g++
AS   = $(TRGT)gcc -x assembler-with-cpp

LD   = $(TRGT)g++
AR   = $(TRGT)ar rvc

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

CSTD=-std=gnu17
CPPSTD=-std=gnu++17

OPTS= -O2 -g

DEFS= \
	-DNDEBUG \
	-D_LARGEFILE64_SOURCE \
	-D_FILE_OFFSET_BITS=64 \
	-DWANT_ZLIB\
	-DWANT_ZSTD

INCS= \
	-Iinclude

CYINCS= \
	-Icython \
	-Isrc

LIBS= \
	-lzstd

OBJS=

PYX_NAMES= hub gonlet shaders tmxlite

PYX_SRCS= $(PYX_NAMES:%=src/%.pyx)
PYX_CPPS= $(subst .pyx,.cpp,$(PYX_SRCS))
PYX_OBJS= $(subst .pyx,.o,$(PYX_SRCS))

all: hub.so tmxlite.so gonlet.so shaders.so ctmx.so

hub.so: src/hub.o src/hub_core.o
gonlet.so: src/gonlet.o
tmxlite.so: src/tmxlite.o
shaders.so: src/shaders.o

TMX_OBJS= \
	src/tmx/tmx.o \
	src/tmx/tmx_err.o \
	src/tmx/tmx_hash.o \
	src/tmx/tmx_mem.o \
	src/tmx/tmx_utils.o \
	src/tmx/tmx_xml.o

ctmx.so: src/ctmx.o $(TMX_OBJS)

%.bin:
	$(LD) $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

%.so:
	$(LD) -shared $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

%.a:
	$(AR) $@ $+

%.o: %.cpp
	$(CXX) $(CPPSTD) $(OPTS) -o $@ -c $< $(DEFS) $(INCS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.o: %.c
	$(CC) $(CSTD) $(OPTS) -o $@ -c $< $(DEFS) $(INCS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.cpp: %.pyx
	$(CYTHON) $(CYFLAGS) $(CYINCS) -o $@ $<


clean:
	$(RM) $(OBJS) $(PYX_OBJS)
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
	@$(RM) core

.PHONY: all clean
