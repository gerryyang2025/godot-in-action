# Signal Sweep 2D 美术与渲染优化计划

本计划用于基于现有 `demo_2d/` 创建一个独立的 2D 美术优化示例，而不是直接修改原始 `Signal Sweep` 基线。建议新建 `demo_2d_art/`，把美术、材质、VFX、UI 和相机反馈实验都放在这个独立目录中；不要把美术实验混入 Godot 上游参考目录，也不要覆盖原来的 `demo_2d/`。

当前仓库状态：`demo_2d_art/` 的首轮独立实现已经存在；本文件按“已完成 / 待补强 / 待验证”回填当前进度，避免计划和实际实现脱节。

## 0. 默认方向

- 基线参考项目：`demo_2d/`
- 目标美术示例项目：`demo_2d_art/`
- 基线 demo：`Signal Sweep`
- 目标引擎：`Godot 4.6.2`
- 默认视觉关键词：深空训练场、霓虹信号、雷达扫描、清晰危险航线、干净战术 HUD。
- 首版仍优先：读图清楚、玩法反馈强、运行稳定、资产来源明确。
- 原则：保留 `demo_2d/` 作为当前玩法基线；所有美术优化默认在 `demo_2d_art/` 中实现。

## 0.1 当前收敛原则

- 后续迭代默认做减法，不再为了“科技感”继续叠加常驻背景线、刻度、警戒纹理或噪点。
- 每一层视觉元素都必须回答“它是否直接帮助玩家看懂目标、危险、边界或状态”；如果不能，就不保留。
- 优先投入状态反馈、对象识别和 HUD 结构，不优先投入无语义装饰。
- 静帧第一眼应该先看到玩家、信标和无人机，而不是场地装饰或后期效果。

## 0.2 当前进度快照

- 已完成：独立项目目录、视觉方向文档、对象 art-pass、训练场背景层、状态卡片 HUD、边界脉冲、收集爆发、低资源预警、headless 启动验证、集中 VFX 参数入口。
- 待补强：如后续继续迭代，可把更多对象级参数继续收敛到统一调优入口，但当前主场景后期与事件反馈已经可统一控制，状态卡片布局也已进一步压缩到顶部信息带内。
- 人工验证：已确认完整试玩、缩放窗口检查、关闭扫描叠层后的可读性检查均无明显问题。

## 1. 当前视觉现状

- 玩家：已拆成推进尾焰、护盾环、受击高亮、核心和轮廓，移动与受击反馈都更明确。
- 信标：已具备外圈扫描环、核心脉冲和收集存在感，能在静帧中快速识别。
- 无人机：已具备危险外环、前向扫描线、短拖尾和撞边反馈，危险感更清楚。
- 场地：已形成远景星点、训练场面板、低对比导视层和边界脉冲的四层结构，并删除了大部分无语义常驻线条。
- UI：已具备标题、任务进度、护盾、倒计时、状态卡片和底部播报，低护盾与低时间也有预警。
- 音频：暂未实现。本计划重点是美术/渲染，音频只作为反馈联动点记录。
- 后续背景迭代要避免“层次提升 = 线条增加”的误区，默认只保留能提升读图效率的少量常驻元素。

## 2. 本地参考入口

优先核对这些本地参考；官方 demo 是 `4.2` 快照，最终以 `4.6.2` 本地验证为准。

- `godot-docs-stable/tutorials/2d/2d_sprite_animation.rst`
- `godot-docs-stable/tutorials/2d/2d_lights_and_shadows.rst`
- `godot-docs-stable/tutorials/2d/particle_systems_2d.rst`
- `godot-docs-stable/tutorials/2d/particle_process_material_2d.rst`
- `godot-docs-stable/tutorials/2d/2d_antialiasing.rst`
- `godot-docs-stable/tutorials/shaders/`
- `godot-docs-stable/tutorials/assets_pipeline/importing_images.rst`
- `godot-docs-stable/classes/class_canvasmodulate.rst`
- `godot-docs-stable/classes/class_pointlight2d.rst`
- `godot-docs-stable/classes/class_gpuparticles2d.rst`
- `godot-demo-projects-4.2-31d1c0c/2d/lights_and_shadows/`
- `godot-demo-projects-4.2-31d1c0c/2d/light2d_as_mask/`
- `godot-demo-projects-4.2-31d1c0c/2d/particles/`
- `godot-demo-projects-4.2-31d1c0c/2d/sprite_shaders/`
- `godot-demo-projects-4.2-31d1c0c/2d/screen_space_shaders/`
- `godot-demo-projects-4.2-31d1c0c/2d/dodge_the_creeps/`

## 3. 目录与资产约定

建议先复制或重建一个独立项目目录，再逐步迁移玩法脚本和场景：

```text
demo_2d_art/
  project.godot
  README.md
  DESIGN.md
  REFERENCES.md
  ART_DIRECTION.md
  assets/
    sprites/
    textures/
    palettes/
  materials/
  shaders/
  vfx/
  ui/
    fonts/
    themes/
```

实施边界：

- 不要直接在 `demo_2d/` 中替换现有 placeholder 资源。
- 如果需要复用现有玩法逻辑，可以从 `demo_2d/` 复制场景/脚本到 `demo_2d_art/`，再在新目录中重构。
- `demo_2d/` 继续作为“玩法基线”保留，便于和美术优化版做 A/B 对照。

提交规则：

- 提交原创源资产、Godot 项目内使用的图片/字体/材质/shader。
- 如果 Godot 为资源创建 `*.import` sidecar，随源资产一起提交。
- 不提交 `.godot/`、导出包、录屏文件、临时截图和设计工具缓存。
- 外部资产必须在 `demo_2d_art/README.md` 或 attribution 文件中记录来源、作者、许可证和下载日期。

## 4. 分阶段计划

### 阶段 2A：建立 2D 视觉规格

- [x] 创建独立项目目录 `demo_2d_art/`，不要在 `demo_2d/` 上直接开工。
- [x] 在 `demo_2d_art/ART_DIRECTION.md` 写 1 页视觉方向。
- [x] 定义 6 到 10 个主色：背景、面板、玩家、玩家核心、信标、危险、护盾、文字、强调。
- [x] 定义形状语言：玩家偏三角/箭头，信标偏圆/菱形，危险偏尖角/红环。
- [x] 定义像素/矢量/程序化图形路线；当前以 Godot 内置节点和程序化矢量图形为主。
- [x] 为开始、游玩、受击、胜利、失败各写一句视觉反馈目标。

验收：

- [x] 不打开 Godot 也能通过 `ART_DIRECTION.md` 理解最终画面目标。

### 阶段 2B：在独立示例中替换玩家/信标/无人机的 placeholder 表现

- [x] 为玩家拆分 `Body`、`Core`、`Thruster`、`ShieldRing`、`HitFlash` 等视觉子节点。
- [x] 给玩家增加移动方向推进器、加速拖尾或轻量残影。
- [x] 给信标增加外圈扫描环、核心闪烁、可收集半径提示。
- [x] 给无人机增加危险外环、前进方向提示、短拖尾。
- [x] 给玩家受击增加短屏闪、护盾环闪烁或击退方向火花。
- [x] 给收集行为增加小型粒子爆发或扩散圆环。

验收：

- [x] 关闭 UI 时，仍能凭颜色和轮廓区分玩家、目标、危险。
- [x] 所有关键对象在 960x640 原始窗口下可读。

### 阶段 2C：升级训练场和背景

- [x] 把背景控制在“远景 + 一套低对比导视层 + 训练场主面板 + 边界反馈”四层以内，不叠加多套常驻线框。
- [x] 只保留一类轻量扫描辅助效果，并确保它比玩家、信标、无人机更弱。
- [x] 添加边界碰撞可读反馈，例如 drone 反弹时边框局部闪烁；优先事件反馈，而不是常亮警戒线。
- [x] 场地内装饰默认只保留少量方向辅助元素；当前仅保留低对比导视线，不继续堆叠刻度和扇形导视线。
- [x] 保持玩法碰撞边界与视觉边界一致，避免“看见能走，实际不能走”。

验收：

- [x] 背景比基线更完整，但玩家、信标和红色 drone 仍是最高视觉优先级。
- [x] 在静帧里，不会先注意到背景装饰，而是先注意到目标和危险。

### 阶段 2D：UI/HUD 美术化

- [x] 明确继续使用默认字体，不引入外部字体。
- [x] 把 HUD 拆成标题、任务进度、护盾、计时、状态播报、开始/结算提示。
- [x] 为 `READY / PLAYING / WON / LOST` 四个状态定义不同 message panel 样式。
- [x] 为低护盾、低时间增加颜色/脉冲反馈。
- [x] 保证状态提示在窗口缩放时不遮住玩家或信标。
  已通过人工缩放验证；状态卡片保持在顶部信息带右侧，没有压进竞技场核心路径。

验收：

- [x] 新玩家 5 秒内能理解目标、风险、剩余资源和开始/重开按键。

### 阶段 2E：2D 光照、Shader 和后期感

- [x] 默认不引入 `CanvasModulate` + `PointLight2D`；只有在明确提升对象识别时才重新评估。
- [x] 给信标/玩家核心/危险单位添加可控 glow 感；如果使用 shader，参数命名要可读，效果数量要少。
- [x] 常驻屏幕空间效果最多保留 1 类主效果，例如轻扫描线或轻暗角；不要同时叠加噪点、干扰和强暗角。
- [x] 为特效添加开关或集中参数，方便后续调性能和清晰度。

验收：

- [x] 截图静帧可读；运动中没有过曝、闪烁疲劳或遮挡目标的问题。
- [x] 关闭后期效果后，核心玩法信息仍然完整，不依赖后期才能看懂。
  已通过关闭 `enable_scan_overlay` 的人工验证；玩家、信标、无人机和 HUD 状态仍然能够直接分辨。

### 阶段 2F：资产管线和性能检查

- [x] 在 `demo_2d_art/README.md` 记录新增资产路径、来源和运行要求。
- [x] 在 `demo_2d_art/REFERENCES.md` 记录实际参考过的 art / shader / particle demo。
- [x] 控制每次导入资源的数量；当前未引入外部素材包，优先替换关键对象。
- [x] 对粒子、shader、光照做“最小有效数量”检查；当前只保留轻量 shader，不引入额外光照与粒子系统。
- [x] 保留 placeholder 回退路径，直到新资产在 Godot 中验证过；`demo_2d/` 继续作为玩法基线回退目录。

验收：

- [x] `git status --short --ignored=matching demo_2d_art` 中没有意外缓存、导出包或本地设计工具产物；当前仅有源码修改与预期的 `.godot/` 忽略目录。

## 5. 提交前验证

```sh
godot --headless --path demo_2d_art --quit-after 1
godot --headless --editor --quit --path demo_2d_art
git diff --check -- demo_2d_art README.md docs/PLAN.md docs/PLAN_2D_ART.md
git status --short
```

当前已完成：

- [x] `godot --headless --path demo_2d_art --quit-after 1`
- [x] `godot --headless --editor --quit --path demo_2d_art`
- [x] `git diff --check -- demo_2d_art docs/PLAN_2D_ART.md`

人工检查建议：

- [x] 用 `godot --path demo_2d_art` 玩一次完整胜利或失败流程。
- [x] 在窗口原始尺寸和拉大尺寸各看一次 HUD 和对象读图。
- [x] 检查 Godot Debugger 是否有缺失资源、shader 编译错误、import warning。
- [x] 截 1 张“游玩中”截图，和 `ART_DIRECTION.md` 的目标对照。

建议执行顺序：

- [x] 先在 Inspector 中关闭 `enable_scan_overlay`，检查关闭后期时玩家、信标、无人机和 HUD 是否仍然易读。
- [x] 保持扫描叠层关闭，完成一次短流程试玩，确认状态卡片和底栏播报不会遮挡核心路径。
- [x] 恢复扫描叠层后再看一次完整画面，确认后期只是在增强氛围，而不是替代基础可读性。

## 6. 首轮美术优化完成标准

- [x] `demo_2d_art/` 是一个独立可运行的 2D 美术优化示例。
- [x] `Signal Sweep` 美术优化版有一份清晰的 `ART_DIRECTION.md`。
- [x] 玩家、信标、无人机不再只是基础 Polygon/Line placeholder。
- [x] 至少有 3 类事件反馈：收集、受击、胜利/失败。
- [x] 背景、边界、HUD、核心对象形成统一的“信号训练场”风格，但背景和后期不与核心对象争抢注意力。
- [x] 没有引入无来源记录的外部图片、字体、音频或素材包。
- [x] `demo_2d/` 原始玩法基线没有被直接改写。
- [x] `demo_2d_art/` 的两条 Godot headless 验证通过。
