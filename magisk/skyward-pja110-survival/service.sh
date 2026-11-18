#!/system/bin/sh
MODDIR=${0%/*}
LOG="$MODDIR/survival.log"

# Let Android finish marking the new A/B slot successful before touching its
# recovery-only files. This service never changes boot, init_boot, vbmeta or
# the active slot.
until [ "$(getprop sys.boot_completed)" = 1 ]; do sleep 5; done
sh "$MODDIR/patch-current-slot.sh" >>"$LOG" 2>&1
