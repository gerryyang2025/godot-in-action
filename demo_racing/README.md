# Infinite Racer

`Infinite Racer` 是一个独立的 Godot 4.6.2 竞速闪避 demo。它不追求传统赛车里的“第一名”，而是把核心循环聚焦在高速车流中的几件事：贴尾切线打出险超连击、在车阵密集时劫持大型车辆续命、通过隐身道具快速穿车堆高 Combo，以及通过轻量改装把车一步步推到更高等级。

## 运行

目标版本：Godot `4.6.2`

```sh
godot --path demo_racing
```

如果你的 Godot 不在 PATH 中，请用本机 Godot 4.6.2 编辑器打开 `demo_racing/project.godot`。

## 测试

```sh
godot --headless --path demo_racing --quit-after 1
godot --headless --editor --quit --path demo_racing
./demo_racing/tools/verify_fresh_checkout.sh
```

其中 `verify_fresh_checkout.sh` 会把 `demo_racing/` 复制到一个不带项目级 `.godot/` 缓存的临时目录里，再执行启动和编辑器导入检查；它用于保证新环境 `git clone` 后也能直接运行，而不是只在当前机器导入过一次后才正常。

## 操作

- `A` / `D` 或方向键左右：五车道切线
- `Space`：起跳；贴近同车道大型车辆时会触发劫持
- `Enter`：从开始页或结算页进入下一局
- `1`：升级加速度
- `2`：升级最高速
- `3`：升级节油
- `P`：晋升当前车辆等级

## 核心玩法

- 险超连击：先贴近前车尾部，再在最后一拍切到其他车道。成功后会累积 Combo、提高分数，并立刻回补燃油。
- 分级鼓励：Combo 会按连续数量给出不同的屏幕特效和语音反馈，从 `GOOD / COOL / GREAT` 一路抬到 `UNBELIEVABLE / I LOVE YOU`；高连击还会触发短暂节油窗口。
- 碰撞惩罚：撞上前车不会直接结算，而是把对方撞飞、让玩家车辆重刹减速并清空当前连击；真正结束条件只有燃油耗尽。
- 劫持大车：与大型车辆同车道并贴近时起跳，会直接接管并合并为当前受控大车；期间无敌且不耗油，还能直接撞飞挡路车辆。
- 隐身穿车：赛道会周期性刷新隐身道具，拾取后玩家车辆进入高透明隐身状态，可直接穿过车流并把穿车本身计入 Combo、分数和续航回补。
- 车辆成长：每局结束按分数、距离和最佳 Combo 结算 credits，可在开局前升级 `加速度 / 最高速 / 节油`，并从 `C -> B -> A -> S -> T` 逐步晋升。

## 主要文件

- `project.godot`：项目配置和输入映射。
- `scenes/main.tscn`：主场景、相机、灯光、HUD、开始页、结算页和音频播放器。
- `scenes/player_car.tscn`：玩家跑车场景。
- `scenes/traffic_vehicle.tscn`：民用轿车、服务车辆、大型车辆的统一交通单位场景。
- `scripts/main.gd`：高速路生成、车流刷新、险超结算、劫持、成长存档和 UI。
- `scripts/player_car.gd`：变线、跳跃、劫持状态下的玩家车辆表现。
- `scripts/traffic_vehicle.gd`：车流车型变体切换、近身判定和大车劫持状态。
- `assets/third_party/quaternius/`：当前接入的 Quaternius CC0 车辆与道路装饰资源。
- `assets/runtime/`：从 OBJ 和音频源文件导出的正式 `.res` 运行时资源，保证 fresh clone 也能直接 `godot --path demo_racing`，不依赖项目级 `.godot/imported/` 缓存。
- `tools/generate_audio.py`：本地生成背景音乐、发动机循环和玩法提示音的脚本。
- `tools/export_runtime_assets.gd`：当第三方模型或音频源文件更新后，重新导出 `assets/runtime/` 的 Godot 运行时资源。
- `tools/verify_fresh_checkout.sh`：在临时目录中模拟一个没有 `.godot/` 缓存的新环境，并执行启动级验证。
- `DESIGN.md`：首版范围和设计取舍。
- `REFERENCES.md`：使用过的本地参考资料和外部素材入口。
- `CREDITS.md`：第三方资源来源与授权说明。

## 当前实现功能

- 五车道无限高速赛道：支持持续加速、路段循环、路侧装饰滚动，以及适合当前玩法的较宽可视范围。
- 完整前端流程：已接入游戏首页、进行中 HUD、结算页和基础车库信息展示；首页与结算页都会根据窗口大小做自适应排版。
- 核心资源系统：已实现燃油、分数、距离、Combo、最佳 Combo、credits、车阶和三项升级数据，并持久化到 `user://demo_racing_save.cfg`。
- 险超连击：已实现“贴尾后变线”的判定窗口；成功后会同时提升分数、刷新 Combo、回补燃油。
- 分级 Combo 反馈：已实现中心爆字、屏幕闪色、提示文案和英语语音播报。当前梯度为 `GOOD / COOL / GREAT / PERFECT / WELL DONE / WONDERFUL / EXCELLENT / AMAZING / UNBELIEVABLE / I LOVE YOU`。
- 高连击节油：Combo 达到较高档位后会进入短暂 `Fuel Save` 窗口，在窗口内继续冲分时不会消耗燃油。
- 劫持大车：玩家可通过 `Space` 起跳并劫持大型车辆；劫持成功后车辆会合并为当前受控大车，玩家可左右变线并撞飞其他车辆。
- 劫持缓冲：劫持结束后会给予一小段落地护盾时间，避免玩家立刻因为落位问题再次吃到碰撞。
- 隐身道具：赛道会刷新蓝色隐身拾取物；拾取后玩家车辆进入高透明隐身状态，不再与普通车流发生碰撞，并可通过穿车快速累积高收益 Combo。
- 碰撞降级处理：普通撞车不会直接 Game Over，而是进入减速恢复状态，同时清空当前 Combo；只有燃油耗尽才会结束本局。
- 车流调优：当前中后期车流已做减密处理，包含活跃车辆上限、同车道间距、单波占道数和二次波概率的控制，避免后期过度堵死。
- 美术接入：已使用 Quaternius `Cars Pack`、`Public Transport Pack`、`Modular Streets Pack` 的 CC0 资源，并把车流区分为轿车、服务车和大型车辆三类轮廓。
- 音频反馈：已接入背景音乐、发车、跳跃、险超、劫持、隐身拾取、升级、晋升、碰撞和燃油耗尽等音效；Combo 语音已替换为本地 TTS 版本。
- 展示与署名：首页已补充作者信息 `Created by Gerry`，项目可直接作为仓库中的独立 Godot demo 运行。

## 当前限制

- 还没有 BOSS 关卡、任务系统、地图切换或正式关卡结构。
- 车流 AI 仍以固定车道推进为主，未实现主动并线、急刹或追击行为。
- 目前的成长层以数值升级和车阶晋升为主，尚未加入车辆解锁、技能分支或更复杂的改装系统。
