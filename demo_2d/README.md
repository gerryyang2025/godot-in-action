# Signal Sweep

`Signal Sweep` 是一个独立的 Godot 2D demo：驾驶小飞船回收信标，并在固定竞技场里躲开弹射移动的巡逻无人机。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_2d
```

如果你的 Godot 不在 PATH 中，请用本机 Godot 4.6.2 编辑器打开 `demo_2d/project.godot`。

## 操作

- `WASD` / 方向键：移动
- `Space` / `Enter`：开始或在结束后重开

## 玩法目标

- 在倒计时结束前收集 `8` 个信标。
- 避开巡逻无人机。
- 你有 `3` 点护盾；撞到无人机会扣除护盾，并获得短暂无敌。

## 主要文件

- `project.godot`：Godot 项目配置和输入映射。
- `scenes/main.tscn`：主场景、UI、计时器、玩家实例。
- `scenes/player.tscn`：玩家飞船。
- `scenes/drone.tscn`：巡逻无人机。
- `scenes/beacon.tscn`：可收集信标。
- `scripts/main.gd`：游戏流程、生成、计分、胜负。
- `scripts/player.gd`：输入、移动、边界、碰撞转发。
- `scripts/drone.gd`：无人机移动和边界反弹。
- `scripts/beacon.gd`：信标的轻量视觉脉冲。
- `DESIGN.md`：首版玩法边界。
- `REFERENCES.md`：使用过的本地 Godot 参考资料。

## 当前实现范围

- 已使用 placeholder 几何图形，不依赖外部素材。
- 当前是一个固定竞技场，没有关卡切换。
- 当前没有音频；音效和音乐留给后续 polish。
