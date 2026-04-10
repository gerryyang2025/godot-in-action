# Godot 3D 游戏 Demo 实现计划

本计划参考 `demo_2d/` 的做法：先做独立目录、设计文档、参考记录和最小 Godot 项目，再实现一个可运行的 3D 垂直切片。不要把新 demo 代码混入 Godot 源码、文档或官方 demo 参考目录。

## 0. 3D demo 默认约定

- 目标引擎：`Godot 4.6.2`
- 默认语言：`GDScript`
- 项目类型：独立 3D demo
- 建议项目目录：`demo_3d/`
- 运行命令：`godot --path demo_3d`
- 主场景验证：`godot --headless --path demo_3d --quit-after 1`
- 编辑器导入验证：`godot --headless --editor --quit --path demo_3d`
- 实现原则：优先使用 Godot 内置 3D primitive / placeholder 材质，不依赖外部模型、贴图或音频。

## 当前进度

- 已启动独立项目：`demo_3d/`
- 当前 demo 名称：`Beacon Runner 3D`
- 当前核心循环：开始游戏、控制 3D 胶囊角色、跳跃、收集 5 个绿色信标、躲避 2 个红色巡逻无人机、护盾扣减、倒计时、胜利/失败、按键重开。
- 已完成主场景验证：`godot --headless --path demo_3d --quit-after 1`
- 已完成编辑器导入验证：`godot --headless --editor --quit --path demo_3d`

## 1. 3D demo 建议方向

首版推荐做一个范围小、和 2D demo 一样容易验证的 3D demo：

`Beacon Runner 3D`：玩家控制一个简单胶囊/机器人，在小型 3D 训练场中移动、跳跃、拾取发光信标，并避开巡逻 drone。收集指定数量信标后获胜，掉出平台或生命归零失败。

首版核心：

- 视角：第三人称固定跟随相机，或略高的斜俯视相机。
- 玩家：`CharacterBody3D`，支持移动、转向、可选跳跃。
- 世界：1 个简单地面、若干墙/柱/坡道。
- 目标：若干可收集 beacon，或一次出现一个 beacon。
- 危险：1 到 2 个巡逻 drone / hazard volume。
- UI：信标数、生命/护盾、倒计时、状态提示。

## 2. 3D 阶段计划

### 阶段 A：确定 3D demo 方向

- [ ] 在 `demo_3d/DESIGN.md` 中写清楚玩家是谁、目标是什么、为什么需要 3D 空间。
- [ ] 选择移动模型：第三人称自由移动、坦克式移动、固定轨道、第一人称，或点击寻路。
- [ ] 选择相机模型：固定斜视、跟随、自由鼠标视角、房间切换视角。
- [ ] 写出首版胜利条件，例如收集 `5` 个 3D 信标、抵达出口、完成 1 圈路线。
- [ ] 写出首版失败条件，例如生命归零、计时结束、掉出平台。
- [ ] 划定首版范围：1 个 main scene、1 个 player scene、1 个 arena、最多 2 类互动对象。

产出物：

- [ ] `demo_3d/DESIGN.md`

### 阶段 B：选择本地 3D 参考

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

### 阶段 C：创建独立 3D 项目骨架

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

### 阶段 D：实现 3D 可玩闭环

- [ ] 玩家能出现在 3D 训练场中。
- [ ] 玩家能移动；如果选择跳跃，则要有地面检测、重力和落地。
- [ ] 相机稳定显示玩家、目标和关键空间。
- [ ] 场景里至少有 1 个可收集目标。
- [ ] 至少有 1 种危险或压力来源：巡逻敌人、移动障碍、坠落、倒计时。
- [ ] 玩家行为能改变 UI 或游戏状态。
- [ ] 有胜利/失败判定，并支持按键重开。

产出物：

- [ ] 一个 30 到 60 秒可完成的 3D 垂直切片。

### 阶段 E：3D 质量和体验

- [ ] 用 primitive / CSG / MeshInstance3D 搭出清晰读图的单关卡。
- [ ] 增加基础灯光：`DirectionalLight3D`、必要时增加局部灯。
- [ ] 增加相机遮挡/高度/距离调试，避免玩家跑出视野。
- [ ] 增加材质颜色区分：玩家、目标、危险、地面、边界。
- [ ] 增加交互反馈：收集闪烁、受击闪烁、结束提示。
- [ ] 如果引入外部 3D 资产，在 README 或 attribution 文件中记录来源和许可证。

产出物：

- [ ] 一个不依赖编辑器手工切场景即可启动的 3D demo。

### 阶段 F：3D 验证命令

常规运行：

```sh
godot --path demo_3d
```

提交前最少执行：

```sh
godot --headless --path demo_3d --quit-after 1
godot --headless --editor --quit --path demo_3d
git status --short
git diff --check -- demo_3d README.md docs/PLAN_3D.md
```

产出物：

- [ ] 在 `demo_3d/README.md` 记录已验证的 Godot 版本、运行命令、测试命令和已知问题。

## 3. 3D 首版完成标准

- [x] `demo_3d/project.godot` 存在，并能被 Godot 4.6.2 导入。
- [x] `demo_3d/scenes/main.tscn` 是 main scene。
- [x] 玩家能控制一个 3D 角色或载具。
- [x] demo 有明确目标、危险、UI 反馈、胜负条件、重开流程。
- [x] `godot --headless --path demo_3d --quit-after 1` 通过。
- [x] `demo_3d/README.md` 说明玩法、操作、运行方式、测试方式和本地参考来源。

## 4. 3D 开始前决策点

- [ ] 目录名是否使用默认 `demo_3d/`
- [ ] 首版是第三人称平台/收集，还是第一人称/俯视/轨道移动
- [ ] 是否沿用 2D demo 的“收集信标 + 躲避巡逻者”主题
- [ ] 首个 3D 参考 demo 选哪个：`3d/platformer`、`3d/kinematic_character`、`3d/squash_the_creeps`、`3d/navigation`，或其他本地官方 demo
