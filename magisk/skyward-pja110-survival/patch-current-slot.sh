#!/system/bin/sh
set -eu

MODDIR=${0%/*}
SLOT=$(getprop ro.boot.slot_suffix)
BY_NAME=/dev/block/by-name
VENDOR_BOOT="$BY_NAME/vendor_boot$SLOT"
RECOVERY="$BY_NAME/recovery$SLOT"
SKYWARD="$MODDIR/skyward-recovery.img"
WORK=/data/local/tmp/skyward-pja110-survival
STOCK_LIST=6890e32e6d3c6d1f18ed36b9fd29a6933733a5a22ed6baa93d3bdb828791e027
PATCHED_LIST=037abb1a0a95f8a08729910d67ee08015799734ac22772eed3ab224c05f303b5

case "$SLOT" in _a|_b) ;; *) echo "invalid slot suffix: $SLOT"; exit 1;; esac
[ -b "$VENDOR_BOOT" ] && [ -b "$RECOVERY" ] && [ -f "$SKYWARD" ]

MAGISK_TMP=$(magisk --path)
MAGISKBOOT="$MAGISK_TMP/magiskboot"
[ -x "$MAGISKBOOT" ] || MAGISKBOOT=/data/adb/magisk/magiskboot
[ -x "$MAGISKBOOT" ]

rm -rf "$WORK"
mkdir -p "$WORK"
dd if="$VENDOR_BOOT" of="$WORK/vendor_boot.img" bs=4M
cd "$WORK"
"$MAGISKBOOT" unpack vendor_boot.img || true
"$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio \
  "extract lib/modules/modules.load.recovery $WORK/modules.load.recovery"

SUM=$(sha256sum "$WORK/modules.load.recovery" | cut -d' ' -f1)
case "$SUM" in
  "$PATCHED_LIST") echo "vendor_boot$SLOT is already patched" ;;
  "$STOCK_LIST")
    "$MAGISKBOOT" cpio vendor_ramdisk/ramdisk.cpio \
      "add 0644 lib/modules/modules.load.recovery $MODDIR/modules.load.recovery.patched"
    "$MAGISKBOOT" repack vendor_boot.img "$WORK/vendor_boot.patched.img"
    [ "$(stat -c %s "$WORK/vendor_boot.patched.img")" = "$(blockdev --getsize64 "$VENDOR_BOOT")" ]
    dd if="$WORK/vendor_boot.patched.img" of="$VENDOR_BOOT" bs=4M conv=fsync
    echo "patched vendor_boot$SLOT from its OTA-provided image"
    ;;
  *)
    echo "refusing unknown modules.load.recovery $SUM; update the PJA110 patch first"
    exit 2
    ;;
esac

WANT=$(sha256sum "$SKYWARD" | cut -d' ' -f1)
HAVE=$(sha256sum "$RECOVERY" | cut -d' ' -f1)
if [ "$HAVE" != "$WANT" ]; then
  [ "$(stat -c %s "$SKYWARD")" = "$(blockdev --getsize64 "$RECOVERY")" ]
  dd if="$SKYWARD" of="$RECOVERY" bs=4M conv=fsync
  echo "restored Skyward to recovery$SLOT"
else
  echo "recovery$SLOT already holds Skyward"
fi

rm -rf "$WORK"
echo "PJA110 Skyward pair is ready on $SLOT"
