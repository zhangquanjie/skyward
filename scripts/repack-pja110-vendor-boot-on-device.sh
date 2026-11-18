#!/system/bin/sh
set -eu

MAGISKBOOT=${MAGISKBOOT:-/data/local/tmp/magiskboot}
WORK=${WORK:-/data/local/tmp/skyward-vendor-repack}
STOCK_VENDOR_BOOT=${STOCK_VENDOR_BOOT:-/data/local/tmp/new-vendor.img}
PATCHED_MODULES=${PATCHED_MODULES:-/data/local/tmp/skyward-unpack/old-vendor/vendor_ramdisk/root/lib/modules/modules.load.recovery}
OUT=${OUT:-/data/local/tmp/skyward-20261118-vendor_boot.img}

rm -rf "$WORK"
mkdir -p "$WORK"
cd "$WORK"
"$MAGISKBOOT" unpack "$STOCK_VENDOR_BOOT" || true

"$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio \
  "add 0644 lib/modules/modules.load.recovery $PATCHED_MODULES"

"$MAGISKBOOT" repack "$STOCK_VENDOR_BOOT" "$OUT"
sha256sum "$OUT"
