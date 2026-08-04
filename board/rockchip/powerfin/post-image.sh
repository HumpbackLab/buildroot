#!/bin/sh
set -eu

BOARD_DIR="$(unset CDPATH; cd -- "$(dirname -- "$0")" && pwd)"
BUILDROOT_DIR="$(unset CDPATH; cd -- "$BOARD_DIR/../../.." && pwd)"

install -m 0644 "$BOARD_DIR/powerfin-layout" \
	"$BINARIES_DIR/powerfin-layout"

"$BUILDROOT_DIR/support/scripts/genimage.sh" \
	-c "$BOARD_DIR/genimage.cfg"

gzip -n -9 -c "$BINARIES_DIR/powerfin-sdcard.img" \
	>"$BINARIES_DIR/powerfin-sdcard.img.gz"
(
	cd "$BINARIES_DIR"
	sha256sum powerfin-sdcard.img.gz \
		>powerfin-sdcard.img.gz.sha256
)
