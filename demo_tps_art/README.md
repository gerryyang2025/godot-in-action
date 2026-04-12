# Tactical Proxy Strike Art

`Tactical Proxy Strike Art` 是基于 `demo_tps/` 玩法基线独立拆出来的 Godot `4.6.2` 第三人称射击 art-pass demo。它保留原版的第三人称移动、瞄准射击、敌人巡逻与部位伤害系统，但单独引入了 `reference/tps-demo/` 中适合迁移的机器人模型、PBR 贴图、工业门体、环境材质和部分特效贴图，用于和原始 `demo_tps` 做直接对比。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_tps_art
```

如果你的 Godot 不在 PATH 中，请用本机 Godot `4.6.2` 编辑器打开 `demo_tps_art/project.godot`。

## 测试

```sh
godot --headless --path demo_tps_art --quit-after 1
godot --headless --editor --quit --path demo_tps_art
```

当前版本已在 Godot `4.6.2.stable.official.71f334935` 通过上述两条 headless 检查。

## 操作

- `WASD` / 方向键：移动
- 鼠标：视角旋转
- `Space`：开始、跳跃，或在结束后重开
- `Right Mouse Button` 或 `Q`：短按切换瞄准，长按保持瞄准
- `Left Mouse Button` 或 `F`：开火，仅在瞄准状态下有效
- `Esc`：释放或重新捕获鼠标
- `Enter`：开始，或在结束后重开

在 MacBook 上，如果触控板右键不顺手，推荐直接用 `Q` 瞄准、`F` 开火；当鼠标已经释放时，按 `Q` 或 `F` 也会重新捕获输入。

## 玩法目标

- 在 `90` 秒倒计时结束前清空 `4` 个巡逻哨兵。
- 你有 `100` 点生命值；头部命中直接致死，胸部伤害高于腿部。
- 回合开始后的前 `3` 秒为部署无敌时间。
- 掉出场地、生命值归零或倒计时归零都会失败。

## 相比 demo_tps 的 art-pass 升级

- 玩家与敌人从 primitive 几何体升级为参考项目机器人模型。
- 地图仍沿用当前训练场布局，但材质换成更接近参考项目的工业科幻 PBR 面板。
- 环境参数改成更写实的日间训练场氛围，弱化了过强的 glow 和冷蓝雾感。
- 玩家与敌人都补上了可见步枪，并把枪械挂点对齐到角色右手骨骼。
- 枪击与命中特效改成了更克制的 tracer 与火花式命中反馈，不再是科幻蓝色能量球。
- 额外加入参考门体作为空间装饰，用来增强场地的工业感与尺度感。

## 主要文件

- `project.godot`：项目配置和输入映射。
- `scenes/main.tscn`：art-pass 主场景、PBR 材质、灯光、装饰门体、HUD、开始页和结算页。
- `scenes/player.tscn`：玩家角色、参考机器人模型、肩后相机、准星和命中盒。
- `scenes/enemy.tscn`：敌人角色、基于玩家同款骨骼模型的人形哨兵、手部挂枪节点和命中盒。
- `scenes/bullet.tscn`：玩家投射物，使用高速 tracer 弹道表现。
- `scenes/impact_effect.tscn`：命中闪光与贴图化冲击效果。
- `scripts/main.gd`：回合流程、敌人生成、HUD 和胜负结算。
- `scripts/player.gd`：第三人称移动、鼠标捕获、瞄准射击和玩家血量逻辑。
- `scripts/enemy.gd`：敌人巡逻/索敌/瞄准/开火状态机，以及 art-pass 模型的死亡淡出处理。
- `assets/reference/`：从 `reference/tps-demo/` 选择性复制过来的模型、贴图和特效素材。

## 当前边界

- 保留了 `demo_tps` 的玩法脚本与训练场布局，便于直接做前后对比。
- 没有直接迁移 `reference/tps-demo/` 的整张关卡、旧动画树或 Godot `3.5.x` 脚本。
- 参考项目中的部分旧模型通过额外贴图别名适配 Godot `4.6.2` 导入流程，但整体仍以“选取资源、重新组装”为原则，而不是直接搬运旧工程。

## 资源说明

- 当前版本复用了 `reference/tps-demo/` 中的角色模型、部分贴图、门体、环境贴图、准星、音乐、音效和特效贴图。
- 具体来源与授权见 [CREDITS.md](/Users/gerry/Proj/github/new/godot-in-action/demo_tps_art/CREDITS.md)。
