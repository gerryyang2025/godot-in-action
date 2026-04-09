# Beacon Runner 3D 美术与渲染优化计划

本计划用于基于现有 `demo_3d/` 创建一个独立的 3D 美术优化示例，而不是直接修改原始 `Beacon Runner 3D` 基线。建议新建 `demo_3d_art/`，把模型、材质、灯光、相机和 VFX 实验都放在这个独立目录中；不要修改 Godot 上游源码、文档或官方 demo 参考目录，也不要覆盖原来的 `demo_3d/`。

## 0. 默认方向

- 基线参考项目：`demo_3d/`
- 目标美术示例项目：`demo_3d_art/`
- 基线 demo：`Beacon Runner 3D`
- 目标引擎：`Godot 4.6.2`
- 默认视觉关键词：低多边形科幻训练场、深色地面、青色玩家、绿色信标、红色巡逻 drone、清晰航线、受控 glow、可读高度。
- 首版仍优先：输入响应、碰撞可信、目标清晰、性能稳定、资产来源明确。
- 原则：保留 `demo_3d/` 作为当前玩法基线；所有美术优化默认在 `demo_3d_art/` 中实现。

## 1. 当前视觉现状

- 玩家：`CharacterBody3D` + capsule / box primitive，轮廓可读，但缺少角色身份、移动动画、着陆/受击反馈。
- 信标：发光 sphere + `OmniLight3D`，可见，但缺少底座、投射标记、收集预热/完成反馈。
- 无人机：红色 sphere + wing，路径固定，但缺少传感器、警戒范围、路径投影和击中反馈。
- 场地：box 地面、低墙、柱子、小坡，空间明确，但材质、道具、比例、引导线和背景氛围还很基础。
- 灯光：`DirectionalLight3D` + 信标/无人机点光源；尚未建立 `WorldEnvironment`、雾、反射、色调映射或后期策略。
- UI：基础 2D `Label` 叠层，功能完整，但还没有 3D 任务感、结算面板和状态转场。

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

建议先复制或重建一个独立项目目录，再逐步迁移玩法脚本和场景：

```text
demo_3d_art/
  project.godot
  README.md
  DESIGN.md
  REFERENCES.md
  ART_DIRECTION.md
  assets/
    models/
    textures/
    decals/
  materials/
  shaders/
  vfx/
  ui/
    fonts/
    themes/
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

## 4. 分阶段计划

### 阶段 3A：建立 3D 视觉规格和性能预算

- [ ] 创建独立项目目录 `demo_3d_art/`，不要在 `demo_3d/` 上直接开工。
- [ ] 在 `demo_3d_art/ART_DIRECTION.md` 写 1 页视觉方向。
- [ ] 明确是否走低多边形、硬表面科幻、纯 primitive 风、或轻量卡通 PBR。
- [ ] 定义玩家、信标、危险、可走地面、不可走边界、可跳跃物的材质/颜色编码。
- [ ] 定义相机截图目标：玩家、最近信标、巡逻路径、倒计时都应该可读。
- [ ] 建立首轮预算：最大光源数、粒子发射器数、贴图最大尺寸、模型三角面粗略上限。

验收：

- [ ] `ART_DIRECTION.md` 里有一张文字版“目标截图描述”和一张资产清单表。

### 阶段 3B：材质、环境和色彩基线

- [ ] 新建 `demo_3d_art/materials/`，把主场景内联 material 逐步抽成命名 `.tres`。
- [ ] 为地面、墙、坡、柱子、玩家、信标、无人机建立统一 roughness / metallic / emission 规则。
- [ ] 增加 `WorldEnvironment`，设置背景色/ambient/tonemap/glow 策略。
- [ ] 评估是否启用 glow；先只让信标、玩家核心、危险传感器发光。
- [ ] 调整 `DirectionalLight3D` 角度、颜色、强度，让玩家始终从背景中分离。

验收：

- [ ] 不改玩法，单靠材质/环境/灯光让场景有明确前景、中景、边界和目标层级。

### 阶段 3C：在独立示例中替换关键角色 silhouette

- [ ] 把玩家从单 capsule 升级为 3 到 6 个 primitive/model 组成的探测员或训练机器人。
- [ ] 给玩家添加方向性强的头灯、胸灯、背包或天线。
- [ ] 给 drone 添加机身、旋翼/翼片/传感器眼睛，保持红色危险编码。
- [ ] 给信标添加底座、光柱或悬浮环，确保远处也能识别。
- [ ] 若导入模型，优先用小型 `.glb`，并保留碰撞体的手工可控性。

验收：

- [ ] 在相机默认距离下，玩家面朝方向、信标、drone 能一眼区分。

### 阶段 3D：关卡美术和路径可读性

- [ ] 给训练场增加地面分区、跑道线、信标编号、危险路径投影。
- [ ] 添加少量非碰撞背景道具：天线、信号塔、维修箱、训练靶、远景墙面。
- [ ] 为可碰撞墙/柱/坡添加视觉边线或材质区别。
- [ ] 给每条 drone 巡逻路径增加地面警戒线或端点标记。
- [ ] 保证装饰物不会挡住相机、信标或玩家落地点。

验收：

- [ ] 玩家不看 README，也能从场景中推断目标点、危险路线和可走区域。

### 阶段 3E：VFX、动画和反馈

- [ ] 玩家移动时添加轻量脚步尘/喷气/能量拖尾。
- [ ] 玩家跳跃、落地、受击各至少 1 个视觉反馈。
- [ ] 信标 idle 时有悬浮/旋转/扫描；收集时有光环收缩、粒子爆发或光柱熄灭。
- [ ] drone 接触玩家时有红色闪烁、短暂冲击波或 shield hit 环。
- [ ] 胜利/失败时增加场地灯色或 UI 状态转场。

验收：

- [ ] 玩家可以通过视觉反馈判断：已收集、受伤、倒计时压力、胜利、失败。

### 阶段 3F：相机、后期和 UI 合成

- [ ] 微调相机高度、FOV、跟随速度和 look target，减少斜俯视下的距离误判。
- [ ] 评估抗锯齿设置；优先清晰稳定，不追求过重后期。
- [ ] 给 UI 增加半透明 panel、任务状态、按键提示和结束状态。
- [ ] 评估 3D 世界内标记：信标上方 Label3D、路径箭头、出口方向等。
- [ ] 如果使用暗角/雾/景深，必须验证不会掩盖远处绿色信标。

验收：

- [ ] 动态游玩时没有“玩家跑出画面、drone 隐在背景里、信标被 UI 挡住”的问题。

### 阶段 3G：资产管线、版权和性能检查

- [ ] 在 `demo_3d_art/README.md` 记录新增资产路径、来源和运行要求。
- [ ] 在 `demo_3d_art/REFERENCES.md` 记录实际参考过的 3D art / material / lighting demo。
- [ ] 对每个导入模型记录用途、原始文件、导入结果、碰撞体策略。
- [ ] 控制实时点光源数量；新增灯光前先确认它解决了哪个读图问题。
- [ ] 对粒子、glow、雾、阴影做 A/B 检查，删除“看起来热闹但不帮助玩法”的效果。

验收：

- [ ] `git status --short --ignored=matching demo_3d_art` 中没有意外缓存、导出包、烘焙中间产物或本地设计工具产物。

## 5. 提交前验证

```sh
godot --headless --path demo_3d_art --quit-after 1
godot --headless --editor --quit --path demo_3d_art
git diff --check -- demo_3d_art README.md PLAN.md PLAN_3D_ART.md
git status --short
```

人工检查建议：

- [ ] 用 `godot --path demo_3d_art` 玩一次完整胜利或失败流程。
- [ ] 从默认相机视角检查玩家、信标、drone、UI、地面危险路径是否可读。
- [ ] 检查 Godot Debugger 是否有缺失模型/贴图、shader 编译错误、import warning。
- [ ] 截 1 张“游玩中”截图，和 `ART_DIRECTION.md` 的目标对照。

## 6. 首轮美术优化完成标准

- [ ] `demo_3d_art/` 是一个独立可运行的 3D 美术优化示例。
- [ ] `Beacon Runner 3D` 美术优化版有一份清晰的 `ART_DIRECTION.md`。
- [ ] 关键材质从场景内联资源逐步整理为命名 `.tres` 或明确的资源段。
- [ ] 玩家、信标、无人机具备可辨 silhouette，而不只是单一 primitive。
- [ ] 场地具备地面引导、危险路径提示、边界层级和基础背景装饰。
- [ ] 至少有 4 类事件反馈：收集、跳跃/落地、受击、胜利/失败。
- [ ] 没有引入无来源记录的模型、图片、HDRI、字体、音频或素材包。
- [ ] `demo_3d/` 原始玩法基线没有被直接改写。
- [ ] `demo_3d_art/` 的两条 Godot headless 验证通过。
