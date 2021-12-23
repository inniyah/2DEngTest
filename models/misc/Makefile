MKFILE_PATH := $(abspath $(lastword $(MAKEFILE_LIST)))
MKFILE_DIR := $(dir $(MKFILE_PATH))

TILES_ID := $(lastword $(subst /, ,$(MKFILE_DIR)))

OPACITY = 0.75

SCRIPTS_DIR := ../../scripts/
TINYRENDERER_DIR := ../../tools/TinyRenderer
TINYRENDERER := "$(TINYRENDERER_DIR)/TinyRenderer"
TINYRENDERER_ISO := $(TINYRENDERER) -C "$(TINYRENDERER_DIR)"/config_iso.ini
TINYRENDERER_TOP := $(TINYRENDERER) -C "$(TINYRENDERER_DIR)"/config_top.ini
TINYRENDERER_UP := $(TINYRENDERER) -C "$(TINYRENDERER_DIR)"/config_up.ini

OBJ_SOURCES = $(shell find . -maxdepth 1 -name "*.obj")

TILES = $(OBJ_SOURCES:.obj=.up.png)

#~ TILES += \
#~ 	$(OBJ_SOURCES:.obj=_1.iso.png) \
#~ 	$(OBJ_SOURCES:.obj=_2.iso.png) \
#~ 	$(OBJ_SOURCES:.obj=_3.iso.png) \
#~ 	$(OBJ_SOURCES:.obj=_4.iso.png)

TILES += \
	$(OBJ_SOURCES:.obj=_1.top.png) \
	$(OBJ_SOURCES:.obj=_2.top.png) \
	$(OBJ_SOURCES:.obj=_3.top.png) \
	$(OBJ_SOURCES:.obj=_4.top.png) \
	$(OBJ_SOURCES:.obj=.top.png)

all: $(TILES) ../$(TILES_ID).top.tsx

add-new-objs:
	ls *.obj | sort --unique | while read -r F; do \
		"$(SCRIPTS_DIR)"/add_metadata.py "$${F}" -d metadata.json -t $(TILES_ID); done

up: $(OBJ_SOURCES:.obj=.up.png)

$(TINYRENDERER):
	$(MAKE) -C "$(TINYRENDERER_DIR)"

%.up.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_UP) -w $< "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	optipng "$@"

%_1.iso.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@)
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@)
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set $@
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile1 $@
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

%_2.iso.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@) -a 90
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@) -a 90
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set "$@"
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile2 "$@"
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

%_3.iso.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@) -a 180
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@) -a 180
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set "$@"
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile3 "$@"
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

%_4.iso.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@) -a 270
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@) -a 270
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set "$@"
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile4 "$@"
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

%.iso.png: %_1.iso.png %_2.iso.png %_3.iso.png %_4.iso.png
	mkdir -p tmp
	@echo DIR: "'$(dir $@)'", FILE: "'$(basename $(basename $(notdir $@)))'", EXT: "'$(suffix $@)'"
	convert +append $+ $@
	optipng $@

%_1.top.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_TOP) -w $< "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile1 "$@"
	optipng "$@"

%_2.top.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_TOP) -w $< "$@" -a 90
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile2 "$@"
	optipng "$@"

%_3.top.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_TOP) -w $< "$@" -a 180
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile3 "$@"
	optipng "$@"

%_4.top.png: %.obj $(TINYRENDERER)
	$(TINYRENDERER_TOP) -w $< "$@" -a 270
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile4 "$@"
	optipng "$@"

%.top.png: %_1.top.png %_2.top.png %_3.top.png %_4.top.png
	mkdir -p tmp
	@echo DIR: "'$(dir $@)'", FILE: "'$(basename $(basename $(notdir $@)))'", EXT: "'$(suffix $@)'"
	convert +append $+ $@
	optipng $@

../$(TILES_ID).top.tsx: $(TILES) metadata.json
	"$(SCRIPTS_DIR)"/generate_tsx.py -d metadata.json -i . -o .. -n "$(TILES_ID).top" -t TopTile

../$(TILES_ID).iso.tsx: $(TILES) metadata.json
	"$(SCRIPTS_DIR)"/generate_tsx.py -d metadata.json -i . -o .. -n "$(TILES_ID).iso" -t IsoTile

update: $(OBJ_SOURCES)
	"$(SCRIPTS_DIR)"/update_attributes.py -J attributes.json -P '*.obj'

clean:
	@rm -fv `find . -maxdepth 1 -name "*.iso.png"`
	@rm -fv `find . -maxdepth 1 -name "*.top.png"`
	@rm -fv `find . -maxdepth 1 -name "*.up.png"`
	@rm -fv `find . -maxdepth 1 -name "*.tsx"`
	@rm -fv `find . -maxdepth 1 -name "*.log"`
	@rm -fv `find . -maxdepth 1 -name "tmp_*.png"`
	@rm -fv "../$(TILES_ID).top.tsx" "../$(TILES_ID).iso.tsx"

.PHONY: all add-new-objs up update clean
