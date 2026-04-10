# References

本 demo 是独立实现；本文件记录使用当前仓库中的哪些 Godot 参考资料来做结构和 API 核对。

## 本地官方 demo

- `godot-demo-projects-4.2-31d1c0c/2d/dodge_the_creeps/`
  - 参考点：独立 `project.godot`、main scene、player scene、计时器驱动、输入动作、重新开始流程。
  - 注意点：该 demo 是 Godot `4.2` 快照；本 demo 的目标版本按 `4.6.2 / 4.6` 文档核对。
- `godot-demo-projects-4.2-31d1c0c/2d/lights_and_shadows/`
  - 参考点：2D 光感、场景层次和发光对象如何帮助读图。
- `godot-demo-projects-4.2-31d1c0c/2d/particles/`
  - 参考点：轻量粒子和运动反馈的组织方式。
- `godot-demo-projects-4.2-31d1c0c/2d/screen_space_shaders/`
  - 参考点：屏幕空间 shader 适合做扫描线和轻后期，而不必改玩法逻辑。

## 本地官方文档

- `godot-docs-stable/classes/class_area2d.rst`
  - 参考点：`Area2D` 可通过子 `CollisionShape2D` 定义检测区域，并通过 area signals 检测重叠。
- `godot-docs-stable/classes/class_characterbody2d.rst`
  - 参考点：`CharacterBody2D` 更适合需要 `move_and_slide()` 的角色。本 demo 的玩家运动是简单俯视边界内滑动，首版选择 `Area2D` 降低节点复杂度。
- `godot-docs-stable/getting_started/first_2d_game/`
  - 参考点：2D 游戏通常拆成 player scene、main scene、HUD、timer、输入动作、碰撞反馈。
- `godot-docs-stable/tutorials/2d/2d_lights_and_shadows.rst`
  - 参考点：2D 场景中的发光对象和整体明暗层次。
- `godot-docs-stable/tutorials/2d/particle_systems_2d.rst`
  - 参考点：后续如需补粒子，可按官方节点组织方式迭代。
- `godot-docs-stable/tutorials/shaders/your_first_shader/your_first_2d_shader.rst`
  - 参考点：本 art 版使用轻量 canvas shader 做扫描叠层。

## 本 demo 的版本选择

- 目标运行：Godot `4.6.2`。
- 项目特性：`project.godot` 中声明 `config/features=PackedStringArray("4.6")`。
- 参考 demo：Godot `4.2.x`，只参考架构，不直接复制代码或资产。
