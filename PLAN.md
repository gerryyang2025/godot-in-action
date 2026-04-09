# Godot 2D 游戏 Demo 实现计划

本计划用于在当前 `godot-in-action` 工作台中启动一个独立的 Godot 2D 游戏 demo。当前根目录是 Godot 本地参考仓库，不是游戏项目；新 demo 应放在新的独立顶层目录中。

## 0. 默认约定

- 目标引擎：`Godot 4.6.2`
- 默认语言：`GDScript`
- 项目类型：独立 2D demo
- 建议项目目录：`demo_2d/`
- 本地编辑器：请安装 Godot `4.6.2`，并使用 Godot.app、系统 PATH 中的 `godot`，或你自己的绝对路径运行项目。
- 不直接修改的参考目录：
  - `godot-4.6.2-stable/`
  - `godot-docs-stable/`
  - `godot-demo-projects-4.2-31d1c0c/`
  - `awesome-godot-master/`

## 1. 目标

实现一个范围可控、可运行、可继续扩展的 Godot 2D 游戏 demo，先完成一个“可玩 1 分钟”的垂直切片，再逐步补素材、关卡、UI、音效和文档。

## 当前进度

- 已启动独立项目：`demo_2d/`
- 当前 demo 名称：`Signal Sweep`
- 当前核心循环：开始游戏、移动飞船、收集信标、躲避无人机、护盾扣减、倒计时、胜利/失败、按键重开。
- 已安装 CLI：`godot` 指向本机 Godot `4.6.2.stable.official.71f334935`。
- 已完成静态检查：`res://` 引用路径存在，`demo_2d/` 和根 `README.md` 没有 `git diff --check` 问题。
- 已完成 Godot 检查：`godot --headless --editor --quit --path demo_2d` 导入成功；`godot --headless --path demo_2d --quit-after 1` 主场景启动成功。

## 2. 阶段计划

### 阶段 A：确定 demo 方向

- [ ] 用 5 到 10 句话写清楚 demo 概念：玩家是谁、在哪里、做什么、为什么有趣。
- [ ] 选择一个核心动词，例如移动、躲避、跳跃、射击、采集、解谜、对话、回合战斗。
- [ ] 选择目标视角：俯视、横版、固定屏幕、网格移动、房间制。
- [ ] 写出最小胜利条件：例如存活 60 秒、收集 10 个物品、抵达出口、击败 3 个敌人。
- [ ] 写出最小失败条件：例如生命归零、时间耗尽、掉落深渊、被敌人碰到。
- [ ] 划定首版范围：最多 1 名玩家角色、1 个主场景、1 个关卡、1 到 2 种障碍/敌人、1 个 UI 面板。

产出物：

- [ ] `demo_2d/DESIGN.md`，记录首版玩法边界。

### 阶段 B：选择本地参考样例

先在 `godot-demo-projects-4.2-31d1c0c/` 中选择 1 到 2 个最接近的官方 demo。注意这些 demo 是 `4.2.x` 参考，目标实现仍默认按 `4.6.2` 验证。

可选参考：

- [ ] 横版动作：`godot-demo-projects-4.2-31d1c0c/2d/platformer/`
- [ ] 躲避/刷怪/计分：`godot-demo-projects-4.2-31d1c0c/2d/dodge_the_creeps/`
- [ ] 网格 RPG/对话/战斗：`godot-demo-projects-4.2-31d1c0c/2d/role_playing_game/`
- [ ] TileMap/地图：`godot-demo-projects-4.2-31d1c0c/2d/hexagonal_map/`
- [ ] 2D 导航：`godot-demo-projects-4.2-31d1c0c/2d/navigation/`
- [ ] 状态机：`godot-demo-projects-4.2-31d1c0c/2d/finite_state_machine/`
- [ ] 2D 灯光/阴影：`godot-demo-projects-4.2-31d1c0c/2d/lights_and_shadows/`

文档核对入口：

- [ ] `godot-docs-stable/getting_started/first_2d_game/`
- [ ] `godot-docs-stable/getting_started/step_by_step/`
- [ ] `godot-docs-stable/tutorials/2d/`
- [ ] `godot-docs-stable/classes/`

产出物：

- [ ] `demo_2d/REFERENCES.md`，记录参考了哪些本地 demo、文档和关键结论。

### 阶段 C：创建独立 Godot 项目骨架

- [ ] 新建 `demo_2d/`，不要在根目录直接放 `project.godot`。
- [ ] 创建 `demo_2d/project.godot`。
- [ ] 创建主场景 `demo_2d/scenes/main.tscn`。
- [ ] 创建玩家场景 `demo_2d/scenes/player.tscn`。
- [ ] 创建玩家脚本 `demo_2d/scripts/player.gd`。
- [ ] 创建基础目录：`assets/`、`audio/`、`scenes/`、`scripts/`、`ui/`。
- [ ] 设置 main scene 指向 `res://scenes/main.tscn`。
- [ ] 设定窗口大小、拉伸策略、渲染方法和输入映射。

建议目录：

```text
demo_2d/
  project.godot
  DESIGN.md
  REFERENCES.md
  README.md
  assets/
  audio/
  scenes/
    main.tscn
    player.tscn
  scripts/
    player.gd
  ui/
```

产出物：

- [ ] 一个能被 Godot 4.6.2 打开的空项目。
- [ ] 一个能运行但还不一定有玩法的主场景。

### 阶段 D：实现第一条可玩闭环

- [ ] 玩家角色能出现在主场景中。
- [ ] 玩家能通过键盘输入移动。
- [ ] 摄像机/视口能稳定展示玩家与游戏区域。
- [ ] 场景中有一个目标、出口、收集物、敌人或危险区域。
- [ ] 玩家行为能改变游戏状态，例如分数、生命、计时器、位置、关卡进度。
- [ ] 有胜利/失败判定，并且可以重新开始。
- [ ] 增加最小 UI：分数/生命/时间/提示文本。

产出物：

- [ ] 一个从启动到结束可完整游玩的 30 到 60 秒垂直切片。

### 阶段 E：补关卡、反馈和内容

- [ ] 用 placeholder 资产先完成关卡，不等最终美术。
- [ ] 补充 1 个完整测试关卡或固定游玩场地。
- [ ] 增加碰撞、触发区、边界和死亡/重生点。
- [ ] 增加基础动画：待机、移动、受击、拾取、死亡，按实际玩法裁剪。
- [ ] 增加基础音效：操作反馈、收集、受击、胜利、失败。
- [ ] 增加暂停/继续/重新开始入口。
- [ ] 调整手感：移动速度、加速度、跳跃、碰撞尺寸、敌人频率、难度曲线。

产出物：

- [ ] 一个有基本表现力的单关卡 2D demo。

### 阶段 F：兼容性和质量检查

- [ ] 用 Godot 4.6.2 打开 `demo_2d/`，确认没有导入错误。
- [ ] 运行主场景，确认主流程可以开始、游玩、结束、重开。
- [ ] 检查 Debugger 输出，没有脚本错误、缺失资源、循环报错。
- [ ] 如果引用 `4.2` demo 写法，核对 `4.6` 文档或 `4.6.2` 源码。
- [ ] 确认 `.import/`、导入产物、临时缓存是否需要忽略或保留。
- [ ] 确认复制来的第三方/官方资产有许可证记录和 attribution。

可选命令参考：

```sh
godot --path demo_2d
godot --headless --editor --quit --path demo_2d
```

产出物：

- [ ] 一份当前已验证内容的记录，写到 `demo_2d/README.md`。

### 阶段 G：demo 自身文档

- [ ] 编写 `demo_2d/README.md`。
- [ ] 说明项目使用 Godot 版本、玩法、操作、主场景、核心脚本、参考来源。
- [ ] 记录已知问题、待办事项和下一步扩展计划。
- [ ] 如果使用了外部资产，在 README 或单独 LICENSE/ATTRIBUTION 文件中记录来源。

产出物：

- [ ] 后续人或 LLM 能在 3 分钟内理解、打开、运行、继续改这个 demo。

## 3. 推荐执行顺序

1. 先完成 `DESIGN.md`，把首版玩法压到很小。
2. 选择最多 2 个官方 demo 参考，写到 `REFERENCES.md`。
3. 创建 `demo_2d/` 和最小 Godot 项目骨架。
4. 只用简单形状或 placeholder 图形完成玩家移动。
5. 添加目标、危险、分数/生命、胜负条件。
6. 在 Godot 4.6.2 里运行并修复错误。
7. 再加入关卡、动画、音效、菜单和更好的素材。
8. 最后整理 demo 自己的 README。

## 4. 首版完成标准

首版 demo 可以算完成，当且仅当：

- [ ] `demo_2d/project.godot` 存在，并能被本地 Godot 4.6.2 打开。
- [ ] 项目有明确 main scene。
- [ ] 玩家可以控制一个 2D 角色或实体。
- [ ] demo 有明确的目标、障碍、反馈和结束条件。
- [ ] 从启动到一次胜利/失败不需要手工切换场景。
- [ ] README 说明了玩法、操作、运行方式和本地参考来源。

## 5. 决策点

开始写代码前，优先确定这 3 件事：

- [ ] demo 名称和目录名是否使用默认 `demo_2d/`
- [ ] demo 玩法是横版、俯视、固定屏幕，还是网格/TileMap
- [ ] 首个参考 demo 选哪个：`2d/platformer`、`2d/dodge_the_creeps`、`2d/role_playing_game`、`2d/hexagonal_map`，或其他本地官方 demo

---

# Godot 3D 游戏 Demo 实现计划

本计划参考 `demo_2d/` 的做法：先做独立目录、设计文档、参考记录和最小 Godot 项目，再实现一个可运行的 3D 垂直切片。不要把新 demo 代码混入 Godot 源码、文档或官方 demo 参考目录。

## 6. 3D demo 默认约定

- 目标引擎：`Godot 4.6.2`
- 默认语言：`GDScript`
- 项目类型：独立 3D demo
- 建议项目目录：`demo_3d/`
- 运行命令：`godot --path demo_3d`
- 主场景验证：`godot --headless --path demo_3d --quit-after 1`
- 编辑器导入验证：`godot --headless --editor --quit --path demo_3d`
- 实现原则：优先使用 Godot 内置 3D primitive / placeholder 材质，不依赖外部模型、贴图或音频。

## 7. 3D demo 建议方向

首版推荐做一个范围小、和 2D demo 一样容易验证的 3D demo：

`Beacon Runner 3D`：玩家控制一个简单胶囊/机器人，在小型 3D 训练场中移动、跳跃、拾取发光信标，并避开巡逻 drone。收集指定数量信标后获胜，掉出平台或生命归零失败。

首版核心：

- 视角：第三人称固定跟随相机，或略高的斜俯视相机。
- 玩家：`CharacterBody3D`，支持移动、转向、可选跳跃。
- 世界：1 个简单地面、若干墙/柱/坡道。
- 目标：若干可收集 beacon，或一次出现一个 beacon。
- 危险：1 到 2 个巡逻 drone / hazard volume。
- UI：信标数、生命/护盾、倒计时、状态提示。

## 8. 3D 阶段计划

### 阶段 3A：确定 3D demo 方向

- [ ] 在 `demo_3d/DESIGN.md` 中写清楚玩家是谁、目标是什么、为什么需要 3D 空间。
- [ ] 选择移动模型：第三人称自由移动、坦克式移动、固定轨道、第一人称，或点击寻路。
- [ ] 选择相机模型：固定斜视、跟随、自由鼠标视角、房间切换视角。
- [ ] 写出首版胜利条件，例如收集 `5` 个 3D 信标、抵达出口、完成 1 圈路线。
- [ ] 写出首版失败条件，例如生命归零、计时结束、掉出平台。
- [ ] 划定首版范围：1 个 main scene、1 个 player scene、1 个 arena、最多 2 类互动对象。

产出物：

- [ ] `demo_3d/DESIGN.md`

### 阶段 3B：选择本地 3D 参考

先从这些本地官方 demo 中选择 1 到 2 个主参考：

- [ ] 第三人称/平台移动：`godot-demo-projects-4.2-31d1c0c/3d/platformer/`
- [ ] 3D CharacterBody：`godot-demo-projects-4.2-31d1c0c/3d/kinematic_character/`
- [ ] 3D 物理/碰撞：`godot-demo-projects-4.2-31d1c0c/3d/physics_tests/`
- [ ] 3D 导航：`godot-demo-projects-4.2-31d1c0c/3d/navigation/`
- [ ] 3D 光照/阴影：`godot-demo-projects-4.2-31d1c0c/3d/lights_and_shadows/`
- [ ] 官方 3D 小游戏结构：`godot-demo-projects-4.2-31d1c0c/3d/squash_the_creeps/`
- [ ] 基础关卡/材质实验：`godot-demo-projects-4.2-31d1c0c/3d/csg/`

文档核对入口：

- [ ] `godot-docs-stable/classes/class_characterbody3d.rst`
- [ ] `godot-docs-stable/classes/class_area3d.rst`
- [ ] `godot-docs-stable/classes/class_camera3d.rst`
- [ ] `godot-docs-stable/classes/class_navigationagent3d.rst`
- [ ] `godot-docs-stable/tutorials/3d/`
- [ ] `godot-docs-stable/tutorials/physics/`

产出物：

- [ ] `demo_3d/REFERENCES.md`

### 阶段 3C：创建独立 3D 项目骨架

- [ ] 新建 `demo_3d/`，不要在根目录放 `project.godot`。
- [ ] 创建 `demo_3d/project.godot`，main scene 指向 `res://scenes/main.tscn`。
- [ ] 创建 `demo_3d/scenes/main.tscn`。
- [ ] 创建 `demo_3d/scenes/player.tscn`。
- [ ] 创建 `demo_3d/scenes/beacon.tscn`。
- [ ] 创建 `demo_3d/scenes/hazard.tscn` 或 `demo_3d/scenes/drone.tscn`。
- [ ] 创建 `demo_3d/scripts/main.gd`、`player.gd`、`beacon.gd`、`hazard.gd`。
- [ ] 创建基础目录：`assets/`、`audio/`、`materials/`、`scenes/`、`scripts/`、`ui/`。
- [ ] 设置输入映射：移动、跳跃、开始/重开、可选视角旋转。

建议目录：

```text
demo_3d/
  project.godot
  DESIGN.md
  REFERENCES.md
  README.md
  assets/
  audio/
  materials/
  scenes/
    main.tscn
    player.tscn
    beacon.tscn
  scripts/
    main.gd
    player.gd
    beacon.gd
  ui/
```

产出物：

- [ ] 一个能被 Godot 4.6.2 打开、导入、headless 启动的 3D 项目。

### 阶段 3D：实现 3D 可玩闭环

- [ ] 玩家能出现在 3D 训练场中。
- [ ] 玩家能移动；如果选择跳跃，则要有地面检测、重力和落地。
- [ ] 相机稳定显示玩家、目标和关键空间。
- [ ] 场景里至少有 1 个可收集目标。
- [ ] 至少有 1 种危险或压力来源：巡逻敌人、移动障碍、坠落、倒计时。
- [ ] 玩家行为能改变 UI 或游戏状态。
- [ ] 有胜利/失败判定，并支持按键重开。

产出物：

- [ ] 一个 30 到 60 秒可完成的 3D 垂直切片。

### 阶段 3E：3D 质量和体验

- [ ] 用 primitive / CSG / MeshInstance3D 搭出清晰读图的单关卡。
- [ ] 增加基础灯光：`DirectionalLight3D`、必要时增加局部灯。
- [ ] 增加相机遮挡/高度/距离调试，避免玩家跑出视野。
- [ ] 增加材质颜色区分：玩家、目标、危险、地面、边界。
- [ ] 增加交互反馈：收集闪烁、受击闪烁、结束提示。
- [ ] 如果引入外部 3D 资产，在 README 或 attribution 文件中记录来源和许可证。

产出物：

- [ ] 一个不依赖编辑器手工切场景即可启动的 3D demo。

### 阶段 3F：3D 验证命令

常规运行：

```sh
godot --path demo_3d
```

提交前最少执行：

```sh
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
git status --short
git diff --check -- demo_3d README.md PLAN.md
```

产出物：

- [ ] 在 `demo_3d/README.md` 记录已验证的 Godot 版本、运行命令、测试命令和已知问题。

## 9. 3D 首版完成标准

- [ ] `demo_3d/project.godot` 存在，并能被 Godot 4.6.2 导入。
- [ ] `demo_3d/scenes/main.tscn` 是 main scene。
- [ ] 玩家能控制一个 3D 角色或载具。
- [ ] demo 有明确目标、危险、UI 反馈、胜负条件、重开流程。
- [ ] `godot --headless --path demo_3d --quit-after 1` 通过。
- [ ] `demo_3d/README.md` 说明玩法、操作、运行方式、测试方式和本地参考来源。

## 10. 3D 开始前决策点

- [ ] 目录名是否使用默认 `demo_3d/`
- [ ] 首版是第三人称平台/收集，还是第一人称/俯视/轨道移动
- [ ] 是否沿用 2D demo 的“收集信标 + 躲避巡逻者”主题
- [ ] 首个 3D 参考 demo 选哪个：`3d/platformer`、`3d/kinematic_character`、`3d/squash_the_creeps`、`3d/navigation`，或其他本地官方 demo
