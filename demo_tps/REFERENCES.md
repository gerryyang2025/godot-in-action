# Tactical Proxy Strike References

## 外部参考

- `https://github.com/godotengine/tps-demo`
  - 参考了 `README.md` 中的控制目标和项目定位。
  - 参考了 `project.godot` 的输入映射命名方式。
  - 参考了 `player/player.gd` 与 `player/player_input.gd` 的职责拆分思路：输入与相机状态一侧、角色运动与射击一侧。
  - 参考了 `enemies/red_robot/red_robot.gd` 的敌人“巡逻 / 瞄准 / 开火”状态节奏。
  - 参考了 `level/level.gd` 的“主场景负责生成玩家与敌人并处理 round flow”模式。

## 本地参考

- `godot-demo-projects-4.2-31d1c0c/3d/kinematic_character/`
  - 用于核对第三人称相机跟随和相机朝向驱动移动的基础写法。
- `demo_3d/`
  - 复用了当前仓库自有 3D demo 的项目组织方式、README / DESIGN / REFERENCES 文档结构，以及轻量 primitive-only 关卡搭建原则。
- `reference/tps-demo/`
  - 参考了 `level/geometry/environment.tres` 的雾效、tone mapping 和 glow 氛围参数方向。
  - 参考了 `player/player.tscn` 与 `player/camera_noise_shake_effect.gd` 的准星、枪口反馈与镜头震动思路。
  - 参考了 `default_bus_layout.tres`、`level/level.tscn`、`enemies/red_robot/*.tscn` 的音乐、音效总线和敌人战斗反馈组织方式。
  - 该目录是 Godot `3.5.x` 参考项目，在当前 Godot `4.6.2` 环境下不能直接运行，仅用于拆解实现思路和资源组织。
- `godot-docs-stable/classes/`
  - 用于核对 `CharacterBody3D`、`Camera3D`、`PhysicsRayQueryParameters3D`、`Timer` 等 4.6 文档描述。

## 版本说明

- 目标实现版本：Godot `4.6.2`
- 外部参考仓库：`godotengine/tps-demo` 的 `master` 分支，README 标注为 Godot `4.x`
- 本地 `reference/tps-demo/`：对应 Godot `3.5.x` 参考项目，不能直接视为 `4.6.2` 可运行工程
- 本地官方 demo 参考：`4.2.x`，仅借鉴结构和思路，不默认与 `4.6.2` 完全等价
