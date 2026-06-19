#!/bin/sh
# Runs INSIDE the container at `docker run`. Builds the static musl binary for
# $TARGET, then packages tre + tre.1 into a release tarball and drops ONLY that
# tarball into /out (the single host bind-mount).
set -eu

BIN="target/${TARGET}/release/tre"

RUSTFLAGS='-C target-feature=+crt-static' cargo build --release --target "$TARGET"
"${TARGET}-strip" "$BIN"

VER="$(grep '^version' Cargo.toml | head -1 | cut -d'"' -f2)"
NAME="tre-v${VER}-${TARGET}"

# Stage tre + manpage at archive root, matching the release.yml layout.
STAGE="$(mktemp -d)"
cp "$BIN" "$STAGE/tre"
cp manual/tre.1 "$STAGE/tre.1"

tar -C "$STAGE" -czf "/out/${NAME}.tar.gz" tre tre.1
echo "Packaged /out/${NAME}.tar.gz"
