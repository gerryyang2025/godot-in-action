# godot-in-action

这是一个 Godot 学习和 demo 开发工作台。仓库已经包含六个独立可运行项目：`demo_2d/` 的 `Signal Sweep`、`demo_3d/` 的 `Beacon Runner 3D`、`demo_2d_art/` 的 `Signal Sweep Art`、`demo_3d_art/` 的 `Beacon Runner 3D Art`、`demo_tps/` 的 `Tactical Proxy Strike`，以及 `demo_tps_art/` 的 `Tactical Proxy Strike Art`；同时也把 Godot 引擎源码、官方文档源码、官方 demo 项目集和社区资源清单放在同一个目录中，方便离线检索、对照学习和快速取样。

## 仓库定位

- 目标：为自定义 Godot demo 的设计、实现、验证提供本地参考资料和独立 demo 工程。
- 当前状态：已包含独立 `demo_2d/`、`demo_3d/`、`demo_2d_art/`、`demo_3d_art/`、`demo_tps/` 和 `demo_tps_art/`；根目录仍是工作台，不是 Godot 项目。
- 使用方式：把这里当作 Godot 本地知识库与样例库，而不是把根目录直接当成一个 Godot 工程打开。
- GitHub 提交范围：提交本仓库原创文档、配置、独立 demo 和本地 Godot 参考资料目录；本地 macOS Godot 编辑器 app 暂不进普通 Git。

## 快速开始

前提：安装 Godot `4.6.2`，并确认 `godot` 命令在 PATH 中。

运行当前 2D demo：

```sh
godot --path demo_2d
```

运行当前 3D demo：

```sh
godot --path demo_3d
```

运行当前 2D art demo：

```sh
godot --path demo_2d_art
```

运行当前 3D art demo：

```sh
godot --path demo_3d_art
```

运行当前 TPS demo：

```sh
godot --path demo_tps
```

运行当前 TPS art demo：

```sh
godot --path demo_tps_art
```

提交前快速验证六个 demo：

```sh
godot --headless --path demo_2d --quit-after 1
godot --headless --editor --quit --path demo_2d
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
godot --headless --path demo_2d_art --quit-after 1
godot --headless --editor --quit --path demo_2d_art
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
godot --headless --path demo_tps --quit-after 1
godot --headless --editor --quit --path demo_tps
godot --headless --path demo_tps_art --quit-after 1
godot --headless --editor --quit --path demo_tps_art
```

命令说明：

- `godot --path <demo_dir>`：正常启动项目并打开窗口，适合实际试玩、查看画面和交互。
- `godot --headless --path <demo_dir> --quit-after 1`：无窗口快速启动项目并在 `1` 次迭代后退出，适合提交前做冒烟检查；这里的 `1` 代表迭代次数，不是 `1` 秒。
- `godot --headless --editor --quit --path <demo_dir>`：以编辑器模式导入并加载项目后退出，适合检查资源导入、脚本加载和编辑器侧报错。

## 当前内容总览

| 路径 | 内容 | 角色 | 备注 |
| --- | --- | --- | --- |
| `godot-4.6.2-stable/` | Godot 引擎源码 | 底层行为与 API 参考 | 含 `SConstruct`、`version.py` 等构建入口 |
| `godot-docs-stable/` | Godot 官方文档源码 | 概念与 API 文档参考 | `conf.py` 中版本为 `4.6`，当前是 reST 源码，不是已构建 HTML |
| `godot-demo-projects-4.2-31d1c0c/` | Godot 官方 demo 项目集 | 场景/脚本/玩法实现参考 | 共 `108` 个 demo，目录名表明是 `4.2` 分支快照 |
| `awesome-godot-master/` | Awesome Godot 资源清单 | 扩展资源发现 | 适合找第三方项目、插件、模板，不是 API 真正依据 |
| `reference/` | 本地参考项目集合 | 定向玩法/资源参考 | 当前包含 `tps-demo/`；该项目基于 Godot `3.5.x`，用于参考，不可直接在 `4.6.2` 下运行 |
| `demo_2d/` | Signal Sweep | 当前 2D demo | Godot 4.6.2 验证的俯视收集/躲避 demo |
| `demo_3d/` | Beacon Runner 3D | 当前 3D demo | Godot 4.6.2 验证的 3D 收集/躲避 demo |
| `demo_2d_art/` | Signal Sweep Art | 独立 2D art-pass demo | 保留 `demo_2d/` 玩法基线，验证 HUD / shader / 视觉升级 |
| `demo_3d_art/` | Beacon Runner 3D Art | 独立 3D art-pass demo | 保留 `demo_3d/` 玩法基线，验证材质 / 环境 / HUD 升级 |
| `demo_tps/` | Tactical Proxy Strike | 独立 TPS demo | 参考 `godotengine/tps-demo` 的交互和模块划分，用内置几何体实现第三人称射击训练场 |
| `demo_tps_art/` | Tactical Proxy Strike Art | 独立 TPS art-pass demo | 保留 `demo_tps/` 玩法基线，迁移参考机器人模型、工业材质和氛围光照以便直接对比 |

其中 `godot-4.6.2-stable/`、`godot-docs-stable/`、`godot-demo-projects-4.2-31d1c0c/`、`awesome-godot-master/` 和 `reference/` 是需要纳入 Git 的本地参考资料。Godot macOS 编辑器二进制不是 LLM 参考资料；请在本机另行安装 Godot 4.6.2，或用系统 PATH 中的 `godot` 命令打开当前或后续 demo。

## 关键结论

1. 根目录没有 `project.godot`，因此根目录本身不是一个可直接导入 Godot 的工程。
2. 当前本地“运行环境”和“底层参考”以 `4.6.2 / 4.6` 为主。
3. 官方 demo 项目集是 `4.2` 系列，适合学习结构和写法，但不应无条件假定和 `4.6.2` 完全等价。
4. `godot-docs-stable/` 是文档源码仓库，不是离线 HTML 成品；适合全文搜索、读 `.rst` 源文件、查目录结构。
5. 这个仓库更像“Godot 本地知识底座 + 独立 demo 工作区”；新增 demo 应继续放在新的独立顶层目录中。
6. `reference/tps-demo/` 是 Godot `3.5.x` 参考项目，适合借鉴结构与资源组织，不应当作当前 `4.6.2` 环境下可直接运行的项目。

## 快速统计

- 官方 demo 数量：`108`
- demo 主要分类：
  - `2d`: `23`
  - `3d`: `24`
  - `gui`: `13`
  - `misc`: `9`
  - `audio`: `7`
  - `networking`: `7`
  - `loading`: `6`
  - `viewport`: `6`
  - `mono`: `5`
  - `mobile`: `4`
  - `xr`: `2`
  - `compute`: `1`
  - `plugins`: `1`
- demo 脚本统计：
  - `*.gd`: `327`
  - `*.cs`: `29`
- 文档源码量：
  - `*.rst`: `1568`

## 推荐使用方式

### 1. 查概念和 API

优先查看 `godot-docs-stable/`，尤其是这些目录：

- `godot-docs-stable/getting_started/`
- `godot-docs-stable/tutorials/`
- `godot-docs-stable/classes/`
- `godot-docs-stable/engine_details/`

对于“第一步怎么做”的内容，可先看：

- `godot-docs-stable/getting_started/first_2d_game/`
- `godot-docs-stable/getting_started/step_by_step/`

### 2. 查实际项目写法

优先从 `godot-demo-projects-4.2-31d1c0c/` 中找最接近需求的 demo，再看对应的场景、脚本和 README。常见入口如下：

- 2D 平台动作：`godot-demo-projects-4.2-31d1c0c/2d/platformer/`
- 2D 网格/RPG：`godot-demo-projects-4.2-31d1c0c/2d/role_playing_game/`
- TileMap / 六边形地图：`godot-demo-projects-4.2-31d1c0c/2d/hexagonal_map/`
- 2D 导航：`godot-demo-projects-4.2-31d1c0c/2d/navigation/`
- 2.5D：`godot-demo-projects-4.2-31d1c0c/misc/2.5d/`
- 3D 平台动作：`godot-demo-projects-4.2-31d1c0c/3d/platformer/`
- 联机：`godot-demo-projects-4.2-31d1c0c/networking/multiplayer_bomber/`

### 3. 查底层实现或版本差异

如果遇到下列问题，转去看 `godot-4.6.2-stable/`：

- 某个类在 `4.6` 到底怎么实现
- 文档描述不够精确
- demo 的 `4.2` 写法在 `4.6.2` 下是否有 API 或行为变化

建议重点搜索这些目录：

- `godot-4.6.2-stable/core/`
- `godot-4.6.2-stable/scene/`
- `godot-4.6.2-stable/servers/`
- `godot-4.6.2-stable/modules/`
- `godot-4.6.2-stable/editor/`

### 4. 查外部生态

如果本地官方资料里没有合适案例，再看 `awesome-godot-master/`，把它当作：

- 第三方项目发现入口
- 插件/模板检索入口
- 社区资源清单

不要把它当成 Godot API 或当前仓库结构的事实来源。

## 新增自定义 demo 的建议落点

当前根目录下的 Godot 参考资料目录更适合视为“上游镜像”或“参考资料”。如果要开始实现新的自定义 demo，建议：

1. 新建一个独立顶层目录，例如 `demo/`、`sandbox/`、`playground/`，或按具体主题命名。
2. 在该目录下单独维护自己的 `project.godot`、场景、脚本、资源和说明文档。
3. 默认以 `Godot 4.6.2` 为目标版本开发，参考 `4.2` demo 时明确记录迁移点。
4. 优先使用 GDScript，除非需求明确要求 C#、GDExtension 或引擎层改动。

## 当前可运行 demo

| 项目 | 入口 | 已实现玩法 | 说明 |
| --- | --- | --- | --- |
| `Signal Sweep` | `demo_2d/project.godot` | 俯视飞船移动、收集 8 个信标、躲避弹射巡逻无人机、3 点护盾、45 秒倒计时、胜负/重开 | 详见 `demo_2d/README.md`、`demo_2d/DESIGN.md`、`demo_2d/REFERENCES.md` |
| `Signal Sweep Art` | `demo_2d_art/project.godot` | 保留 2D 基线玩法，升级为霓虹雷达风训练场、扫描叠层、推进器/护盾/危险外环反馈 | 详见 `demo_2d_art/README.md`、`demo_2d_art/ART_DIRECTION.md`、`demo_2d_art/REFERENCES.md` |
| `Beacon Runner 3D` | `demo_3d/project.godot` | 3D 胶囊角色移动/跳跃、收集 5 个发光信标、躲避 2 个线段巡逻无人机、3 点护盾、60 秒倒计时、胜负/重开 | 详见 `demo_3d/README.md`、`demo_3d/DESIGN.md`、`demo_3d/REFERENCES.md` |
| `Beacon Runner 3D Art` | `demo_3d_art/project.godot` | 保留 3D 基线玩法，升级为带命名材质、雾、导视光边和控制台 HUD 的独立 art-pass 场景 | 详见 `demo_3d_art/README.md`、`demo_3d_art/ART_DIRECTION.md`、`demo_3d_art/REFERENCES.md` |
| `Tactical Proxy Strike` | `demo_tps/project.godot` | 第三人称肩后相机、瞄准态、玩家投射物、巡逻哨兵、敌方激光、90 秒清场目标 | 详见 `demo_tps/README.md`、`demo_tps/DESIGN.md`、`demo_tps/REFERENCES.md` |
| `Tactical Proxy Strike Art` | `demo_tps_art/project.godot` | 保留 TPS 基线玩法，升级为参考机器人模型、工业门体、PBR 面板材质和更强的 art-pass 氛围 | 详见 `demo_tps_art/README.md`、`demo_tps_art/DESIGN.md`、`demo_tps_art/REFERENCES.md` |

其中 `demo_2d/`、`demo_3d/`、`demo_2d_art/`、`demo_3d_art/` 和 `demo_tps/` 仍以 Godot 内置节点、primitive、材质、Label 或轻量 shader 为主；`demo_tps_art/` 额外选择性复制了 `reference/tps-demo/` 的模型、贴图、音乐和音效资源，并在项目内记录来源与授权。

## 常用命令

打开当前 2D demo：

```sh
godot --path demo_2d
```

提交前快速验证当前 2D demo：

```sh
godot --headless --path demo_2d --quit-after 1
godot --headless --editor --quit --path demo_2d
```

打开当前 3D demo：

```sh
godot --path demo_3d
```

提交前快速验证当前 3D demo：

```sh
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
```

打开当前 2D art demo：

```sh
godot --path demo_2d_art
```

提交前快速验证当前 2D art demo：

```sh
godot --headless --path demo_2d_art --quit-after 1
godot --headless --editor --quit --path demo_2d_art
```

打开当前 3D art demo：

```sh
godot --path demo_3d_art
```

提交前快速验证当前 3D art demo：

```sh
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
```

打开当前 TPS demo：

```sh
godot --path demo_tps
```

提交前快速验证当前 TPS demo：

```sh
godot --headless --path demo_tps --quit-after 1
godot --headless --editor --quit --path demo_tps
```

打开当前 TPS art demo：

```sh
godot --path demo_tps_art
```

提交前快速验证当前 TPS art demo：

```sh
godot --headless --path demo_tps_art --quit-after 1
godot --headless --editor --quit --path demo_tps_art
```

## 适合后续 LLM/代理的理解方式

- 把本仓库理解成“Godot 本地参考仓库”，不是单一应用项目。
- 把 `godot-docs-stable/` 视为概念和 API 参考。
- 把 `godot-demo-projects-4.2-31d1c0c/` 视为项目级实现样例。
- 把 `godot-4.6.2-stable/` 视为最终的底层事实来源。
- 把 `awesome-godot-master/` 视为外部资源导航，不直接决定代码实现。

更具体的 AI/LLM 协作规则见根目录的 `AGENTS.md`。

## GitHub 仓库协作文件

- `README.md`：仓库首页和本地参考资料导航。
- `AGENTS.md`：给 LLM/代理使用的项目理解规则。
- `docs/PLAN.md`：demo 路线图总入口。
- `docs/PLAN_2D.md`：实现 Godot 2D 游戏 demo 的详细阶段计划。
- `docs/PLAN_3D.md`：实现 Godot 3D 游戏 demo 的详细阶段计划。
- `docs/PLAN_2D_ART.md`：2D demo 的美术、VFX、UI 和渲染优化计划。
- `docs/PLAN_3D_ART.md`：3D demo 的模型、材质、灯光、相机、VFX 和渲染优化计划。
- `docs/PLAN_TPS.md`：TPS demo 的相机、敌人状态机、战斗节奏和后续迭代计划。
- `CONTRIBUTING.md`：人类和 AI 协作者的贡献流程。
- `SECURITY.md`：安全问题报告范围和方式。
- `SUPPORT.md`：求助入口和上游问题分流。
- `.github/ISSUE_TEMPLATE/`：bug / feature issue 模板。
- `.github/PULL_REQUEST_TEMPLATE.md`：PR 描述和验证清单。
- `.gitignore`：忽略 Godot 缓存、导出产物和本地编辑器二进制；显式允许提交 Godot 参考资料目录。
- `.gitattributes`：统一常见 Godot/Markdown/YAML 文本文件换行，并标记常见二进制资产。
- `.editorconfig`：统一基础文本格式、换行和缩进约定。

## 当前限制

- 根目录不是一个可直接运行的 Godot 工程。
- 当前 2D/3D 基线 demo 与 2D/3D art demo 都是首版垂直切片，暂未包含音频、主菜单、导出预设或完整关卡流程。
- 文档当前是源码形式，若需要浏览完整离线站点，还要额外构建或下载离线 HTML。
- 本地参考 demo 与当前编辑器版本存在 `4.2` 对 `4.6.2` 的版本差，需要在实现时留意兼容性。
- GitHub 普通 Git 不包含 macOS 编辑器 app；编辑器二进制对 LLM 参考价值低，而且超过 GitHub 普通单文件限制。
