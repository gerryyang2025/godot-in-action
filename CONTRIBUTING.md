# Contributing

感谢你愿意改进 `godot-in-action`。这个仓库是 Godot 本地参考工作台，并承载独立的 Godot 2D/3D demo。

## 开始之前

请先阅读：

- `README.md`：当前仓库有什么、哪些目录只是本地参考。
- `AGENTS.md`：LLM/代理和人类协作者都应遵守的仓库边界。
- `PLAN.md`：demo 计划总入口。
- `PLAN_2D.md`：2D demo 的分阶段实现计划。
- `PLAN_3D.md`：3D demo 的分阶段实现计划。
- `PLAN_2D_ART.md`：2D art-pass demo 的分阶段实现计划。
- `PLAN_3D_ART.md`：3D art-pass demo 的分阶段实现计划。

## 开发原则

- 默认目标 Godot 版本是 `4.6.2`。
- 默认使用 GDScript，除非任务明确要求其他语言。
- 不要在仓库根目录创建 `project.godot`。
- 新 demo 默认放在独立顶层目录，例如 `demo_2d/` 或 `demo_3d/`。
- 美术/渲染优化版本也保持独立顶层目录，例如 `demo_2d_art/` 或 `demo_3d_art/`。
- Godot 引擎源码、官方文档镜像、官方 demo 镜像和 awesome-godot 清单是本仓库的参考资料，可以提交。
- 不要把本地 macOS Godot 编辑器 app 提交进普通 Git；如果需要分发编辑器，请先配置 Git LFS 或使用 Release 资产。
- 如果参考 `godot-demo-projects-4.2-31d1c0c/`，请记住它是 Godot `4.2.x` demo，需要按 `4.6.2` 重新验证。

## 提交前检查

- [ ] `git status --short` 中没有意外的编辑器 app、缓存或导出包。
- [ ] 变更过的 Godot 项目能用目标版本打开。
- [ ] 当前 2D demo 可以运行：`godot --path demo_2d`
- [ ] 当前 2D demo 可以 headless 启动：`godot --headless --path demo_2d --quit-after 1`
- [ ] 当前 2D demo 可以导入/加载编辑器：`godot --headless --editor --quit --path demo_2d`
- [ ] 当前 3D demo 可以运行：`godot --path demo_3d`
- [ ] 当前 3D demo 可以 headless 启动：`godot --headless --path demo_3d --quit-after 1`
- [ ] 当前 3D demo 可以导入/加载编辑器：`godot --headless --editor --quit --path demo_3d`
- [ ] 如果改动了 `demo_2d_art/`，可以运行：`godot --path demo_2d_art`
- [ ] 如果改动了 `demo_2d_art/`，请做 headless 验证：`godot --headless --path demo_2d_art --quit-after 1`
- [ ] 如果改动了 `demo_2d_art/`，请做编辑器导入验证：`godot --headless --editor --quit --path demo_2d_art`
- [ ] 如果改动了 `demo_3d_art/`，可以运行：`godot --path demo_3d_art`
- [ ] 如果改动了 `demo_3d_art/`，请做 headless 验证：`godot --headless --path demo_3d_art --quit-after 1`
- [ ] 如果改动了 `demo_3d_art/`，请做编辑器导入验证：`godot --headless --editor --quit --path demo_3d_art`
- [ ] README 或 demo 自身文档已同步更新。
- [ ] 如果引入了第三方资源，已记录来源、作者和许可证。

## Pull Request 建议

PR 请尽量保持小而完整：

- 描述玩家可见的变化。
- 写明被改动的 demo/目录。
- 列出本地验证结果。
- 如果是基于官方 demo 改写，请写明参考路径。
