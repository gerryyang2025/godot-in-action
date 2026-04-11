# Signal Sweep Art

`Signal Sweep Art` 是一个独立的 Godot 2D art-pass demo：在保留原始 `Signal Sweep` 玩法基线的前提下，把训练场升级成更克制、可读性优先的霓虹雷达风格示例，并补上开始页、结算页与程序化音频反馈。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_2d_art
```

如果你的 Godot 不在 PATH 中，请用本机 Godot 4.6.2 编辑器打开 `demo_2d_art/project.godot`。

## 测试

```sh
godot --headless --path demo_2d_art --quit-after 1
godot --headless --editor --quit --path demo_2d_art
```

## 命令说明

- `godot --path demo_2d_art`：正常打开 `Signal Sweep Art` 窗口，适合试玩、看 UI、看动画和检查输入反馈。
- `godot --headless --path demo_2d_art --quit-after 1`：无窗口快速启动项目并在 `1` 次迭代后退出，适合提交前做启动级冒烟检查；这里的 `1` 不是 `1` 秒。
- `godot --headless --editor --quit --path demo_2d_art`：让 Godot 以编辑器模式导入并加载项目后退出，适合补充检查脚本、资源导入和编辑器侧错误。

## 操作

- `WASD` / 方向键：移动
- `Space` / `Enter`：在首页开始，或在结束后重开

## 玩法目标

- 在倒计时结束前收集 `8` 个信标。
- 避开巡逻无人机。
- 你有 `3` 点护盾；撞到无人机会扣除护盾，并获得短暂无敌。

## 主要文件

- `ART_DIRECTION.md`：本轮 2D 美术方向说明。
- `project.godot`：Godot 项目配置和输入映射。
- `scenes/main.tscn`：主场景、UI、计时器、玩家实例。
- `default_bus_layout.tres`：`Music / Ambience / SFX / UI` 音频总线布局。
- `scenes/player.tscn`：玩家飞船。
- `scenes/drone.tscn`：巡逻无人机。
- `scenes/beacon.tscn`：可收集信标。
- `scripts/audio_controller.gd`：程序生成背景音乐、结算提示音和交互音效。
- `scripts/main.gd`：游戏流程、生成、计分、胜负。
- `scripts/player.gd`：输入、移动、边界、碰撞转发。
- `scripts/drone.gd`：无人机移动和边界反弹。
- `scripts/beacon.gd`：信标的轻量视觉脉冲。
- `shaders/scan_overlay.gdshader`：全屏扫描线叠层。
- `DESIGN.md`：首版玩法边界。
- `REFERENCES.md`：使用过的本地 Godot 参考资料。

## 当前实现范围

- 已加入霓虹 HUD、扫描叠层、推进器/护盾/危险外环等第一轮美术升级。
- 已保留直接服务玩法的反馈：边界脉冲、状态卡片、信标收集爆发、玩家受击护盾脉冲。
- 已补充首页 briefing、结算页报告和右下角作者署名 `Created by Gerry`。
- 已加入程序生成的占位背景音乐、结算提示音，以及部署、收集、受击、刷怪、边界反弹、倒计时预警等交互音效。
- 已删减大部分无语义的常驻装饰线，背景收敛为星点远景、低对比训练场面板和边界反馈。
- 已把扫描叠层简化为柔和扫描与轻暗角，不再额外叠加噪点干扰。
- 已为低护盾和低时间加入更明确的视觉预警。
- 主场景 `Main` 脚本已提供集中 VFX 参数，可统一开关扫描叠层、屏闪、边界脉冲和收集爆发，方便做可读性对照。
- 当前继续使用 Godot 默认字体，并通过程序生成音频占位，不依赖外部图片、字体或音频素材。
- 当前视觉主要由内置节点、程序化图形和仓库内 shader 构成，没有额外素材包依赖。
- `demo_2d/` 继续保留为玩法基线，可作为 art 版的回退和 A/B 对照目录。
- 当前是一个固定竞技场，没有关卡切换；原始玩法仍和 `demo_2d/` 保持一致。

## 可调参数

- 在 Godot 编辑器中选中 `scenes/main.tscn` 的 `Main` 根节点，可在 Inspector 里看到 `VFX` 分组。
- 当前可直接开关或调节：`enable_scan_overlay`、`scan_overlay_strength`、`enable_screen_flash`、`screen_flash_strength`、`enable_edge_pulses`、`edge_pulse_strength`、`enable_collection_burst`、`collection_burst_strength`。
- 如果要验证“关闭后期效果后是否仍然可读”，优先把 `enable_scan_overlay` 关闭，再检查玩家、信标、无人机和 HUD 是否仍然一眼可分辨。

## 人工验证

- 用 `godot --path demo_2d_art` 打开项目，在原始 `960x640` 窗口下确认顶部状态卡片和底部播报都没有压进竞技场核心路径。
- 把窗口放大后再检查一次，确认状态卡片仍然停留在顶部信息带里，不会挡住玩家或信标常见活动区域。
- 在 Inspector 里选中 `Main` 根节点，关闭 `enable_scan_overlay` 后试玩一小段，确认不依赖扫描叠层也能一眼区分玩家、信标、无人机和 HUD 状态。
- 触发一次收集、一次受击和一次 drone 撞边，确认收集爆发、屏闪和边界脉冲都仍然短促且不会长期遮挡目标。
