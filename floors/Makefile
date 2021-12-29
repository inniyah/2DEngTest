PNG_SOURCES = $(shell find . -maxdepth 1 -name "*.png" | grep -v ".floors.png$$")
JPG_SOURCES = $(shell find . -maxdepth 1 -name "*.jpg")

IMG_SOURCES = $(PNG_SOURCES:.png=) $(JPG_SOURCES:.jpg=)

OUT_PNG = $(addsuffix .floors.png,$(addprefix tiles/,$(IMG_SOURCES)))
OUT_TSX = $(addsuffix .floors.tsx,$(addprefix ./,$(IMG_SOURCES)))

all: $(OUT_PNG)

%.floors.tsx tiles/%.floors.png: %.png
	./mkfloortiles.py -n $(<:.png=)

%.floors.tsx tiles/%.floors.png: %.jpg
	./mkfloortiles.py -n $(<:.jpg=)

clean:
	@rm -fv $(OUT_PNG) $(OUT_TSX)
	@if [ -d tiles ]; then rmdir --ignore-fail-on-non-empty tiles ; fi
	@if [ -d tmp ]; then rmdir --ignore-fail-on-non-empty tmp ; fi

.PHONY: all clean
