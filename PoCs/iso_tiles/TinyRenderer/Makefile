PROGRAM=TinyRenderer

all: $(PROGRAM)

OBJS = \
	geometry.o \
	model.o \
	render.o \
	image.o \
	str2dbl.o \
	arghelper.o \
	main.o

PKG_CONFIG=

ifndef PKG_CONFIG
PKG_CONFIG_CFLAGS=
PKG_CONFIG_LDFLAGS=
PKG_CONFIG_LIBS=
else
PKG_CONFIG_CFLAGS=`pkg-config --cflags $(PKG_CONFIG)`
PKG_CONFIG_LDFLAGS=`pkg-config --libs-only-L $(PKG_CONFIG)`
PKG_CONFIG_LIBS=`pkg-config --libs-only-l $(PKG_CONFIG)`
endif

OPTFLAGS= -O2 -g
CFLAGS= -MD -Wall -pedantic -Wno-unused-variable -Wno-unused-value -Wno-unused-function -Wno-unused-but-set-variable
LDFLAGS= -Wl,--as-needed -Wl,--no-undefined -Wl,--no-allow-shlib-undefined
INCS=
LIBS=
DEFS=
CSTD=-std=c11
CPPSTD=-std=c++11

DEPS=$(OBJS:.o=.d)

$(PROGRAM): $(OBJS)
	g++ $(CPPSTD) $(CSTD) $(LDFLAGS) $(PKG_CONFIG_LDFLAGS) $+ -o $@ $(LIBS) $(PKG_CONFIG_LIBS)

%.o: %.cpp
	g++ -o $@ -c $+ $(CPPSTD) $(DEFS) $(INCS) $(OPTFLAGS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.o: %.c
	gcc -o $@ -c $+ $(CSTD) $(DEFS) $(INCS) $(OPTFLAGS) $(CFLAGS) $(PKG_CONFIG_CFLAGS)

clean:
	@rm -fv *.o *.a *~
	@rm -fv */*.o */*.a */*~
	@rm -fv $(PROGRAM)
	@rm -fv $(DEPS)

cleanall: clean

-include $(DEPS)
