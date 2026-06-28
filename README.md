# Packaging scripts

libvips and its dependencies are provided as pre-compiled shared libraries
for the most common operating systems and CPU architectures.

These are [packaged](npm) and published to the npm registry under the
[@img](https://www.npmjs.com/org/img) organisation.

## Creating a tarball

Most people will not need to do this; proceed with caution.

Run the top-level [build script](build.sh) without parameters for help.

## Portable CLI tarballs

This fork can also build macOS/Linux libvips command-line tarballs for desktop
app bundling, e.g. Tauri apps that need a portable `vips` executable and its
shared libraries.

Run [build-cli.sh](build-cli.sh) to create `libvips-cli-<platform>.tar.gz`.
See [CLI-BUILD.md](CLI-BUILD.md) for supported platforms, local macOS M4 builds,
Linux Docker builds, automatic GitHub Release artifacts, and Tauri packaging
notes.

### Linux

One [build script](build/posix.sh) is used to (cross-)compile
the same shared libraries within multiple containers.

* [x64 glibc](platforms/linux-x64/Dockerfile)
* [x64 musl](platforms/linuxmusl-x64/Dockerfile)
* [ARMv6 glibc](platforms/linux-armv6/Dockerfile)
* [ARM64v8-A glibc](platforms/linux-arm64v8/Dockerfile)
* [ARM64v8-A musl](platforms/linuxmusl-arm64v8/Dockerfile)
* [ppc64le glibc](platforms/linux-ppc64le/Dockerfile)
* [RISC-V 64-bit glibc](platforms/linux-riscv64/Dockerfile)
* [s390x glibc](platforms/linux-s390x/Dockerfile)

### Windows

The output of libvips' [build-win64-mxe](https://github.com/libvips/build-win64-mxe)
static "web" releases are [post-processed](build/win.sh) within a [container](platforms/win32/Dockerfile).

### macOS

Uses a macOS virtual machine hosted by GitHub to compile the shared libraries.
The dylib files are compiled within the same build script as Linux.

* x64
* ARM64

Dependency paths are modified to use the relative `@rpath` with `install_name_tool`.

### WebAssembly

The scripts from [wasm-vips](https://github.com/kleisauke/wasm-vips)
are [used to compile](build/wasm.sh) libvips and its dependencies
as static Wasm libraries ready for further compilation into a single,
statically-linked sharp shared library.

## Licences

These scripts are licensed under the terms of the [Apache 2.0 Licence](LICENSE).

The shared libraries contained in the tarballs are distributed under
the terms of [various licences](THIRD-PARTY-NOTICES.md), all of which
are compatible with the Apache 2.0 Licence.
