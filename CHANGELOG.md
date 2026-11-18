# 更新日志

## PJA110 · crDroid Android 17 · 20261118

适配基线：`crDroidAndroid-17.0-20261118-xigua-v13.1`，内核 `5.15.223-g68fc396ad5e5`。以下三份成品已在一加 Ace 2 Pro 当前槽位 A 上配对刷入并成功启动。

### Skyward Recovery

文件：`skyward-v0.3.1-pja110-crDroid-Android17-20261118.img`

相对 20261118 原版 `recovery.img`：

- 注入 Skyward 0.3.1 的主程序、系统初始化资源、字体、配置、MTP 与任务配置；
- 调整 `prop.default` 和 `init.rc`，让 recovery 通过 PJA110 专用包装脚本启动；
- 新增 `recovery_drm_wrapper.sh`：等待 `ssc_interact`，按 PJA110 依赖顺序加载 DRM、霍尔与触摸驱动，传入 AA536 面板参数，等待 `/dev/dri/card0` 后再启动 Skyward；
- 保留 20261118 固件自己的 recovery 底座，避免继续使用上一版系统的底层 ramdisk。

相对旧版 `skyward-v0.3.1-pja110-crDroid-Android17-v16.img`：

- Recovery 底座由旧版 crDroid 更新为 20261118 版本；
- 与新内核 `5.15.223` 和新的配对 vendor_boot 重新适配、重新真机验证；
- 将此前隐藏在成品里的 PJA110 DRM 启动依赖整理成仓库内可追踪脚本。

SHA-256：`3df9d55f70cfe3c124a361bd2ec3f8b875ea22361931aa652eeab975a2ac5813`

### 配对 vendor_boot

文件：`vendor_boot-20261118-recovery-fixed.img`

相对 20261118 原版 `vendor_boot.img`：

- 仅修改 vendor ramdisk 内的 `lib/modules/modules.load.recovery`；
- 从自动加载列表移除 `msm_drm.ko`、`oplus_ak09970.ko`、`synaptics_tcm2.ko`，交给 Recovery 包装脚本在硬件依赖就绪后延迟加载；
- 补齐 `msm_drm` 启动前所需的完整依赖链；
- DTB、bootconfig、内核模块二进制和其余 vendor 文件保持不变；
- 使用本次 OTA 自带的 `5.15.223` 模块，没有跨版本复用旧 vendor_boot。

原版模块列表 SHA-256：`6890e32e6d3c6d1f18ed36b9fd29a6933733a5a22ed6baa93d3bdb828791e027`

修正后模块列表 SHA-256：`037abb1a0a95f8a08729910d67ee08015799734ac22772eed3ab224c05f303b5`

成品 SHA-256：`17fea4f1054fd5f33a10412e87130d3a125ce711574edc78ef88ffb485038787`

### OTA 生存 Magisk 模块

文件：`skyward-pja110-ota-survival-20261118.zip`

这是本次新增的 OTA 后自恢复方案：

- Android 启动完成后检测当前活动槽位；
- 解包当前槽位在 OTA 后得到的**新 vendor_boot**；
- 仅当 `modules.load.recovery` 与已知 20261118 原版哈希一致时修正加载顺序；
- 当前槽位 Recovery 不再是配套 Skyward 时，自动刷回模块内携带的已验证镜像；
- 已经修正的分区会跳过，避免重复写入；
- 遇到未知模块列表时采用 fail-closed 策略：停止修改并记录原因，避免把旧规则盲目套用到新内核；
- 不会把旧槽位或旧系统的 vendor_boot 复制到新 OTA。

运行日志：`/data/adb/modules/skyward_pja110_survival/survival.log`

SHA-256：`41cd145c33005d1775325184ccbf4a5fad32622b00873bd78e0fc03a377b7518`

### 真机验证结果

- Recovery 与 vendor_boot 在槽位 A 配对启动成功；
- `/dev/dri/card0` 正常生成，AA536 面板绑定成功并工作在 120 Hz；
- `msm_drm`、`oplus_ak09970`、`synaptics_tcm2` 正常加载；
- Skyward 进程稳定，触摸、解密、ADB/MTP、Wi-Fi 与备份界面可用；
- Magisk 模块安装、自检和“当前组合已修正”的跳过逻辑验证通过。

## PJA110 · v0.3.1-v16

上一版用于旧 crDroid Android 17 / 5.15.220 基线。升级到 20261118 后不可继续混用其 vendor_boot，历史说明见 [PJA110-PORT.md](PJA110-PORT.md)。
