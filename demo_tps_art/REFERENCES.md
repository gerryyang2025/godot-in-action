# Tactical Proxy Strike Art References

## 玩法基线

- `demo_tps/`
  - 直接复用了已有的项目结构、输入映射、玩家与敌人脚本职责拆分、血量系统、开始页/结算页流程和训练场布局。
  - `demo_tps_art/` 的目标是做平行 art-pass，而不是回头修改 `demo_tps/`。

## 外部参考

- `https://github.com/godotengine/tps-demo`
  - 继续参考其 TPS 项目定位、模块拆分、敌人开火节奏和整体视觉方向。

## 本地参考

- `reference/tps-demo/`
  - 参考了 `level/geometry/environment.tres` 的雾效、曝光和工业空间氛围组织方式，但在当前版本里做了更写实、低 glow 的再解释。
  - 迁移了 `player/model/player.glb` 与对应贴图，用于玩家 art-pass 模型。
  - 迁移了 `enemies/red_robot/model/red_robot.dae` 与对应贴图，作为敌人美术探索与素材储备；当前运行时敌人使用的是 `player.glb` 人形基底。
  - 迁移了 `door/model/door.dae` 与贴图，用于场景装饰。
  - 迁移了部分 `level/textures/structure/*.png`，用于训练场 PBR 面板材质。
  - 迁移了 `effects_shared/BlastTexture.png`、`player/bullet/effect/*.png` 等贴图，用于强化 tracer 与命中特效。
  - 该目录是 Godot `3.5.x` 参考项目，在当前 Godot `4.6.2` 环境下不能直接运行，仅用于拆解思路和选择性迁移资源。

- `godot-demo-projects-4.2-31d1c0c/3d/kinematic_character/`
  - 用于核对第三人称移动与相机跟随的 Godot 4 写法。

- `godot-docs-stable/classes/`
  - 用于核对 `CharacterBody3D`、`Camera3D`、`WorldEnvironment`、`Sprite3D`、`PhysicsRayQueryParameters3D` 等 4.6 文档行为。

## 版本说明

- 目标实现版本：Godot `4.6.2`
- 玩法基线项目：`demo_tps/`，Godot `4.6.2`
- 本地 art 资源来源：`reference/tps-demo/`，Godot `3.5.x` 参考工程
- 迁移原则：复制资源、在 Godot `4.6.2` 下重新挂接，不直接复用旧场景脚本
