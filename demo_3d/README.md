# Beacon Runner 3D

`Beacon Runner 3D` 是一个独立的 Godot 3D demo：在封闭训练场中控制胶囊探测员，收集绿色信标，并躲开红色巡逻无人机。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_3d
```

如果你的 Godot 不在 PATH 中，请用本机 Godot 4.6.2 编辑器打开 `demo_3d/project.godot`。

## 测试

```sh
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
```

当前首版已在 Godot `4.6.2.stable.official.71f334935` 通过上述两条 headless 检查。

## 操作

- `WASD` / 方向键：移动
- `Space`：开始、跳跃，或在结束后重开
- `Enter`：开始，或在结束后重开

## 玩法目标

- 在倒计时结束前收集 `5` 个绿色信标。
- 避开 `2` 个红色巡逻无人机。
- 你有 `3` 点护盾；撞到无人机会扣除护盾，并获得短暂无敌。
- 掉出平台、护盾归零或倒计时归零都会失败。

## 主要文件

- `project.godot`：Godot 项目配置和 3D 输入映射。
- `scenes/main.tscn`：主场景、训练场、灯光、相机、UI、玩家实例。
- `scenes/player.tscn`：玩家胶囊角色。
- `scenes/drone.tscn`：巡逻无人机。
- `scenes/beacon.tscn`：可收集发光信标。
- `scripts/main.gd`：游戏流程、生成、UI、倒计时、胜负。
- `scripts/player.gd`：`CharacterBody3D` 输入、移动、跳跃、坠落检测、受击闪烁。
- `scripts/drone.gd`：无人机在线段两端往返巡逻。
- `scripts/beacon.gd`：信标收集信号、旋转和漂浮。
- `DESIGN.md`：首版玩法边界。
- `REFERENCES.md`：使用过的本地 Godot 参考资料。

## 当前实现范围

- 已使用 placeholder 3D 几何体，不依赖外部素材。
- 当前是一个单房间训练场，没有关卡切换。
- 当前没有音频、菜单和角色动画；这些留给后续 polish。
