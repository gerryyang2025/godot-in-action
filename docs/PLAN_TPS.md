# demo_tps 实现计划

本文件记录 `demo_tps/` 的目标边界、已完成内容和后续可迭代方向。它对应当前仓库里的轻量第三人称射击 demo：`Tactical Proxy Strike`。

## 当前定位

- 项目目录：`demo_tps/`
- 目标版本：Godot `4.6.2`
- 脚本语言：`GDScript`
- 参考来源：`godotengine/tps-demo` 的输入 / 相机 / 状态机职责拆分 + 本地官方和自有 3D demo 的结构约定

## 当前已完成

- 已完成独立 Godot 项目：`demo_tps/project.godot`
- 已完成第三人称肩后相机和鼠标视角
- 已完成玩家移动、跳跃、瞄准切换、准星和开火
- 已完成敌人巡逻、视线检测、瞄准和激光攻击
- 已完成单房间训练场、掩体、倒计时、胜负和重开流程
- 已完成 `README.md`、`DESIGN.md`、`REFERENCES.md`
- 已完成 Godot 4.6.2 headless 启动和编辑器导入检查

## 首版验收标准

- `godot --path demo_tps` 可以正常进入可操作场景
- `godot --headless --path demo_tps --quit-after 1` 通过
- `godot --headless --editor --quit --path demo_tps` 通过
- 玩家可以通过 `WASD + 鼠标 + RMB + LMB` 完成完整战斗循环
- 倒计时、护甲、敌人数、状态提示能正确更新

## 后续可选迭代

1. 给玩家和敌人补上更明确的击中、受击和死亡反馈。
2. 增加更丰富的掩体形态、坡道或高低差，提升第三人称空间感。
3. 为敌人加入更完整的追击、换位或压制射击逻辑。
4. 增加菜单、暂停、音效和更完整的 UI 风格化包装。
5. 在独立目录中做一个 `demo_tps_art/`，而不是直接破坏当前基线。
