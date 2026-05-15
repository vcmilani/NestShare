#!/usr/bin/env bash
set -euo pipefail

VERSION=$(git describe --tags --always 2>/dev/null || git rev-parse --short HEAD)
OUTPUT="nestshare-${VERSION}.zip"

git archive --format=zip --prefix=nestshare/ HEAD -o "$OUTPUT"

echo "Gerado: $OUTPUT"
