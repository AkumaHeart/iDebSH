#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
OUTPUT_DIR="${1:-$REPO_ROOT}"

echo "==> Building Debian i386 rootfs for iDebSH with Docker..."
docker build \
    --platform=linux/386 \
    -f "$SCRIPT_DIR/Dockerfile" \
    --output type=local,dest="$OUTPUT_DIR" \
    "$SCRIPT_DIR"

if [ -f "$OUTPUT_DIR/root.tar.gz" ]; then
    echo "==> Successfully generated: $OUTPUT_DIR/root.tar.gz"
    ls -lh "$OUTPUT_DIR/root.tar.gz"
else
    echo "Error: root.tar.gz was not found in $OUTPUT_DIR" >&2
    exit 1
fi
