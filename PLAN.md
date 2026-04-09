# Godot Demo 实现路线图

本文件是当前仓库的计划入口。2D 和 3D demo 的详细执行清单已经拆分到独立文件中，避免后续实现时互相污染。

## 计划文件

- `PLAN_2D.md`：`demo_2d/` 的详细实现计划、当前进度、参考样例、验收标准。
- `PLAN_3D.md`：`demo_3d/` 的详细实现计划、推荐首版方向、3D 参考样例、验收标准。
- `demo_2d/README.md`：已实现 2D demo 的运行方式、玩法和实现说明。

## 当前状态

- 已完成独立 2D demo 项目：`demo_2d/`
- 已完成 2D demo CLI 文档：`godot --path demo_2d`
- 已规划独立 3D demo 项目：`demo_3d/`
- 尚未创建 3D demo 代码目录。

## 通用约定

- 根目录是学习/参考工作台，不是 Godot 游戏项目。
- 新 demo 必须放入独立顶层目录，例如 `demo_2d/` 或 `demo_3d/`。
- 不要直接修改这些参考目录：
  - `godot-4.6.2-stable/`
  - `godot-docs-stable/`
  - `godot-demo-projects-4.2-31d1c0c/`
  - `awesome-godot-master/`
- 优先使用仓库中已纳入版本控制的 Godot 参考材料。
- 若复制外部素材，必须记录来源、许可证和 attribution。

## 常用命令

运行 2D demo：

```sh
godot --path demo_2d
```

验证 2D demo：

```sh
godot --headless --path demo_2d --quit-after 1
godot --headless --editor --quit --path demo_2d
```

未来运行 3D demo：

```sh
godot --path demo_3d
```

## 推荐下一步

1. 继续打磨 `demo_2d/` 时，先看 `PLAN_2D.md` 和 `demo_2d/README.md`。
2. 开始实现 3D demo 前，先看 `PLAN_3D.md` 的“开始前决策点”。
3. 创建 `demo_3d/` 后，同步补 `demo_3d/README.md`、`DESIGN.md` 和 `REFERENCES.md`。
