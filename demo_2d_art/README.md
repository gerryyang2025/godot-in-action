# Signal Sweep Art

`Signal Sweep Art` 是一个独立的 Godot 2D art-pass demo：在保留原始 `Signal Sweep` 玩法基线的前提下，把训练场升级成霓虹雷达风格的可玩示例。

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
- `Space` / `Enter`：开始或在结束后重开

## 玩法目标

- 在倒计时结束前收集 `8` 个信标。
- 避开巡逻无人机。
- 你有 `3` 点护盾；撞到无人机会扣除护盾，并获得短暂无敌。

## 主要文件

- `ART_DIRECTION.md`：本轮 2D 美术方向说明。
- `project.godot`：Godot 项目配置和输入映射。
- `scenes/main.tscn`：主场景、UI、计时器、玩家实例。
- `scenes/player.tscn`：玩家飞船。
- `scenes/drone.tscn`：巡逻无人机。
- `scenes/beacon.tscn`：可收集信标。
- `scripts/main.gd`：游戏流程、生成、计分、胜负。
- `scripts/player.gd`：输入、移动、边界、碰撞转发。
- `scripts/drone.gd`：无人机移动和边界反弹。
- `scripts/beacon.gd`：信标的轻量视觉脉冲。
- `shaders/scan_overlay.gdshader`：全屏扫描线叠层。
- `DESIGN.md`：首版玩法边界。
- `REFERENCES.md`：使用过的本地 Godot 参考资料。

## 当前实现范围

- 已加入霓虹 HUD、扫描叠层、推进器/护盾/危险外环等第一轮美术升级。
- 仍然不依赖外部图片、字体或音频素材。
- 当前是一个固定竞技场，没有关卡切换；原始玩法仍和 `demo_2d/` 保持一致。
