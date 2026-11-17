# OnePlus Ace 2 Pro (PJA110) port

This downstream port targets the OnePlus Ace 2 Pro running crDroid Android 17
with the 5.15.220 kernel. It is based on Skyward by kirklin and remains licensed
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
- Kernel: 5.15.220-g7ec40be85325
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

## Current recovery image

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
