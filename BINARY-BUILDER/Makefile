# Build tre as a static musl binary in a container, packaged as a tarball.
#
#   make                       # build image + tarball -> dist/
#   make ARCH=x86_64           # same, for x86_64
#   make TARGET=... BASE=...   # full override (advanced)
#   make image                 # build the builder image only
#   make binary                # run image, drop tarball into dist/
#   make verify                # list tarball contents
#   make clean                 # remove dist/
#   make distclean             # remove dist/ and the docker image

# --- knobs ------------------------------------------------------------------
ARCH    ?= aarch64
TARGET  ?= $(ARCH)-unknown-linux-musl
BASE    ?= messense/rust-musl-cross:$(ARCH)-musl
IMAGE   ?= tre-builder:$(TARGET)
DIST    ?= dist

# --- paths (work regardless of cwd) ----------------------------------------
DIR  := $(patsubst %/,%,$(dir $(abspath $(lastword $(MAKEFILE_LIST)))))
ROOT := $(abspath $(DIR)/..)

.DEFAULT_GOAL := all
.PHONY: all image binary verify clean distclean

all: binary

image:
	docker build \
	    --build-arg BASE=$(BASE) \
	    --build-arg TARGET=$(TARGET) \
	    -t $(IMAGE) \
	    -f $(DIR)/Dockerfile \
	    $(ROOT)

# Run the image with exactly ONE mount: a fresh host tmp dir -> /out.
# Container drops only the tarball there; we move it into dist/ and wipe tmp.
binary: image
	@TMP=$$(mktemp -d); \
	trap 'rm -rf "$$TMP"' EXIT; \
	echo "Running $(IMAGE); mounting only $$TMP -> /out ..."; \
	docker run --rm -v "$$TMP:/out" $(IMAGE); \
	rm -rf "$(DIR)/$(DIST)"; \
	mkdir -p "$(DIR)/$(DIST)"; \
	mv "$$TMP"/*.tar.gz "$(DIR)/$(DIST)/"; \
	ls -l "$(DIR)/$(DIST)"

verify:
	@tar -tzf $(DIR)/$(DIST)/*.tar.gz

clean:
	rm -rf $(DIR)/$(DIST)

distclean: clean
	-docker image rm $(IMAGE)
