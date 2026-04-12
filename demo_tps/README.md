# Tactical Proxy Strike

`Tactical Proxy Strike` 是一个独立的 Godot 4.6.2 第三人称射击 demo，参考 `godotengine/tps-demo` 的模块划分与交互节奏，用纯几何体和内置材质实现了一个可运行的轻量版本。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_tps
```

如果你的 Godot 不在 PATH 中，请用本机 Godot 4.6.2 编辑器打开 `demo_tps/project.godot`。

## 测试

```sh
godot --headless --path demo_tps --quit-after 1
godot --headless --editor --quit --path demo_tps
```

当前首版已在 Godot `4.6.2.stable.official.71f334935` 通过上述两条 headless 检查。

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
- 你有 `100` 点生命值；头部命中直接致死，胸部伤害高于腿部，不再使用普通受击后的短暂无敌。
- 回合开始后的前 `3` 秒为部署无敌时间，方便在更大的训练场中找掩体和调整视角。
- 掉出训练场、生命值归零或倒计时归零都会失败。

## 主要文件

- `project.godot`：Godot 项目配置和 TPS 输入映射。
- `scenes/main.tscn`：主场景、训练场、掩体、灯光、HUD、血条、开始页/结算页、玩家实例。
- `scenes/player.tscn`：玩家角色、肩后相机、准星、命中闪屏和部位命中盒。
- `scenes/enemy.tscn`：巡逻哨兵、激光束可视化和部位命中盒。
- `scenes/bullet.tscn`：玩家投射物。
- `scripts/main.gd`：游戏流程、敌人生成、倒计时、HUD、开始页/结算页和胜负判断。
- `scripts/player.gd`：第三人称移动、瞄准切换、鼠标捕获、射击、100 血生命系统和受击逻辑。
- `scripts/enemy.gd`：巡逻/瞄准状态切换、视线检测、敌方开火和部位伤害结算。
- `scripts/bullet.gd`：玩家投射物飞行、命中部位识别与伤害处理。
- `scripts/hitbox.gd`：头部/胸部/腿部命中盒的伤害配置与受击转发。
- `DESIGN.md`：首版设计边界和参考取舍。
- `REFERENCES.md`：参考过的外部和本地 Godot 资料。
- `CREDITS.md`：本轮复用的参考资源与授权说明。

## 当前实现范围

- 已实现第三人称肩后相机、带震动的瞄准射击、贴图准星、玩家投射物、敌方激光攻击，以及更明确的敌人充能预警。
- 已实现更贴地的跳跃手感、更大尺寸的单房间训练场、扩展掩体与障碍物布局、4 条哨兵巡逻路线、倒计时和重开流程。
- 已实现更接近主流 TPS 的 `100` 血生命值玩法，支持头部秒杀、胸部高伤、腿部低伤，以及 HUD 血条反馈。
- 已实现参考 `demo_3d_art` 的开始页和任务结算页，让部署前 briefing 与回合结束后的统计回顾更完整。
- 当前已补上环境雾效、glow、场地导光条、背景音乐，以及跳跃、落地、脚步、开火、命中、爆炸等关键音效。
- 当前仍以 Godot 内置 primitive mesh 和标准材质为主，没有引入完整角色动画系统、菜单系统或高模场景资源。

## 资源说明

- 当前版本复用了 `reference/tps-demo/` 中的少量准星、音乐和音效资源。
- 具体来源与授权见 `CREDITS.md`。
