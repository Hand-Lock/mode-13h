#!/bin/sh
# Zip the committed shaders/ and LICENSE into dist/mode-13h-<version>.zip.
# Built from `git archive HEAD`, so uncommitted changes and Finder junk never
# get in.
# Usage: tools/build.sh [version]   (default: git describe)
set -eu

cd "$(dirname "$0")/.."
ver=${1:-$(git describe --tags --always)}
out=dist/mode-13h-$ver.zip

[ -z "$(git status --porcelain -- shaders LICENSE)" ] ||
    echo "build: warning: uncommitted changes in shaders/ are not included" >&2

mkdir -p dist
rm -f "$out"
git archive --format=zip -o "$out" HEAD shaders LICENSE
echo "$out"
