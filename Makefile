#!/usr/bin/make -f

# sudo apt install pkg-config cython3 libpython3-dev libsdl2-dev libsdl2-image-dev libzstd-dev
# Also install: libsdl2-gpu-dev libtmxlite-dev

PACKAGES= python3-embed sdl2 SDL2_image SDL2_gpu tmxlite zlib libxml-2.0 imgui raylib

NUM_CPUS ?= $(shell grep -c '^processor' /proc/cpuinfo)

ARCH_NAME := $(shell '$(TRGT)gcc' -dumpmachine)

# See: https://peps.python.org/pep-3149/
PYMOD_SOABI := $(shell python3 -c "import sysconfig; print(sysconfig.get_config_var('SOABI'));")
PYMOD_SUFFIX := $(shell python3 -c "import sysconfig; print(sysconfig.get_config_var('EXT_SUFFIX'));")

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

PYX_NAMES= hub gonlet shaders tmxlite pyimgui

PYX_SRCS= $(PYX_NAMES:%=src/%.pyx)
PYX_CPPS= $(subst .pyx,.cpp,$(PYX_SRCS))
PYX_OBJS= $(subst .pyx,.o,$(PYX_SRCS))

all: \
	hub$(PYMOD_SUFFIX) \
	tmxlite$(PYMOD_SUFFIX) \
	gonlet$(PYMOD_SUFFIX) \
	shaders$(PYMOD_SUFFIX) \
	ctmx$(PYMOD_SUFFIX) \
	raylib$(PYMOD_SUFFIX)

HUB_OBJS= \
	src/hub_core.o

hub$(PYMOD_SUFFIX): src/hub.o $(HUB_OBJS)

GONLET_OBJS= 
gonlet$(PYMOD_SUFFIX): src/gonlet.o $(GONLET_OBJS)

SHADERS_OBJS= 
shaders$(PYMOD_SUFFIX): src/shaders.o $(SHADERS_OBJS)

TMX_OBJS= \
	src/tmx/tmx.o \
	src/tmx/tmx_err.o \
	src/tmx/tmx_hash.o \
	src/tmx/tmx_mem.o \
	src/tmx/tmx_utils.o \
	src/tmx/tmx_xml.o

ctmx$(PYMOD_SUFFIX): src/ctmx.o $(TMX_OBJS)

TMXLITE_OBJS= 
tmxlite$(PYMOD_SUFFIX): src/tmxlite.o $(TMXLITE_OBJS)

RAYLIB_OBJS= 
raylib$(PYMOD_SUFFIX): src/raylib.o $(RAYLIB_OBJS)

IMGUI_OBJS= \
	src/imgui/AnsiTextColored.o

pyimgui$(PYMOD_SUFFIX): src/pyimgui.o $(IMGUI_OBJS)

%.bin:
	$(LD) $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

%$(PYMOD_SUFFIX):
	$(LD) -shared $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

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
