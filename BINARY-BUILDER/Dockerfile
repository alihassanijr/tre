# Build tre as a static musl binary for a chosen arch.
# BASE is an arch-specific messense/rust-musl-cross image (ships the matching
# musl cross toolchain + linker), so this cross-compiles from any host arch.
ARG BASE=messense/rust-musl-cross:aarch64-musl
FROM ${BASE}

ARG TARGET=aarch64-unknown-linux-musl
ENV TARGET=${TARGET}

WORKDIR /src

# Add the target toolchain BEFORE COPY so source edits don't bust this layer.
RUN rustup target add ${TARGET}

# Bake the whole project + build script into the image. Source never leaves
# via a mount. The actual compile happens at `docker run`, not here.
COPY . .

# At `docker run`: build + strip + tarball, dropping ONLY the .tar.gz into /out
# (the single host tmp dir bind-mount). target/ stays inside the container and
# dies with --rm.
CMD ["sh", "/src/BINARY-BUILDER/in-container-build.sh"]
