#!/system/bin/sh
set -eu

MAGISKBOOT=${MAGISKBOOT:-/data/local/tmp/magiskboot}
WORK=${WORK:-/data/local/tmp/skyward-repack}
STOCK_RECOVERY=${STOCK_RECOVERY:-/data/local/tmp/new-recovery.img}
SKYWARD_BASE=${SKYWARD_BASE:-/data/local/tmp/skyward-unpack/old-recovery/root}
OUT=${OUT:-/data/local/tmp/skyward-20261118-recovery.img}

rm -rf "$WORK"
mkdir -p "$WORK/unpack"
cd "$WORK/unpack"
"$MAGISKBOOT" unpack "$STOCK_RECOVERY"

cp "$SKYWARD_BASE/prop.default" "$WORK/prop.default.old"
cp "$WORK/unpack/ramdisk.cpio" "$WORK/ramdisk.cpio"
"$MAGISKBOOT" cpio "$WORK/ramdisk.cpio" \
  "extract prop.default $WORK/prop.default" \
  "extract system/etc/init/hw/init.rc $WORK/init.rc"
sed -i \
  -e '/^ro.build.version.release=/d' \
  -e '/^ro.build.version.security_patch=/d' \
  -e '/^ro.vendor.build.security_patch=/d' \
  "$WORK/prop.default"
printf '\nro.secure=0\nro.adb.secure=0\nro.debuggable=1\nro.ota.allow_downgrade=true\n' >> "$WORK/prop.default"
sed -i 's#^service recovery /system/bin/recovery$#service recovery /system/bin/recovery_drm_wrapper.sh#' "$WORK/init.rc"
grep -q '^service recovery /system/bin/recovery_drm_wrapper.sh$' "$WORK/init.rc"

"$MAGISKBOOT" cpio "$WORK/ramdisk.cpio" \
  "mkdir 0755 skyward" \
  "add 0755 system/bin/recovery $SKYWARD_BASE/system/bin/recovery" \
  "add 0755 system/bin/recovery_drm_wrapper.sh $SKYWARD_BASE/system/bin/recovery_drm_wrapper.sh" \
  "add 0644 system/etc/init/hw/init.rc $WORK/init.rc" \
  "ln recovery system/bin/7za" \
  "ln recovery system/bin/avbctl" \
  "ln recovery system/bin/resetprop" \
  "ln recovery system/bin/unzip" \
  "ln recovery system/bin/zstd" \
  "add 0755 skyward/system-init $SKYWARD_BASE/skyward/system-init" \
  "add 0644 skyward/device.toml $SKYWARD_BASE/skyward/device.toml" \
  "add 0644 skyward/MiSansVF.ttf $SKYWARD_BASE/skyward/MiSansVF.ttf" \
  "add 0644 skyward/KirkMono-Regular.ttf $SKYWARD_BASE/skyward/KirkMono-Regular.ttf" \
  "add 0644 skyward/KirkMono-OFL.txt $SKYWARD_BASE/skyward/KirkMono-OFL.txt" \
  "add 0644 system/etc/task_profiles.json $SKYWARD_BASE/system/etc/task_profiles.json" \
  "add 0644 system/etc/init/skyward-mtp.rc $SKYWARD_BASE/system/etc/init/skyward-mtp.rc" \
  "add 0644 prop.default $WORK/prop.default"

cp "$WORK/ramdisk.cpio" "$WORK/unpack/ramdisk.cpio"
cd "$WORK/unpack"
"$MAGISKBOOT" repack "$STOCK_RECOVERY" "$OUT"
sha256sum "$OUT"
