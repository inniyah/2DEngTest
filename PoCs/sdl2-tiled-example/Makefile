#!/usr/bin/make -f

PROGRAM= example

PACKAGES= zlib libzstd libxml-2.0 sdl2 SDL2_image SDL2_gpu

CC= gcc
CXX= g++
RM= rm --force --verbose

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

CSTD=-std=c17
CPPSTD=-std=c++17

OPTS= -O2 -g

DEFS= \
	-DWANT_ZLIB \
	-DWANT_ZSTD \
	-DMINIZ_NO_STDIO \
	-DNDEBUG

INCS= \
	-I.

LIBS=

all: $(PROGRAM)

OBJS= \
	tmxlite/FreeFuncs.o \
	tmxlite/LayerGroup.o \
	tmxlite/ObjectGroup.o \
	tmxlite/TileLayer.o \
	tmxlite/ImageLayer.o \
	tmxlite/Map.o \
	tmxlite/Object.o \
	tmxlite/ObjectTypes.o \
	tmxlite/Property.o \
	tmxlite/Tileset.o \
	tmxlite/detail/pugixml.o \
	tmxlite/detail/miniz.o \
	src/assets.o \
	src/level.o \
	src/main.o

$(PROGRAM): $(OBJS)
	$(CXX) $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) -o $@ $+ $(LIBS) $(PKG_CONFIG_LIBS)

%.o: %.cpp
	$(CXX) $(CPPSTD) $(OPTS) -o $@ -c $< $(DEFS) $(INCS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.o: %.c
	$(CC) $(CSTD) $(OPTS) -o $@ -c $< $(DEFS) $(INCS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

clean:
	$(RM) $(OBJS) $(PROGRAM)

cleanall: clean
	@find . -name '*.o' -exec $(RM) {} +
	@find . -name '*.a' -exec $(RM) {} +
	@find . -name '*.so' -exec $(RM) {} +
	@find . -name '*.pyc' -exec $(RM) {} +
	@find . -name '*.pyo' -exec $(RM) {} +
	@find . -name '*.bak' -exec $(RM) {} +
	@find . -name '*~' -exec $(RM) {} +
	@$(RM) core

.PHONY: all clean cleanall
