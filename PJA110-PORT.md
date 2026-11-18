# OnePlus Ace 2 Pro (PJA110) port

This downstream port targets the OnePlus Ace 2 Pro running crDroid Android 17.
It is based on Skyward by kirklin and remains licensed
under GPL-3.0-or-later. The upstream project is:

https://github.com/kirklin/skyward

## Device-specific boot pairing

PJA110 requires `recovery` and `vendor_boot` to be installed as a pair. The
stock recovery module list starts `msm_drm` before all of its dependencies and
before the AA536 P 3 A0001 DSI panel is ready. The paired vendor_boot used by
this port:

1. loads the current ROM's complete dependency chain for `msm_drm`;
2. delays `msm_drm`, `oplus_ak09970`, and `synaptics_tcm2`;
3. starts DRM with the PJA110 panel parameter;
4. waits for `/dev/dri/card0`, then starts Skyward;
5. loads the Synaptics S3910 touch driver after the panel is bound.

The binary kernel modules are not committed to this repository. They remain
part of the user's installed firmware/vendor_boot. Build and redistribution of
firmware-derived images must follow the applicable firmware terms.

The exact vendor_boot ramdisk change, checksums, and reproduction notes are in
[`devices/pja110/vendor_boot`](devices/pja110/vendor_boot/README.md). The only
modified ramdisk file is `lib/modules/modules.load.recovery`; proprietary
modules, DTB, bootconfig, and all other vendor files are unchanged.

## Verified baseline

- Device: PJA110 / OP5943L1
- Android: 17
- Kernel: 5.15.223-g68fc396ad5e5 (current 20261118 baseline)
- Display: 1240 x 2772 at density 480
- Panel: `qcom,mdss_dsi_panel_AA536_P_3_A0001_dsc_cmd`
- Touch: Synaptics S3910 (`synaptics_tcm2`)
- Haptics: disabled because the recovery driver reports a 0 Hz resonance
- Recovery partition size: 100 MiB
- Vendor boot partition size: 192 MiB
- USB: pure `adb` at rest; pure MTP while file transfer is enabled, with
  Windows read/write verified; disabling file transfer restores adb
- Data: device-encrypted storage and user credential decryption verified
- Wi-Fi: WCN7850/Kiwi v2, scan/association/DHCP/internet verified

## Current recovery image and downloads

### crDroid 20261118

The image tested with crDroidAndroid-17.0-20261118-xigua-v13.1 is
`skyward-v0.3.1-pja110-crDroid-Android17-20261118.img`, SHA-256:

```text
3df9d55f70cfe3c124a361bd2ec3f8b875ea22361931aa652eeab975a2ac5813
```

Its paired image is `vendor_boot-20261118-recovery-fixed.img`, SHA-256:

```text
17fea4f1054fd5f33a10412e87130d3a125ce711574edc78ef88ffb485038787
```

The pair was boot-tested on slot A with kernel
`5.15.223-g68fc396ad5e5`. DRM created `/dev/dri/card0`, the AA536 panel
bound at 120 Hz, and the Synaptics touch modules loaded.

All three current artifacts are published in the
[20261118 GitHub release](https://github.com/zhangquanjie/skyward/releases/tag/pja110-crDroid-Android17-v0.3.1-20261118).
The exact user-facing differences are recorded in [`CHANGELOG.md`](CHANGELOG.md).

The device-specific recovery wrapper is now tracked in
[`devices/pja110/recovery`](devices/pja110/recovery), and the reproducible
on-device repack scripts are under [`scripts`](scripts). They must be used
together with the matching OTA's stock recovery and vendor_boot images.

### Previous 5.15.220 baseline

The Skyward 0.3.1 image is
`skyward-v0.3.1-pja110-crDroid-Android17-v16.img` (100 MiB), SHA-256:

```text
3d7990ca81747e6ac8231e100ead7a4a13d48c7fc8878073d3f08c1bba0a9b0f
```

It was built and linted for Android arm64 by GitHub Actions, flashed to slot B,
and boot-tested with the paired `vendor_boot_b` described above. The Skyward UI
and the PJA110 pure-MTP USB mode both started successfully on the device.

The tested paired image is `vendor_boot_b_recovery_fixed.img` (192 MiB),
SHA-256:

```text
0b1cc3c052ee3f835f4ed386c30c0f475430c8a01885dfef7cae8d49da8b9d00
```

The port must be tested with the paired images on the exact firmware baseline;
an OTA can replace either partition and require rebuilding/reflashing the pair.

## Surviving later OTAs

`skyward-pja110-ota-survival-20261118.zip` is a Magisk module that checks the
active slot after Android finishes booting. If an OTA restored the known stock
`modules.load.recovery`, it patches that slot's own new vendor_boot in place and
restores the tested Skyward recovery image. It never copies an old vendor_boot
across an OTA, because its kernel modules must match the updated kernel.

For safety, an unknown module list is not modified. The module writes the
reason to `/data/adb/modules/skyward_pja110_survival/survival.log`; in that case
the new OTA must be reviewed and the expected list/checksums updated before the
pair is flashed. This fail-closed behavior prevents an outdated module ordering
from being applied blindly to a changed kernel baseline.
