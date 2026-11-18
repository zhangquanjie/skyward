# 酷安发布文案

## 标题

【一加 Ace 2 Pro】Skyward Recovery 0.3.1｜适配 crDroid Android 17 20261118｜支持 OTA 后自恢复

## 正文

给一加 Ace 2 Pro（PJA110）适配的 Skyward Recovery 更新了。

这次针对 `crDroidAndroid-17.0-20261118-xigua-v13.1` 重新制作了 Recovery 和配套 vendor_boot，已经在真机槽位 A 完整刷入并启动验证。屏幕、120Hz、触摸、Data 解密、ADB/MTP、Wi-Fi、备份界面均可正常使用。

本次一共提供 3 个文件：

1. `skyward-v0.3.1-pja110-crDroid-Android17-20261118.img`

   Recovery 本体。使用 20261118 原版 recovery 作为底座，加入 Skyward 0.3.1，并增加 PJA110 专用 DRM/面板/触摸启动流程。

2. `vendor_boot-20261118-recovery-fixed.img`

   必须配套刷入。它使用 20261118 系统自己的 5.15.223 内核模块，只调整 recovery 模式下的模块加载列表和顺序，没有替换 DTB、bootconfig 或模块二进制。

3. `skyward-pja110-ota-survival-20261118.zip`

   可选 Magisk 模块。系统 OTA 后会处理新活动槽位自己的 vendor_boot，并恢复配套 Recovery。遇到未知版本会停止修改并写日志，不会把旧 vendor_boot 硬套到新内核上。

刷入前务必确认：

- 仅限一加 Ace 2 Pro（PJA110）；
- 当前验证基线仅为 crDroid Android 17 20261118；
- Recovery 和 vendor_boot 必须成对刷入，不能只刷其中一个；
- 解锁、刷机均有风险，请提前备份数据，并给另一槽保留可启动的回退组合；
- 其他 ROM、其他日期版本不要直接套用。

槽位 A 刷入示例：

```text
fastboot getvar current-slot
fastboot flash recovery_a skyward-v0.3.1-pja110-crDroid-Android17-20261118.img
fastboot flash vendor_boot_a vendor_boot-20261118-recovery-fixed.img
fastboot reboot recovery
```

当前槽位是 B 就把 `_a` 改成 `_b`。OTA 生存模块直接在 Magisk 中选择 ZIP 安装即可，日志路径：`/data/adb/modules/skyward_pja110_survival/survival.log`。

校验值：

- Recovery：`3df9d55f70cfe3c124a361bd2ec3f8b875ea22361931aa652eeab975a2ac5813`
- vendor_boot：`17fea4f1054fd5f33a10412e87130d3a125ce711574edc78ef88ffb485038787`
- OTA 模块：`41cd145c33005d1775325184ccbf4a5fad32622b00873bd78e0fc03a377b7518`

下载、完整更新日志和源码：

https://github.com/zhangquanjie/skyward/releases/tag/pja110-crDroid-Android17-v0.3.1-20261118

项目主页：

https://github.com/zhangquanjie/skyward

如果后续 OTA 改了内核或 vendor_boot，请先不要强刷旧配对文件，把新版本号和镜像反馈给我重新适配。

## 推荐配图顺序

1. Skyward 主界面
2. 设备信息页（展示 OnePlus Ace 2 Pro / Android 17 / Skyward 0.3.1）
3. 设置页
4. 备份页
