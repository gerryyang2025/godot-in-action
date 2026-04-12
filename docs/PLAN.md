# Godot Demo 实现路线图

本文件是当前仓库的计划入口。2D 和 3D demo 的详细执行清单已经拆分到 `docs/` 下的独立文件中，避免后续实现时互相污染。

## 计划文件

- `docs/PLAN_2D.md`：`demo_2d/` 的详细实现计划、当前进度、参考样例、验收标准。
- `docs/PLAN_3D.md`：`demo_3d/` 的详细实现计划、推荐首版方向、3D 参考样例、验收标准。
- `docs/PLAN_2D_ART.md`：基于 `demo_2d/` 的独立 2D 美术优化示例计划；当前首轮实现已落到 `demo_2d_art/`。
- `docs/PLAN_3D_ART.md`：基于 `demo_3d/` 的独立 3D 美术优化示例计划；当前首轮实现已落到 `demo_3d_art/`。
- `docs/PLAN_TPS.md`：基于 `godotengine/tps-demo` 思路实现的独立 TPS demo 计划；当前首轮实现已落到 `demo_tps/`。
- `demo_2d/README.md`：已实现 2D demo 的运行方式、玩法和实现说明。
- `demo_3d/README.md`：已实现 3D demo 的运行方式、玩法和实现说明。
- `demo_2d_art/README.md`：已实现 2D art-pass demo 的运行方式、美术目标和实现说明。
- `demo_3d_art/README.md`：已实现 3D art-pass demo 的运行方式、美术目标和实现说明。
- `demo_tps/README.md`：已实现 TPS demo 的运行方式、交互和实现说明。
- `demo_tps_art/README.md`：已实现 TPS art-pass demo 的运行方式、美术升级点和资源说明。

## 当前状态

- 已完成独立 2D demo 项目：`demo_2d/`
- 已完成 2D demo CLI 文档：`godot --path demo_2d`
- 已完成独立 3D demo 首版：`demo_3d/`
- 已完成 3D demo CLI 文档：`godot --path demo_3d`
- 已完成独立 2D art-pass demo 首轮：`demo_2d_art/`
- 已完成 2D art-pass demo CLI 文档：`godot --path demo_2d_art`
- 已完成独立 3D art-pass demo 首轮：`demo_3d_art/`
- 已完成 3D art-pass demo CLI 文档：`godot --path demo_3d_art`
- 已完成独立 TPS demo 首轮：`demo_tps/`
- 已完成 TPS demo CLI 文档：`godot --path demo_tps`
- 已完成独立 TPS art-pass demo 首轮：`demo_tps_art/`
- 已完成 TPS art-pass demo CLI 文档：`godot --path demo_tps_art`
- `demo_2d/`、`demo_3d/`、`demo_tps/` 作为当前玩法基线版本保留
- `demo_2d_art/`、`demo_3d_art/`、`demo_tps_art/` 作为当前独立美术优化版本保留

## 通用约定

- 根目录是学习/参考工作台，不是 Godot 游戏项目。
- 新 demo 必须放入独立顶层目录，例如 `demo_2d/` 或 `demo_3d/`。
- 美术/渲染优化版本也必须使用独立顶层目录，例如 `demo_2d_art/` 或 `demo_3d_art/`。
- 不要直接在 `demo_2d/`、`demo_3d/` 上做破坏原始基线的美术实验；它们应保留为当前可运行基线。
- 不要直接修改这些参考目录：
  - `godot-4.6.2-stable/`
  - `godot-docs-stable/`
  - `godot-demo-projects-4.2-31d1c0c/`
  - `awesome-godot-master/`
  - `reference/`
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

运行 3D demo：

```sh
godot --path demo_3d
```

验证 3D demo：

```sh
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
```

运行 2D art demo：

```sh
godot --path demo_2d_art
```

验证 2D art demo：

```sh
godot --headless --path demo_2d_art --quit-after 1
godot --headless --editor --quit --path demo_2d_art
```

运行 3D art demo：

```sh
godot --path demo_3d_art
```

验证 3D art demo：

```sh
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
```

运行 TPS demo：

```sh
godot --path demo_tps
```

验证 TPS demo：

```sh
godot --headless --path demo_tps --quit-after 1
godot --headless --editor --quit --path demo_tps
```

运行 TPS art demo：

```sh
godot --path demo_tps_art
```

验证 TPS art demo：

```sh
godot --headless --path demo_tps_art --quit-after 1
godot --headless --editor --quit --path demo_tps_art
```

## 推荐下一步

1. 继续打磨 `demo_2d/` 时，先看 `docs/PLAN_2D.md` 和 `demo_2d/README.md`。
2. 继续打磨 `demo_3d/` 时，先看 `docs/PLAN_3D.md` 和 `demo_3d/README.md`。
3. 继续打磨 2D art-pass 时，先看 `docs/PLAN_2D_ART.md` 和 `demo_2d_art/README.md`。
4. 继续打磨 3D art-pass 时，先看 `docs/PLAN_3D_ART.md` 和 `demo_3d_art/README.md`。
5. 继续打磨 TPS demo 时，先看 `docs/PLAN_TPS.md` 和 `demo_tps/README.md`。
6. 继续打磨 TPS art-pass 时，先看 `demo_tps_art/README.md`、`demo_tps_art/DESIGN.md` 和 `demo_tps_art/REFERENCES.md`。
7. 提交前分别跑目标 demo 的 headless 主场景和编辑器导入验证。
