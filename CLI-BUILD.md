# Portable libvips CLI builds

This fork can build macOS and Linux tarballs that contain the libvips command-line
tools plus the shared libraries they need at runtime.

Windows is intentionally out of scope here. Use the official libvips
`build-win64-mxe` release for Windows.

## Output

Run the CLI build with:

```sh
./build-cli.sh PLATFORM
```

The output is:

```text
libvips-cli-PLATFORM.tar.gz
```

Each tarball contains this relocatable layout:

```text
bin/
  vips
  vipsthumbnail
  vipsheader
  vipsedit
lib/
  *.so or *.dylib
include/
versions.json
THIRD-PARTY-NOTICES.md
```

Some optional tools may be absent if the upstream libvips version does not build
them, but `bin/vips` is required and the build fails if it is missing.

The binaries are linked for the `bin/../lib` layout:

- Linux: `$ORIGIN/../lib`
- macOS: `@executable_path/../lib`

Keep `bin` and `lib` together when moving the bundle.

## Supported platforms

The helper script accepts:

```text
darwin-arm64v8
darwin-x64
linux-arm64v8
linux-x64
linuxmusl-arm64v8
linuxmusl-x64
```

For Tauri target triples, these usually map as follows:

```text
darwin-arm64v8      -> aarch64-apple-darwin
darwin-x64          -> x86_64-apple-darwin
linux-arm64v8       -> aarch64-unknown-linux-gnu
linux-x64           -> x86_64-unknown-linux-gnu
linuxmusl-arm64v8   -> aarch64-unknown-linux-musl
linuxmusl-x64       -> x86_64-unknown-linux-musl
```

## Build on a macOS M4 machine

Your M4 Mac is the right place to build `darwin-arm64v8`:

```sh
brew install automake cmake nasm pkg-config pipx
pipx install meson
./build-cli.sh darwin-arm64v8
```

Verify the result:

```sh
mkdir -p /tmp/libvips-cli-darwin-arm64v8
tar xzf libvips-cli-darwin-arm64v8.tar.gz -C /tmp/libvips-cli-darwin-arm64v8
/tmp/libvips-cli-darwin-arm64v8/bin/vips --version
otool -L /tmp/libvips-cli-darwin-arm64v8/bin/vips
```

`darwin-x64` should be built on an Intel macOS runner. The included GitHub
Actions workflow uses `macos-15-intel` for this.

## Build Linux with Docker

Linux builds run inside the existing Docker containers:

```sh
./build-cli.sh linux-arm64v8
./build-cli.sh linuxmusl-arm64v8
```

On an Apple Silicon Mac, these arm64 Linux builds are the most natural local
Docker targets.

For x64 Linux artifacts, prefer GitHub Actions or another x86_64 Linux machine:

```sh
./build-cli.sh linux-x64
./build-cli.sh linuxmusl-x64
```

If you want to try x64 locally on Apple Silicon, enable Docker's amd64 emulation
and run:

```sh
DOCKER_DEFAULT_PLATFORM=linux/amd64 ./build-cli.sh linux-x64
DOCKER_DEFAULT_PLATFORM=linux/amd64 ./build-cli.sh linuxmusl-x64
```

This is slower and should be verified on a real x86_64 Linux machine before
shipping.

Verify Linux output in a matching container or host:

```sh
mkdir -p /tmp/libvips-cli-linux-x64
tar xzf libvips-cli-linux-x64.tar.gz -C /tmp/libvips-cli-linux-x64
/tmp/libvips-cli-linux-x64/bin/vips --version
readelf -d /tmp/libvips-cli-linux-x64/bin/vips
```

## GitHub Actions

The `.github/workflows/cli.yml` workflow builds these artifacts:

```text
darwin-arm64v8
darwin-x64
linux-arm64v8
linux-x64
linuxmusl-arm64v8
linuxmusl-x64
```

Run it manually with `workflow_dispatch`.

Pushing to `main` or `master` builds all artifacts and updates the rolling
`cli-latest` GitHub Release. Download the newest tarballs from that release
after the workflow completes.

For a versioned release, push a tag with the `cli-v` prefix:

```sh
git tag cli-v8.18.3-1
git push origin cli-v8.18.3-1
```

The workflow creates or updates the release for that tag and uploads the
`libvips-cli-*.tar.gz` files. The `cli-latest` tag is reserved for the rolling
main/master release, and `cli-v...` tags are reserved for versioned releases so
they do not interfere with the upstream `sharp-libvips` npm release flow.

## Tauri packaging notes

Do not copy only `bin/vips`; the executable expects its shared libraries at
`../lib` relative to itself.

Recommended layout inside your Tauri app resources:

```text
resources/
  libvips/
    darwin-arm64/
      bin/vips
      lib/*.dylib
    linux-x64/
      bin/vips
      lib/*.so
```

Resolve the resource directory at runtime and spawn:

```text
resources/libvips/<platform>/bin/vips
```

If you need to use Tauri `externalBin` directly, create a small Rust sidecar
wrapper for each target triple. The wrapper should locate the bundled libvips
resource directory and execute `bin/vips` from there. This keeps the portable
`bin/../lib` layout intact and avoids copying a single executable without its
dependencies.

## Code signing on macOS

For local testing, ad-hoc signing is usually enough:

```sh
codesign --force --sign - /tmp/libvips-cli-darwin-arm64v8/bin/vips
find /tmp/libvips-cli-darwin-arm64v8/lib -name '*.dylib' -exec codesign --force --sign - {} \;
```

For distribution, sign the extracted binaries and dylibs with your Developer ID
as part of the Tauri app signing/notarization pipeline.
