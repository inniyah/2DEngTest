#!/usr/bin/make -f

# sudo apt install pkg-config cython3 libpython3-dev zlib1g-dev libzstd-dev \
#     libxml2-dev libsdl2-dev libsdl2-image-dev

PACKAGES= python3-embed zlib libzstd libxml-2.0 sdl2 SDL2_image

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
	-Wl,--no-allow-shlib-undefined

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

INCS= -Isrc/tmx

CYINCS= \
	-Isrc/sdl2_cython \
	-Isrc/tmxlite_cython

LIBS=

all: test.so

PYX_SRCS= \
	src/test_cython/test.pyx

C_SRCS= \
	src/tmxlite/detail/miniz.c

CPP_SRCS= \
	src/tmxlite/FreeFuncs.cpp \
	src/tmxlite/LayerGroup.cpp \
	src/tmxlite/ObjectGroup.cpp \
	src/tmxlite/TileLayer.cpp \
	src/tmxlite/ImageLayer.cpp \
	src/tmxlite/Map.cpp \
	src/tmxlite/Object.cpp \
	src/tmxlite/Property.cpp \
	src/tmxlite/Tileset.cpp \
	src/tmxlite/detail/pugixml.cpp

PYX_CPPS= $(subst .pyx,.cpp,$(PYX_SRCS))
PYX_OBJS= $(subst .pyx,.o,$(PYX_SRCS))

OBJS= $(PYX_OBJS) $(subst .c,.o,$(C_SRCS)) $(subst .cpp,.o,$(CPP_SRCS))

test: $(OBJS)
	$(CXX) $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

test.so: $(OBJS)
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
	@$(RM) core
	@#$(RM) --recursive ~/.cache/CythonOgreTestApp/

.PHONY: all clean
