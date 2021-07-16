PROGRAM=test

all: $(PROGRAM)

OBJS = main.o tileset.o
HDRS = $(shell find . -name "*.h")

PKG_CONFIG=
PKG_CONFIG_CFLAGS=`pkg-config --cflags $(PKG_CONFIG) 2>/dev/null`
PKG_CONFIG_LIBS=`pkg-config --libs $(PKG_CONFIG) 2>/dev/null`

CFLAGS= -O0 -g -Wall

LDFLAGS= -Wl,-z,defs -Wl,--as-needed -Wl,--no-undefined
LIBS=$(PKG_CONFIG_LIBS) -lsfml-graphics -lsfml-window -lsfml-system

CFLAGS+=-std=c++11

$(PROGRAM): $(OBJS)
	g++ $(LDFLAGS) $+ -o $@ $(LIBS)

%.o: %.cpp $(HDRS) Makefile
	g++ -o $@ -c $< $(CFLAGS) $(PKG_CONFIG_CFLAGS)

%.o: %.c $(HDRS) Makefile
	gcc -o $@ -c $< $(CFLAGS) $(PKG_CONFIG_CFLAGS)

clean:
	rm -fv $(OBJS)
	rm -fv $(PROGRAM)
	rm -fv *~

