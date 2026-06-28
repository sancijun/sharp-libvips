#!/usr/bin/env bash
set -e

## Copyright 2017 Lovell Fuller and others.
## SPDX-License-Identifier: Apache-2.0

if [ $# -lt 1 ]; then
  echo
  echo "Usage: $0 PLATFORM"
  echo "Build a portable libvips CLI tarball for macOS/Linux."
  echo
  echo "Possible values for PLATFORM are:"
  echo "- linux-x64"
  echo "- linuxmusl-x64"
  echo "- linux-arm64v8"
  echo "- linuxmusl-arm64v8"
  echo "- darwin-x64"
  echo "- darwin-arm64v8"
  echo
  exit 1
fi

case "$1" in
  linux-x64|linuxmusl-x64|linux-arm64v8|linuxmusl-arm64v8|darwin-x64|darwin-arm64v8)
    BUILD_CLI=true ./build.sh "$1"
    ;;
  *)
    echo "Unsupported CLI platform: $1"
    echo "Windows CLI builds should use the official libvips build-win64-mxe release."
    exit 1
    ;;
esac
