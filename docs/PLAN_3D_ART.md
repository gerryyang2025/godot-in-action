# Beacon Runner 3D 美术与渲染优化计划

本计划用于基于现有 `demo_3d/` 维护一个独立的 3D 美术优化示例，而不是直接修改原始 `Beacon Runner 3D` 基线。`demo_3d_art/` 继续承担模型轮廓、材质、灯光、环境、HUD 和反馈实验；不要修改 Godot 上游源码、文档或官方 demo 参考目录，也不要覆盖原来的 `demo_3d/`。

当前仓库状态：`demo_3d_art/` 的首轮独立实现已经存在；本文件按“已完成 / 待补强 / 待验证”回填当前进度，避免计划和实际实现脱节。

## 0. 默认方向

- 基线参考项目：`demo_3d/`
- 目标美术示例项目：`demo_3d_art/`
- 基线 demo：`Beacon Runner 3D`
- 目标引擎：`Godot 4.6.2`
- 默认视觉关键词：低多边形科幻训练场、深色地面、青色玩家、绿色信标、红色巡逻 drone、清晰边界、受控 glow、可读高度。
- 首版仍优先：输入响应、碰撞可信、目标清晰、性能稳定、资产来源明确。
- 原则：保留 `demo_3d/` 作为当前玩法基线；所有美术优化默认在 `demo_3d_art/` 中实现。

## 0.1 当前进度快照

- 已完成：独立项目目录、`ART_DIRECTION.md` / `DESIGN.md` / `REFERENCES.md`、命名 `StandardMaterial3D` 资源、`WorldEnvironment` + 程序天空 + 雾 + glow、玩家/信标/无人机轮廓升级、收敛后的边缘光栏、控制台风格 HUD、开始说明页、成功/失败结算面板、屏幕闪光反馈、`Q` 干扰脉冲的对象级扩散特效、两条 headless 验证。
- 待补强：性能预算表、无人机地面路径投影、落地与信标收集等更多对象级事件特效、AA 对比记录、世界空间提示、完整人工可读性回归。
- 已验证：`2026-04-11` 已运行 `godot --headless --path demo_3d_art --quit-after 1` 和 `godot --headless --editor --quit --path demo_3d_art`，当前没有启动级报错。

## 0.2 当前收敛原则

- 后续迭代优先补“帮助读图”的效果，不为“更像成品”盲目增加贴花、后期、粒子或外部资产。
- 只要玩家、信标、无人机、边界层级和 HUD 已经足够清楚，就优先保持轻量 primitive 路线。
- 新增 glow、雾、灯光、粒子前，先明确它解决的是哪个具体问题，例如远距离识别、路径引导或状态反馈。
- 在没有明确收益前，不引入外部模型、贴图、HDRI、字体和音频。
- 地图中心的地面导视蓝线已被视为多余功能，不再作为后续设计目标保留。

## 1. 当前视觉现状

- 玩家：已从单一 capsule 升级为带胸甲、背包、推进器、头灯和天线的探索装轮廓；移动时有 bob、倾斜和推进器伸缩，受击时有闪烁无敌，`Q` 干扰脉冲现在也会触发贴地扩散环、能量壳和核心爆闪，但落地特效仍缺席。
- 信标：已具备底座、发光核心、halo、环轨和光柱；当前扩展场地已提升到 8 个收集点，远距离识别明显，收集时主要依赖 HUD 播报和绿色屏闪，尚未加入本地粒子爆发。
- 无人机：已具备机身、翼片、旋翼、前向传感器、危险环和红色脉冲灯；当前玩法已升级为 5 架开局巡逻机加 3 架分段增援机，其中部分单位会在玩家穿过其航线时进入短时追击。玩家现已具备“利用掩体打断视线”与“干扰脉冲”两种脱离追击手段，但尚未把巡逻路径投影到地面。
- 场地：已扩成更大的训练场，并具备低墙、收敛后的边缘光栏、中心能量柱、塔架、多段坡道、侧向立柱和训练阻挡块；可走区域与边界更清楚，但信标编号、地面贴花和路径端点标记仍可继续补强。
- 灯光：已建立 `WorldEnvironment`、程序天空、雾、tonemap、glow、主平行光和场地补光；抗锯齿与进一步后期仍未单独做 A/B 记录。
- UI：已具备顶部信息带、底部播报条、任务进度、护盾、倒计时、开始说明页、开始/重开提示、成功/失败结算面板和屏幕闪光；尚未加入 `Label3D` 或世界内路径箭头。

## 2. 本地参考入口

优先核对这些本地参考；官方 demo 是 `4.2` 快照，最终以 `4.6.2` 本地验证为准。

- `godot-docs-stable/tutorials/3d/`
- `godot-docs-stable/tutorials/3d/lights_and_shadows.rst`
- `godot-docs-stable/tutorials/3d/global_illumination/`
- `godot-docs-stable/tutorials/3d/standard_material_3d.rst`
- `godot-docs-stable/tutorials/3d/environment_and_post_processing.rst`
- `godot-docs-stable/tutorials/3d/3d_antialiasing.rst`
- `godot-docs-stable/tutorials/shaders/`
- `godot-docs-stable/tutorials/assets_pipeline/importing_images.rst`
- `godot-docs-stable/tutorials/assets_pipeline/importing_3d_scenes/`
- `godot-docs-stable/classes/class_standardmaterial3d.rst`
- `godot-docs-stable/classes/class_worldenvironment.rst`
- `godot-docs-stable/classes/class_gpuparticles3d.rst`
- `godot-docs-stable/classes/class_decal.rst`
- `godot-demo-projects-4.2-31d1c0c/3d/lights_and_shadows/`
- `godot-demo-projects-4.2-31d1c0c/3d/material_testers/`
- `godot-demo-projects-4.2-31d1c0c/3d/procedural_materials/`
- `godot-demo-projects-4.2-31d1c0c/3d/decals/`
- `godot-demo-projects-4.2-31d1c0c/3d/volumetric_fog/`
- `godot-demo-projects-4.2-31d1c0c/3d/global_illumination/`
- `godot-demo-projects-4.2-31d1c0c/3d/antialiasing/`
- `godot-demo-projects-4.2-31d1c0c/3d/physical_light_camera_units/`
- `godot-demo-projects-4.2-31d1c0c/3d/platformer/`
- `godot-demo-projects-4.2-31d1c0c/3d/squash_the_creeps/`

## 3. 目录与资产约定

当前 `demo_3d_art/` 已采用独立项目结构；后续扩展继续沿这个方向整理：

```text
demo_3d_art/
  project.godot
  README.md
  DESIGN.md
  REFERENCES.md
  ART_DIRECTION.md
  scenes/
  scripts/
  materials/
  assets/      # 如后续引入外部模型或贴图，再按来源拆分
    models/
    textures/
    decals/
  shaders/     # 需要自定义 shader 时再启用
  vfx/         # 需要把特效资源独立化时再启用
  ui/          # 需要主题或字体时再启用
```

实施边界：

- 不要直接在 `demo_3d/` 中替换现有 primitive、材质或场景布置。
- 如果需要复用现有玩法逻辑，可以从 `demo_3d/` 复制场景/脚本到 `demo_3d_art/`，再在新目录中重构。
- `demo_3d/` 继续作为“玩法基线”保留，便于和美术优化版做 A/B 对照。

提交规则：

- 优先提交小型原创 `.glb` / `.blend` / `.png` / `.webp` / `.tres` / shader 文件。
- 如果 Godot 为资源创建 `*.import` sidecar，随源资产一起提交。
- 不提交 `.godot/`、导出包、烘焙实验缓存、渲染截图批量输出、设计工具缓存。
- 外部模型、贴图、HDRI、字体和音频必须记录到 `demo_3d_art/README.md` 或 attribution 文件中，包含来源、作者、许可证、下载日期和是否改造。
- 当前首轮实现没有引入外部模型或贴图；若下一轮开始引入，先补文档再落资源。

## 4. 分阶段计划

### 阶段 3A：建立 3D 视觉规格和性能预算

- [x] 创建独立项目目录 `demo_3d_art/`，不要在 `demo_3d/` 上直接开工。
- [x] 在 `demo_3d_art/ART_DIRECTION.md` 写 1 页视觉方向。
- [x] 明确采用“低多边形科幻训练场 + Godot 内置 primitive + 轻量发光材质”的路线。
- [x] 定义玩家、信标、危险、可走地面、不可走边界和强调装置的材质/颜色编码。
- [x] 定义相机截图目标，让玩家、最近信标、巡逻威胁和 HUD 在默认镜头下可读。
- [ ] 把性能预算补成可执行表格：最大实时灯数、粒子发射器数、贴图最大尺寸、模型三角面粗略上限。

验收：

- [x] `ART_DIRECTION.md` 已包含文字版“目标截图描述”。
- [ ] 补一张资产清单或预算表，避免后续迭代失控。

### 阶段 3B：材质、环境和色彩基线

- [x] 新建 `demo_3d_art/materials/`，把主场景和关键角色材质抽成命名 `.tres`。
- [x] 为地面、墙、坡、柱子、玩家、信标、无人机建立统一 roughness / metallic / emission 规则。
- [x] 增加 `WorldEnvironment`，设置背景、ambient、tonemap、glow 和 fog。
- [x] 控制 glow 只服务于信标、玩家高光、危险环和少量边界强调，不让全场景一起发光。
- [x] 调整 `DirectionalLight3D` 与场地补光，让玩家始终能从背景中分离出来。

验收：

- [x] 当前即使不改玩法，单靠材质、环境和灯光也能读出前景、中景、边界和目标层级。

### 阶段 3C：在独立示例中替换关键角色 silhouette

- [x] 把玩家从单 capsule 升级为多个 primitive 组成的探索装轮廓。
- [x] 给玩家添加方向性强的胸甲、背包、推进器、头灯和天线。
- [x] 给 drone 添加机身、旋翼、传感器和危险环，保持红色危险编码。
- [x] 给信标添加底座、光柱和环形结构，确保远处也能识别。
- [x] 当前不导入外部模型，继续保留 `CollisionShape3D` 的手工可控性。

验收：

- [x] 在默认相机距离下，玩家面朝方向、信标和 drone 已能一眼区分。

### 阶段 3D：关卡美术和路径可读性

- [x] 给训练场增加收敛后的边缘光栏和中心装置，帮助玩家读清边界和空间重心。
- [x] 添加少量非核心道具和结构，如塔架、中心柱和边界墙体，补出训练场氛围。
- [x] 为可碰撞墙、柱、坡建立清晰的材质区别和光边层级。
- [ ] 给每条 drone 巡逻路径增加地面警戒线、投影或端点标记。
- [x] 当前装饰物没有明显挡住相机、信标或玩家主要落点。

验收：

- [ ] 玩家不看 README 也能推断目标点和可走区域，但危险路线仍建议通过地面投影继续补强。

### 阶段 3E：VFX、动画和反馈

- [x] 玩家移动时已具备轻量 bob、倾斜、推进器伸缩和核心灯脉冲。
- [x] `Q` 干扰脉冲现在已有玩家本体扩散环、能量壳和核心爆闪，技能释放范围更容易被读懂。
- [ ] 玩家跳跃、落地、受击各至少 1 个局部视觉反馈；当前受击最明确，落地特效仍缺。
- [x] 信标 idle 时已有悬浮、旋转、halo、环轨和光柱；收集时当前由 HUD 播报和绿色屏闪承担反馈。
- [x] drone 接触玩家时已有红色闪光和短暂无敌闪烁。
- [x] 胜利/失败现在会显示独立结算面板，区分成功、护盾耗尽、超时和坠落失败原因。
- [ ] 场地灯色或 HUD 状态转场还可以更强。

验收：

- [x] 玩家已经可以通过视觉反馈判断：已收集、受伤、倒计时压力、胜利、失败。

### 阶段 3F：相机、后期和 UI 合成

- [x] 已微调相机高度、FOV、跟随速度和 `look_at()` 目标，减少斜俯视下的距离误判。
- [ ] 抗锯齿设置还没有形成单独的对比记录。
- [x] UI 已具备半透明顶部信息带、底部播报条、任务状态、开始说明页、按键提示和结算面板。
- [ ] 3D 世界内标记仍未加入，例如 `Label3D`、路径箭头或出口方向。
- [ ] 雾、glow 和 HUD 对远处信标可读性的完整人工回归仍需补一次。

验收：

- [ ] 需要再做一轮人工游玩检查，确认动态过程中不存在“玩家跑出画面、drone 隐在背景里、信标被 UI 挡住”的问题。

### 阶段 3G：资产管线、版权和性能检查

- [x] 在 `demo_3d_art/README.md` 记录了项目定位、运行要求和当前资产边界。
- [x] 在 `demo_3d_art/REFERENCES.md` 记录了实际参考过的本地 3D demo 和文档入口。
- [x] 当前没有导入外部模型；碰撞体策略仍然是手工 `CollisionShape3D`。
- [x] 实时点光源数量仍然克制，当前以场地补光和对象局部光源为主。
- [ ] 对 glow、雾、阴影继续做 A/B 检查，删除“看起来热闹但不帮助玩法”的效果。

验收：

- [x] `2026-04-11` 运行 `git status --short --ignored=matching demo_3d_art` 时，只看到预期的 `.godot/` 忽略目录，没有发现导出包、设计缓存或其他意外产物。

## 5. 提交前验证

```sh
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
git diff --check -- demo_3d_art README.md docs/PLAN.md docs/PLAN_3D_ART.md
git status --short
```

当前已完成：

- [x] `2026-04-11` 已运行 `godot --headless --path demo_3d_art --quit-after 1`
- [x] `2026-04-11` 已运行 `godot --headless --editor --quit --path demo_3d_art`
- [x] `2026-04-11` 已运行 `git diff --check -- demo_3d_art README.md docs/PLAN.md docs/PLAN_3D_ART.md`

人工检查建议：

- [ ] 用 `godot --path demo_3d_art` 玩一次完整胜利或失败流程。
- [ ] 从默认相机视角检查玩家、信标、drone、UI 和地面危险路径是否可读。
- [ ] 检查 Godot Debugger 是否有缺失模型、缺失贴图、shader 编译错误或 import warning。
- [ ] 截 1 张“游玩中”截图，和 `ART_DIRECTION.md` 的目标对照。

建议执行顺序：

- [ ] 先正常游玩一轮，确认 HUD、相机、边界高光和屏闪不会打断读图。
- [ ] 再重点检查远处绿色信标、红色 drone 与青色边界强调是否发生视觉竞争。
- [ ] 如需继续 polish，再决定是否补地面投影、局部粒子或更强的结算状态。

## 6. 首轮美术优化完成标准

- [x] `demo_3d_art/` 是一个独立可运行的 3D 美术优化示例。
- [x] `Beacon Runner 3D` 美术优化版有一份清晰的 `ART_DIRECTION.md`。
- [x] 关键材质已经从场景内联资源逐步整理为命名 `.tres`。
- [x] 玩家、信标、无人机具备可辨 silhouette，而不只是单一 primitive。
- [ ] 场地已具备地面引导、边界层级和基础背景装饰，但危险路径提示仍可继续补强。
- [ ] 至少有 4 类事件反馈；当前已覆盖收集、受击、胜负和时间压力，跳跃/落地反馈仍不够完整。
- [x] 没有引入无来源记录的模型、图片、HDRI、字体、音频或素材包。
- [x] `demo_3d/` 原始玩法基线没有被直接改写。
- [x] `demo_3d_art/` 的两条 Godot headless 验证通过。
