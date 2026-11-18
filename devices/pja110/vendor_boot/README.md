# PJA110 paired vendor_boot patch

Skyward on the OnePlus Ace 2 Pro (PJA110) must be flashed together with a
vendor_boot built from the **same crDroid/firmware baseline**.  This directory
records the complete, firmware-independent change made to that image.  It does
not redistribute OnePlus/Qualcomm kernel modules or other proprietary blobs.

## Exact change

Only this file inside the single vendor ramdisk fragment is changed:

```text
lib/modules/modules.load.recovery
```

Apply [`modules.load.recovery.patch`](modules.load.recovery.patch) to the file
from the matching, unpacked vendor_boot.  The patch:

- removes `msm_drm.ko`, `oplus_ak09970.ko`, and `synaptics_tcm2.ko` from the
  automatic module list so the recovery init sequence can load them when their
  hardware dependencies are ready;
- inserts the dependency chain needed before `msm_drm.ko` is loaded.

No DTB, bootconfig, vendor_boot header, kernel module, or other ramdisk file was
changed.  The delayed module loading and PJA110 panel argument are implemented
by the Skyward recovery source itself; this patch only fixes the paired
vendor_boot module ordering.

## Reproducing the image

1. Unpack the current-slot vendor_boot with AOSP
   [`unpack_bootimg.py`](https://android.googlesource.com/platform/system/tools/mkbootimg/+/refs/heads/main/unpack_bootimg.py).
2. Decompress the `vendor_ramdisk00` LZ4 legacy stream and extract its `newc`
   CPIO archive while preserving paths, modes, ownership, and symbolic links.
3. From the extracted ramdisk root, run:

   ```sh
   patch -p1 < /path/to/modules.load.recovery.patch
   ```

4. Recreate the CPIO archive deterministically, recompress it as an LZ4 legacy
   stream, and repack vendor_boot using the arguments printed by
   `unpack_bootimg.py --format=mkbootimg`.
5. Verify the patched text-file checksum below.  Image checksums match only
   when the original image, archive ordering/metadata, compression parameters,
   and page padding are identical.

## Verified crDroid Android 17 baseline

### 20261118 / kernel 5.15.223

| Artifact | SHA-256 |
| --- | --- |
| Patched `vendor_boot-20261118-recovery-fixed.img` | `17fea4f1054fd5f33a10412e87130d3a125ce711574edc78ef88ffb485038787` |
| Original `modules.load.recovery` | `6890e32e6d3c6d1f18ed36b9fd29a6933733a5a22ed6baa93d3bdb828791e027` |
| Patched `modules.load.recovery` | `037abb1a0a95f8a08729910d67ee08015799734ac22772eed3ab224c05f303b5` |

The recovery/vendor_boot pair was flashed and boot-tested on slot A. DTB and
bootconfig were verified unchanged. The image retains the updated ROM's own
5.15.223 modules rather than carrying modules forward from the older baseline.

### Previous 5.15.220 baseline

| Artifact | SHA-256 |
| --- | --- |
| Original `vendor_boot_b_before.img` | `6f24911335c0725787f733aacf8f42b2965761ab9880a1da0650443fcd6cbf9f` |
| Patched `vendor_boot_b_recovery_fixed.img` | `0b1cc3c052ee3f835f4ed386c30c0f475430c8a01885dfef7cae8d49da8b9d00` |
| Original `vendor_ramdisk00` | `f49f80184963f310ea325d737007f8003cfad6cc374dd69e8761668b1344d8de` |
| Patched `vendor_ramdisk00` | `24d6ada623ed1f8ad557fa361afe44d80ba3cf15c2f64eb9b53900cae409d0e` |
| Original `modules.load.recovery` | `6890e32e6d3c6d1f18ed36b9fd29a6933733a5a22ed6baa93d3bdb828791e027` |
| Patched `modules.load.recovery` | `037abb1a0a95f8a08729910d67ee08015799734ac22772eed3ab224c05f303b5` |

The tested 192 MiB patched image is published as a release asset rather than a
Git blob.  Do not apply this patch blindly after a ROM or firmware update:
extract the new image, review the module dependency graph, rebuild the pair,
and test it on the updated kernel/vendor combination.
