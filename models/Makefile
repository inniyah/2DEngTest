#!/usr/bin/make -f

# Top-level targets
TOPTARGETS := all clean

# Register all subdirectories in the project's root directory.
SUBDIRS := $(wildcard */.)

# Recurse `make` into each subdirectory
# Pass along targets specified at command-line (if any).
$(TOPTARGETS): $(SUBDIRS)
$(SUBDIRS):
	$(MAKE) -C $@ $(MAKECMDGOALS)

# Make all the individual targets in the sub-directories available from the top
# level; as in, for instance, `make foo/my_program` or `make bar/clean`
$(foreach __dir__,$(SUBDIRS),$(__dir__)/%):
	@$(MAKE) -C '$(@D)' '$(@F)'

.PHONY: $(TOPTARGETS) $(SUBDIRS)
