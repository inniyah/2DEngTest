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
OBJ_NAMES   = $(notdir $(OBJ_SOURCES:.obj=))

TILES_UP  = $(addsuffix .up.png,$(addprefix tiles/,$(OBJ_NAMES)))
TILES_TOP = $(addsuffix .top.png,$(addprefix tiles/,$(OBJ_NAMES)))
TILES_ISO = $(addsuffix .iso.png,$(addprefix tiles/,$(OBJ_NAMES)))

TILES =

#~ TILES += \
#~ 	$(TILES_UP)

#~ TILES += \
#~ 	$(TILES_ISO:.iso.png=_1.iso.png) \
#~ 	$(TILES_ISO:.iso.png=_2.iso.png) \
#~ 	$(TILES_ISO:.iso.png=_3.iso.png) \
#~ 	$(TILES_ISO:.iso.png=_4.iso.png) \
#~ 	$(TILES_ISO)

TILES += \
	$(TILES_TOP:.top.png=_1.top.png) \
	$(TILES_TOP:.top.png=_2.top.png) \
	$(TILES_TOP:.top.png=_3.top.png) \
	$(TILES_TOP:.top.png=_4.top.png) \
	$(TILES_TOP)

all: $(TILES) ../$(TILES_ID).top.tsx

add-new-objs:
	ls *.obj | sort --unique | while read -r F; do \
		"$(SCRIPTS_DIR)"/add_metadata.py "$${F}" -d metadata.json -t $(TILES_ID); done

up: $(OBJ_SOURCES:.obj=.up.png)

$(TINYRENDERER):
	$(MAKE) -C "$(TINYRENDERER_DIR)"

tiles/%.up.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_UP) -w $< "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	optipng "$@"

tiles/%_1.iso.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@)
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@)
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set $@
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile1 $@
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

tiles/%_2.iso.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@) -a 90
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@) -a 90
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set "$@"
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile2 "$@"
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

tiles/%_3.iso.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@) -a 180
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@) -a 180
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set "$@"
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile3 "$@"
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

tiles/%_4.iso.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_ISO) -w    $< tmp_dir_$(notdir $@) -a 270
	$(TINYRENDERER_ISO) -w -r $< tmp_rev_$(notdir $@) -a 270
	composite -dissolve 60 -gravity Center tmp_dir_$(notdir $@) tmp_rev_$(notdir $@) -alpha Set "$@"
	convert $@ -channel A -evaluate Multiply $(OPACITY) +channel "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D IsoTile4 "$@"
	rm "tmp_dir_$(notdir $@)" "tmp_rev_$(notdir $@)"

tiles/%.iso.png: tiles/%_1.iso.png tiles/%_2.iso.png tiles/%_3.iso.png tiles/%_4.iso.png
	@mkdir -p tmp && mkdir -p "$$(dirname '$@')"
	@echo DIR: "'$(dir $@)'", FILE: "'$(basename $(basename $(notdir $@)))'", EXT: "'$(suffix $@)'"
	convert +append $+ $@
	optipng $@

tiles/%_1.top.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_TOP) -w $< "$@"
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile1 "$@"
	optipng "$@"

tiles/%_2.top.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_TOP) -w $< "$@" -a 90
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile2 "$@"
	optipng "$@"

tiles/%_3.top.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_TOP) -w $< "$@" -a 180
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile3 "$@"
	optipng "$@"

tiles/%_4.top.png: %.obj $(TINYRENDERER)
	@mkdir -p "$$(dirname '$@')"
	$(TINYRENDERER_TOP) -w $< "$@" -a 270
	"$(SCRIPTS_DIR)"/add_metadata.py -v "$<" -d metadata.json -t $(TILES_ID) -J $(dir $<)attributes.json -D 3DModel "$<"
	"$(SCRIPTS_DIR)"/add_metadata.py "$<" -d metadata.json -t $(TILES_ID) -D TopTile4 "$@"
	optipng "$@"

tiles/%.top.png: tiles/%_1.top.png tiles/%_2.top.png tiles/%_3.top.png tiles/%_4.top.png
	@mkdir -p tmp && mkdir -p "$$(dirname '$@')"
	@echo DIR: "'$(dir $@)'", FILE: "'$(basename $(basename $(notdir $@)))'", EXT: "'$(suffix $@)'"
	convert +append $+ $@
	optipng $@

../$(TILES_ID).top.tsx: $(TILES) metadata.json
	@mkdir -p "$$(dirname '$@')"
	"$(SCRIPTS_DIR)"/generate_tsx.py -d metadata.json -i . -o .. -n "$(TILES_ID).top" -t TopTile

../$(TILES_ID).iso.tsx: $(TILES) metadata.json
	@mkdir -p "$$(dirname '$@')"
	"$(SCRIPTS_DIR)"/generate_tsx.py -d metadata.json -i . -o .. -n "$(TILES_ID).iso" -t IsoTile

update: $(OBJ_SOURCES)
	"$(SCRIPTS_DIR)"/update_attributes.py -J attributes.json -P '*.obj'

clean:
	@rm -fv `find . -maxdepth 2 -name "*.iso.png"`
	@rm -fv `find . -maxdepth 2 -name "*.top.png"`
	@rm -fv `find . -maxdepth 2 -name "*.up.png"`
	@rm -fv `find . -maxdepth 2 -name "*.tsx"`
	@rm -fv `find . -maxdepth 2 -name "*.log"`
	@rm -fv `find . -maxdepth 2 -name "tmp_*.png"`
	@rm -fv "../$(TILES_ID).top.tsx" "../$(TILES_ID).iso.tsx"
	@if [ -d tiles ]; then rmdir --ignore-fail-on-non-empty tiles ; fi
	@if [ -d tmp ]; then rmdir --ignore-fail-on-non-empty tmp ; fi

.PHONY: all add-new-objs up update clean
