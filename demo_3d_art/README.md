# Beacon Runner 3D Art

`Beacon Runner 3D Art` 是一个独立的 Godot 3D 美术优化示例：在不改动原始 `demo_3d/` 基线的前提下，把同一套收集/躲避玩法放进一个更强调材质、受控边界高光、环境氛围和 HUD 质感的训练场。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_3d_art
```

如果你的 Godot 不在 PATH 中，请用本机 Godot 4.6.2 编辑器打开 `demo_3d_art/project.godot`。

## 测试

```sh
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
```

## 命令说明

- `godot --path demo_3d_art`：正常打开 `Beacon Runner 3D Art` 窗口，适合实际游玩、观察材质、灯光和 HUD 效果。
- `godot --headless --path demo_3d_art --quit-after 1`：无窗口快速启动项目并在 `1` 次迭代后退出，适合提交前做启动级冒烟检查；这里的 `1` 不是 `1` 秒。
- `godot --headless --editor --quit --path demo_3d_art`：让 Godot 以编辑器模式导入并加载项目后退出，适合补充检查脚本、资源导入和编辑器侧错误。

建议同时保留 `demo_3d/` 作为玩法基线，对比美术层面的变化。

## 操作

- `WASD` / 方向键：移动
- `Space`：开始、跳跃，或在结束后重开
- `Enter`：开始，或在结束后重开

## 玩法目标

- 在倒计时结束前收集 `5` 个绿色信标。
- 开局避开 `3` 个红色巡逻无人机；收集到第 `3` 个信标后，东侧还会加入 `1` 个增援巡逻机。
- 你有 `3` 点护盾；撞到无人机会扣除护盾，并获得短暂无敌。
- 掉出平台、护盾归零或倒计时归零都会失败。

## 主要文件

- `project.godot`：Godot 项目配置和 3D 输入映射。
- `ART_DIRECTION.md`：本美术版的视觉目标、配色和轮廓规则。
- `materials/`：主场景、玩家、信标、无人机使用的命名材质资源。
- `scenes/main.tscn`：训练场、`WorldEnvironment`、灯光、相机、HUD。
- `scenes/player.tscn`：升级后的探索装玩家轮廓。
- `scenes/drone.tscn`：带旋翼与危险环的巡逻无人机。
- `scenes/beacon.tscn`：带底座、环轨和光柱的发光信标。
- `scripts/main.gd`：游戏流程、HUD 更新、屏幕闪光反馈。
- `scripts/player.gd`：移动、跳跃和推进器/头灯视觉反馈。
- `scripts/drone.gd`：巡逻、旋翼转动、危险环脉冲。
- `scripts/beacon.gd`：信标旋转、悬浮、光柱和 halo 动画。
- `DESIGN.md`：玩法范围和本次 art pass 的边界。
- `REFERENCES.md`：使用过的本地 Godot 参考资料。

## 当前实现范围

- 仍然只使用 Godot 内置 primitive mesh、材质、灯光和 Label，不依赖外部模型或贴图。
- 当前是一个单房间训练场，没有关卡切换。
- 当前玩法已升级为“3 架开局巡逻 + 1 架阶段性增援”，让后半程收集更紧张。
- 当前重点是首轮视觉升级：命名材质、环境雾、受控边界高光、轮廓增强、HUD 气质统一。
- 音频、外部模型、贴图、粒子和后期 shader 仍留给下一轮 polish。
