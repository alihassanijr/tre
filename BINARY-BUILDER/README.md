# BINARY-BUILDER

Build `tre` as a **static musl binary** in a container, packaged as a release
tarball. Cross-compiles from any host arch — no qemu, no local Rust toolchain.

## Usage

```bash
cd BINARY-BUILDER
make                # aarch64 (arm64)
make ARCH=x86_64    # x86_64
```

Output: `dist/tre-v<version>-<target>.tar.gz`, containing `tre` + `tre.1`.

## Targets

| Target            | Does                                          |
|-------------------|-----------------------------------------------|
| `make` / `binary` | build image, run it, drop tarball in `dist/`  |
| `make image`      | build the builder image only                  |
| `make verify`     | list tarball contents                         |
| `make clean`      | remove `dist/`                                |
| `make distclean`  | remove `dist/` and the docker image           |

## Knobs

- `ARCH` (default `aarch64`) — picks target triple + base image.
- `TARGET` / `BASE` — full override for advanced cases.

## How it works

`docker build` bakes the project into an arch-specific
[`rust-musl-cross`](https://github.com/rust-cross/rust-musl-cross) image. The
compile happens at `docker run`, which mounts exactly one dir — a host tmp dir
at `/out`. The container builds, strips, tarballs, and drops **only** the
`.tar.gz` there; everything else dies with `--rm`. The host moves it into
`dist/`. So nothing but source enters and nothing but the tarball leaves.
