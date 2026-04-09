# Contributing

感谢你愿意改进 `godot-in-action`。这个仓库当前是 Godot 本地参考工作台，未来会承载独立的 Godot 2D demo。

## 开始之前

请先阅读：

- `README.md`：当前仓库有什么、哪些目录只是本地参考。
- `AGENTS.md`：LLM/代理和人类协作者都应遵守的仓库边界。
- `PLAN.md`：后续 2D demo 的分阶段实现计划。

## 开发原则

- 默认目标 Godot 版本是 `4.6.2`。
- 默认使用 GDScript，除非任务明确要求其他语言。
- 不要在仓库根目录创建 `project.godot`。
- 新 demo 默认放在独立顶层目录，例如 `demo_2d/`。
- 不要把本地 Godot 编辑器、Godot 引擎源码、官方文档镜像、官方 demo 镜像提交进根仓库。
- 如果参考 `godot-demo-projects-4.2-31d1c0c/`，请记住它是 Godot `4.2.x` demo，需要按 `4.6.2` 重新验证。

## 提交前检查

- [ ] `git status --short` 中没有意外的上游镜像、编辑器 app、缓存或导出包。
- [ ] 变更过的 Godot 项目能用目标版本打开。
- [ ] 主场景可以从项目设置中的 main scene 运行。
- [ ] README 或 demo 自身文档已同步更新。
- [ ] 如果引入了第三方资源，已记录来源、作者和许可证。

## Pull Request 建议

PR 请尽量保持小而完整：

- 描述玩家可见的变化。
- 写明被改动的 demo/目录。
- 列出本地验证结果。
- 如果是基于官方 demo 改写，请写明参考路径。
