# AGENTS.md

本文件用于帮助后续 LLM/代理正确理解当前仓库，减少把“参考资料目录”误判成“我们的业务项目”的风险。

## 1. 仓库身份

- 这是一个 Godot 本地工作台/参考仓库，不是单一可运行应用。
- 根目录没有 `project.godot`，因此根目录本身不是 Godot 项目。
- 当前仓库的主体内容是上游镜像、本地参考资料和独立 demo。
- 在 GitHub 维度，根仓库跟踪原创文档、配置、GitHub 元数据、独立 demo，以及选定的 Godot 参考资料目录。

## 2. 顶层目录语义

- `godot-4.6.2-stable/`
  - Godot 4.6.2 引擎源码。
  - 用于确认底层实现、类行为、引擎约束、平台差异。
  - 应纳入根仓库 Git 版本控制。
- `godot-docs-stable/`
  - Godot 4.6 stable 文档源码仓库。
  - 主要是 `.rst` 源文件，适合检索和阅读，不等于构建完成的文档站。
  - 应纳入根仓库 Git 版本控制。
- `godot-demo-projects-4.2-31d1c0c/`
  - 官方 demo 项目快照，面向 Godot 4.2.x。
  - 其中每个包含 `project.godot` 的目录，都是一个独立 demo。
  - 应纳入根仓库 Git 版本控制。
- `awesome-godot-master/`
  - 社区资源导航清单。
  - 只用于发现资源，不作为 API 或仓库结构的事实依据。
  - 应纳入根仓库 Git 版本控制。
- `reference/`
  - 本地参考项目集合目录。
  - 当前包含 `reference/tps-demo/`，用于参考第三人称射击 demo 的关卡组织、音频反馈、美术渲染和交互节奏。
  - `reference/tps-demo/` 是 Godot `3.5.x` 参考项目，不能直接在当前 `4.6.2` 环境下运行。
  - 默认视为只读参考，不作为 `demo_tps/` 的运行时资源根目录。
- `demo_2d/`
  - 当前独立 2D demo：Signal Sweep。
  - 是我们自己的 Godot 项目，可以按用户需求修改。
- `demo_3d/`
  - 当前独立 3D demo：Beacon Runner 3D。
  - 是我们自己的 Godot 项目，可以按用户需求修改。
- `demo_tps/`
  - 当前独立 TPS demo：Tactical Proxy Strike。
  - 是我们自己的 Godot 项目，可以按用户需求修改。
- `demo_2d_art/`
  - 当前独立 2D art-pass demo：Signal Sweep Art。
  - 保留 `demo_2d/` 玩法基线，在独立目录中验证美术、HUD、shader 和反馈升级。
- `demo_3d_art/`
  - 当前独立 3D art-pass demo：Beacon Runner 3D Art。
  - 保留 `demo_3d/` 玩法基线，在独立目录中验证材质、环境、轮廓和 HUD 升级。

## 3. 默认编辑边界

除非用户明确要求，否则以下目录默认视为只读参考，不应直接改动：

- `godot-4.6.2-stable/`
- `godot-docs-stable/`
- `godot-demo-projects-4.2-31d1c0c/`
- `awesome-godot-master/`
- `reference/`

如果用户要求“开始做自己的 demo”，优先新建独立顶层目录承载新项目，而不是把代码混进这些上游目录中。

提交前应运行或等效检查 `git status --short`。若看到 `.godot/`、`.DS_Store`、导出包、编辑器 app 出现在待提交列表里，先停下来检查忽略规则和提交范围。Godot 参考资料目录出现在待提交列表中是允许的。

本机 Godot 编辑器 app 不需要出现在仓库中；用已安装的 Godot 4.6.2 打开 demo。

## 4. 版本判断规则

- 编辑器版本：`4.6.2`
- 引擎源码版本：`4.6.2`
- 文档版本：`4.6 stable`
- 官方 demo 版本：`4.2.x`

因此在分析、实现、回答问题时必须区分：

- “这是 `4.2` demo 的写法”
- “这是 `4.6` 文档的描述”
- “这是 `4.6.2` 引擎源码的实际行为”

不要默认认为 `4.2` demo 可以无修改等价运行在 `4.6.2` 上。需要迁移或验证时，应明确说明这一点。

## 5. 事实来源优先级

当多个来源不一致时，按以下优先级判断：

1. 用户当前指定要改动或分析的目标项目文件
2. 该项目自己的 `project.godot`、`.tscn`、`.gd`、`.cs`
3. `godot-4.6.2-stable/` 中对应类或模块的源码
4. `godot-docs-stable/` 中对应的官方文档
5. `godot-demo-projects-4.2-31d1c0c/` 中相近 demo 的实现模式
6. `awesome-godot-master/` 中的外部资源清单

解释：

- 如果问题是“这个类在 4.6.2 到底怎么工作”，优先看引擎源码。
- 如果问题是“官方推荐如何使用”，优先看文档。
- 如果问题是“一个可运行 demo 应该怎么组织场景和脚本”，优先看官方 demo。

## 6. 新 demo 的默认实现策略

如果用户没有指定其他版本或技术栈，默认采用以下假设：

- 目标引擎版本：`Godot 4.6.2`
- 脚本语言：`GDScript`
- 项目位置：新建独立顶层目录
- 参考顺序：先找官方 demo，再核对官方文档，必要时查引擎源码

只有在以下情况下再偏离默认：

- 用户明确要求兼容 `4.2`
- 用户明确要求 C#
- 用户明确要求修改引擎源码、插件或上游 demo

## 7. 调研与实现前检查清单

开始工作前，先确认以下几点：

1. 当前要处理的是哪个具体目录，是否存在 `project.godot`
2. 目标版本是 `4.2` 兼容，还是 `4.6.2` 新实现
3. 是否已有最接近的本地官方 demo 可复用
4. 是否已有对应的官方文档页面可核对
5. 本次任务是在“新建我们自己的项目”，还是“分析上游参考资料”

如果用户说“分析当前工程”，默认解释为分析整个根仓库及其顶层资料结构，而不是分析某一个具体 demo。

## 7.1. 当前 demo 常用命令

运行当前 2D demo：

```sh
godot --path demo_2d
```

快速验证当前 2D demo：

```sh
godot --headless --path demo_2d --quit-after 1
godot --headless --editor --quit --path demo_2d
```

运行当前 3D demo：

```sh
godot --path demo_3d
```

快速验证当前 3D demo：

```sh
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
```

运行当前 TPS demo：

```sh
godot --path demo_tps
```

快速验证当前 TPS demo：

```sh
godot --headless --path demo_tps --quit-after 1
godot --headless --editor --quit --path demo_tps
```

运行当前 2D art demo：

```sh
godot --path demo_2d_art
```

快速验证当前 2D art demo：

```sh
godot --headless --path demo_2d_art --quit-after 1
godot --headless --editor --quit --path demo_2d_art
```

运行当前 3D art demo：

```sh
godot --path demo_3d_art
```

快速验证当前 3D art demo：

```sh
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
```

如果 Godot 因沙箱无法写用户级日志/设置而失败，改在非沙箱环境运行同一条命令；不要因此把 `.godot/`、`export_presets.cfg` 或用户级 editor settings 提交进仓库。

## 8. 推荐参考入口

遇到这些任务时，优先查看这些目录：

- 新手上手/流程：
  - `godot-docs-stable/getting_started/`
- 2D 入门：
  - `godot-demo-projects-4.2-31d1c0c/2d/`
- 3D 入门：
  - `godot-demo-projects-4.2-31d1c0c/3d/`
- 2.5D、实验特性、特殊玩法：
  - `godot-demo-projects-4.2-31d1c0c/misc/`
- 联机：
  - `godot-demo-projects-4.2-31d1c0c/networking/`
- GUI：
  - `godot-demo-projects-4.2-31d1c0c/gui/`
- API / 底层行为：
  - `godot-docs-stable/classes/`
  - `godot-4.6.2-stable/scene/`
  - `godot-4.6.2-stable/core/`

## 9. 输出时应避免的误判

- 不要把根目录说成“当前游戏项目”。
- 不要把 `awesome-godot-master/` 当成代码实现来源。
- 不要把 `godot-docs-stable/` 说成“已经构建好的离线文档站”。
- 不要把 `godot-demo-projects-4.2-31d1c0c/` 说成“我们的业务代码”。
- 不要忽略 `4.2` demo 与 `4.6.2` 环境之间的版本差。

## 10. 对后续协作最有帮助的一句话

如果需要用一句话描述这个仓库，应表述为：

“这是一个围绕 Godot 4.6.2 源码、4.6 文档和 4.2 官方 demo 组织的本地参考工作台，用于为后续独立 demo 开发提供资料基础。”

## 11. GitHub 协作约定

- 仓库首页信息维护在 `README.md`。
- demo 路线图总入口维护在 `docs/PLAN.md`。
- 2D demo 详细计划维护在 `docs/PLAN_2D.md`。
- 3D demo 详细计划维护在 `docs/PLAN_3D.md`。
- TPS demo 详细计划维护在 `docs/PLAN_TPS.md`。
- 2D art-pass demo 详细计划维护在 `docs/PLAN_2D_ART.md`。
- 3D art-pass demo 详细计划维护在 `docs/PLAN_3D_ART.md`。
- 贡献流程维护在 `CONTRIBUTING.md`。
- 安全报告范围维护在 `SECURITY.md`。
- 求助入口维护在 `SUPPORT.md`。
- Issue 和 PR 模板位于 `.github/`。
- 不要为了“完善 GitHub 社区资料”而给上游参考资料目录补根仓库许可证声明；上游内容应保留自己的许可证和来源。
- 不要把 Godot 编辑器二进制加入普通 Git；它对 LLM 参考价值低，且 macOS universal 可执行文件超过 GitHub 普通单文件限制。
