# godot-in-action

这是一个为后续实现 Godot demo 准备的本地工作台仓库。当前仓库不是单一、可直接运行的 Godot 项目，而是把 Godot 引擎源码、官方文档源码、官方 demo 项目集，以及社区资源清单放在同一个目录中，方便离线检索、对照学习和快速取样。

## 仓库定位

- 目标：为后续自定义 Godot demo 的设计、实现、验证提供本地参考资料。
- 当前状态：仓库里还没有“我们自己的 Godot 项目”，现有内容以官方或社区上游镜像为主。
- 使用方式：把这里当作 Godot 本地知识库与样例库，而不是把根目录直接当成一个 Godot 工程打开。
- GitHub 提交范围：提交本仓库原创文档、配置、后续独立 demo 和本地 Godot 参考资料目录；本地 macOS Godot 编辑器 app 暂不进普通 Git。

## 当前内容总览

| 路径 | 内容 | 角色 | 备注 |
| --- | --- | --- | --- |
| `godot-4.6.2-stable/` | Godot 引擎源码 | 底层行为与 API 参考 | 含 `SConstruct`、`version.py` 等构建入口 |
| `godot-docs-stable/` | Godot 官方文档源码 | 概念与 API 文档参考 | `conf.py` 中版本为 `4.6`，当前是 reST 源码，不是已构建 HTML |
| `godot-demo-projects-4.2-31d1c0c/` | Godot 官方 demo 项目集 | 场景/脚本/玩法实现参考 | 共 `108` 个 demo，目录名表明是 `4.2` 分支快照 |
| `awesome-godot-master/` | Awesome Godot 资源清单 | 扩展资源发现 | 适合找第三方项目、插件、模板，不是 API 真正依据 |

其中 `godot-4.6.2-stable/`、`godot-docs-stable/`、`godot-demo-projects-4.2-31d1c0c/` 和 `awesome-godot-master/` 是需要纳入 Git 的本地参考资料。Godot macOS 编辑器二进制不是 LLM 参考资料；请在本机另行安装 Godot 4.6.2，或用系统 PATH 中的 `godot` 命令打开后续 demo。

## 关键结论

1. 根目录没有 `project.godot`，因此根目录本身不是一个可直接导入 Godot 的工程。
2. 当前本地“运行环境”和“底层参考”以 `4.6.2 / 4.6` 为主。
3. 官方 demo 项目集是 `4.2` 系列，适合学习结构和写法，但不应无条件假定和 `4.6.2` 完全等价。
4. `godot-docs-stable/` 是文档源码仓库，不是离线 HTML 成品；适合全文搜索、读 `.rst` 源文件、查目录结构。
5. 这个仓库更像“Godot 本地知识底座”，后续自己的 demo 建议放在新的独立目录中。

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

## 后续自定义 demo 的建议落点

当前根目录下的 5 个主目录都更适合视为“上游镜像”或“参考资料”。如果要开始实现我们自己的 demo，建议：

1. 新建一个独立顶层目录，例如 `demo/`、`sandbox/`、`playground/`，或按具体主题命名。
2. 在该目录下单独维护自己的 `project.godot`、场景、脚本、资源和说明文档。
3. 默认以 `Godot 4.6.2` 为目标版本开发，参考 `4.2` demo 时明确记录迁移点。
4. 优先使用 GDScript，除非需求明确要求 C#、GDExtension 或引擎层改动。

## 当前 demo

- `demo_2d/`：独立 Godot 2D demo，项目名 `Signal Sweep`。首版目标是收集信标、躲避巡逻无人机，并在一个固定竞技场中完成胜负闭环。
- `demo_2d/project.godot`：用 Godot `4.6.2` 或兼容的 4.x 编辑器打开。
- `demo_2d/README.md`：demo 自己的玩法、操作、结构和运行说明。
- `demo_2d/DESIGN.md`：首版玩法边界。
- `demo_2d/REFERENCES.md`：开发时参考过的本地 Godot docs / official demo。

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
- `PLAN.md`：实现 Godot 2D 游戏 demo 的阶段计划。
- `CONTRIBUTING.md`：人类和 AI 协作者的贡献流程。
- `SECURITY.md`：安全问题报告范围和方式。
- `SUPPORT.md`：求助入口和上游问题分流。
- `.github/ISSUE_TEMPLATE/`：bug / feature issue 模板。
- `.github/PULL_REQUEST_TEMPLATE.md`：PR 描述和验证清单。
- `.gitignore`：忽略 Godot 缓存、导出产物和本地编辑器二进制；显式允许提交 Godot 参考资料目录。
- `.gitattributes`：统一常见 Godot/Markdown/YAML 文本文件换行，并标记常见二进制资产。
- `.editorconfig`：统一基础文本格式、换行和缩进约定。

## 当前限制

- 还没有我们自己的业务代码或独立 demo。
- 根目录不是一个可直接运行的 Godot 工程。
- 文档当前是源码形式，若需要浏览完整离线站点，还要额外构建或下载离线 HTML。
- demo 与当前编辑器版本存在 `4.2` 对 `4.6.2` 的版本差，需要在实现时留意兼容性。
- GitHub 普通 Git 不包含 macOS 编辑器 app；编辑器二进制对 LLM 参考价值低，而且超过 GitHub 普通单文件限制。
