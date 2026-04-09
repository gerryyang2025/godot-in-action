# References

本 demo 是独立实现；本文件记录使用当前仓库中的哪些 Godot 参考资料来做结构和 API 核对。

## 本地官方 demo

- `godot-demo-projects-4.2-31d1c0c/3d/kinematic_character/`
  - 参考点：`CharacterBody3D`、重力、`move_and_slide()`、相机相关的 3D 角色项目结构。
  - 注意点：该 demo 是 Godot `4.2` 快照；本 demo 只参考运动模式和节点拆分。
- `godot-demo-projects-4.2-31d1c0c/3d/squash_the_creeps/`
  - 参考点：小型 3D demo 的 main scene、玩家 scene、生成对象、UI、重开流程。
  - 注意点：该 demo 使用外部 glb/audio 资产；本 demo 首版不复制这些资产。
- `godot-demo-projects-4.2-31d1c0c/3d/platformer/`
  - 参考点：第三人称角色、收集物、敌人、跟随相机的项目拆分方式。

## 本地官方文档

- `godot-docs-stable/classes/class_characterbody3d.rst`
  - 参考点：3D 角色应将速度写入 `velocity`，再调用 `move_and_slide()`。
- `godot-docs-stable/classes/class_area3d.rst`
  - 参考点：信标和无人机使用 `Area3D` 监听玩家 `body_entered`。
- `godot-docs-stable/classes/class_camera3d.rst`
  - 参考点：main scene 保留一个 `Camera3D`，脚本每帧跟随并 `look_at()` 玩家。
- `godot-docs-stable/tutorials/3d/`
  - 参考点：Godot 3D 坐标、灯光、相机、mesh 和材质的基本组织。
- `godot-docs-stable/tutorials/physics/`
  - 参考点：静态地面/墙使用 `StaticBody3D` + `CollisionShape3D`，玩家使用 `CharacterBody3D`。

## 本 demo 的版本选择

- 目标运行：Godot `4.6.2`。
- 项目特性：`project.godot` 中声明 `config/features=PackedStringArray("4.6")`。
- 参考 demo：Godot `4.2.x`，只参考架构，不直接复制代码或资产。
