# Signal Sweep 2D 美术与渲染优化计划

本计划用于把 `demo_2d/` 从“可玩 placeholder”推进到“有明确视觉方向的 2D 垂直切片”。它只规划 `demo_2d/` 内的原创美术、材质、VFX、UI 和相机反馈；不要把美术实验混入 Godot 上游参考目录。

## 0. 默认方向

- 目标项目：`demo_2d/`
- 当前 demo：`Signal Sweep`
- 目标引擎：`Godot 4.6.2`
- 默认视觉关键词：深空训练场、霓虹信号、雷达扫描、清晰危险航线、干净战术 HUD。
- 首版仍优先：读图清楚、玩法反馈强、运行稳定、资产来源明确。

## 1. 当前视觉现状

- 玩家：`Polygon2D` 小飞船，颜色可读，但没有动画帧、推进器、拖尾或受击特效。
- 信标：简单 2D 节点和脚本脉冲，缺少“信号/收集价值”的分层反馈。
- 无人机：红色危险单位，运动可读，但缺少预警轨迹、危险半径和击中反馈。
- 场地：`ColorRect` 背景 + `Line2D` 边框，功能明确，但空间、层次和主题感较弱。
- UI：基础 `Label`，信息完整，但没有字体、颜色层级、状态过渡或结算面板。
- 音频：暂未实现。本计划重点是美术/渲染，音频只作为反馈联动点记录。

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

## 3. 建议资产目录

保留现有 `scenes/`、`scripts/`。新增资产时建议使用：

```text
demo_2d/
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

提交规则：

- 提交原创源资产、Godot 项目内使用的图片/字体/材质/shader。
- 如果 Godot 为资源创建 `*.import` sidecar，随源资产一起提交。
- 不提交 `.godot/`、导出包、录屏文件、临时截图和设计工具缓存。
- 外部资产必须在 `demo_2d/README.md` 或 attribution 文件中记录来源、作者、许可证和下载日期。

## 4. 分阶段计划

### 阶段 2A：建立 2D 视觉规格

- [ ] 在 `demo_2d/ART_DIRECTION.md` 写 1 页视觉方向。
- [ ] 定义 6 到 10 个主色：背景、面板、玩家、玩家核心、信标、危险、护盾、文字、强调。
- [ ] 定义形状语言：玩家偏三角/箭头，信标偏圆/菱形，危险偏尖角/红环。
- [ ] 定义像素/矢量/程序化图形路线；首选一种，不混用过多风格。
- [ ] 为开始、游玩、受击、胜利、失败各写一句视觉反馈目标。

验收：

- [ ] 不打开 Godot 也能通过 `ART_DIRECTION.md` 理解最终画面目标。

### 阶段 2B：替换玩家/信标/无人机的 placeholder 表现

- [ ] 为玩家拆分 `Body`、`Core`、`Thruster`、`ShieldRing`、`HitFlash` 等视觉子节点。
- [ ] 给玩家增加移动方向推进器、加速拖尾或轻量残影。
- [ ] 给信标增加外圈扫描环、核心闪烁、可收集半径提示。
- [ ] 给无人机增加危险外环、前进方向提示、短拖尾。
- [ ] 给玩家受击增加短屏闪、护盾环闪烁或击退方向火花。
- [ ] 给收集行为增加小型粒子爆发或扩散圆环。

验收：

- [ ] 关闭 UI 时，仍能凭颜色和轮廓区分玩家、目标、危险。
- [ ] 所有关键对象在 960x640 原始窗口下可读。

### 阶段 2C：升级训练场和背景

- [ ] 把单色背景拆成远景星尘、暗色网格、训练场地面、边界光带。
- [ ] 添加低对比度雷达扫描线或周期性扇形扫描，不遮挡玩法。
- [ ] 添加边界碰撞可读反馈，例如 drone 反弹时边框局部闪烁。
- [ ] 在场地内增加非碰撞装饰线、坐标刻度、警戒区标识。
- [ ] 保持玩法碰撞边界与视觉边界一致，避免“看见能走，实际不能走”。

验收：

- [ ] 背景变丰富，但信标和红色 drone 仍是最高视觉优先级。

### 阶段 2D：UI/HUD 美术化

- [ ] 选择并引入一套可提交/可授权的字体，或明确继续使用默认字体。
- [ ] 把 HUD 拆成标题、任务进度、护盾、计时、状态播报、开始/结算提示。
- [ ] 为 `READY / PLAYING / WON / LOST` 四个状态定义不同 message panel 样式。
- [ ] 为低护盾、低时间增加颜色/脉冲反馈。
- [ ] 保证状态提示在窗口缩放时不遮住玩家或信标。

验收：

- [ ] 新玩家 5 秒内能理解目标、风险、剩余资源和开始/重开按键。

### 阶段 2E：2D 光照、Shader 和后期感

- [ ] 评估是否引入 `CanvasModulate` + `PointLight2D`，不要只为了“炫”而牺牲清晰度。
- [ ] 给信标/玩家核心/危险单位添加可控 glow 感；如果使用 shader，参数命名要可读。
- [ ] 尝试 1 个屏幕空间轻量效果，例如扫描线、暗角、轻噪点或信号干扰。
- [ ] 为特效添加开关或集中参数，方便后续调性能和清晰度。

验收：

- [ ] 截图静帧可读；运动中没有过曝、闪烁疲劳或遮挡目标的问题。

### 阶段 2F：资产管线和性能检查

- [ ] 在 `demo_2d/README.md` 记录新增资产路径、来源和运行要求。
- [ ] 在 `demo_2d/REFERENCES.md` 记录实际参考过的 art / shader / particle demo。
- [ ] 控制每次导入资源的数量；先替换关键对象，不批量搬入素材包。
- [ ] 对粒子、shader、光照做“最小有效数量”检查。
- [ ] 保留 placeholder 回退路径，直到新资产在 Godot 中验证过。

验收：

- [ ] `git status --short --ignored=matching demo_2d` 中没有意外缓存、导出包或本地设计工具产物。

## 5. 提交前验证

```sh
godot --headless --path demo_2d --quit-after 1
godot --headless --editor --quit --path demo_2d
git diff --check -- demo_2d README.md PLAN.md PLAN_2D_ART.md
git status --short
```

人工检查建议：

- [ ] 用 `godot --path demo_2d` 玩一次完整胜利或失败流程。
- [ ] 在窗口原始尺寸和拉大尺寸各看一次 HUD 和对象读图。
- [ ] 检查 Godot Debugger 是否有缺失资源、shader 编译错误、import warning。
- [ ] 截 1 张“游玩中”截图，和 `ART_DIRECTION.md` 的目标对照。

## 6. 首轮美术优化完成标准

- [ ] `Signal Sweep` 有一份清晰的 `ART_DIRECTION.md`。
- [ ] 玩家、信标、无人机不再只是基础 Polygon/Line placeholder。
- [ ] 至少有 3 类事件反馈：收集、受击、胜利/失败。
- [ ] 背景、边界、HUD、核心对象形成统一的“信号训练场”风格。
- [ ] 没有引入无来源记录的外部图片、字体、音频或素材包。
- [ ] 2D demo 的两条 Godot headless 验证通过。
