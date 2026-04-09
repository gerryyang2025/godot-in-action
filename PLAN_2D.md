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
