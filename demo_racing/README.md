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
```

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
- 分级鼓励：Combo 会按连续数量给出不同的屏幕特效和语音反馈，从 `GOOD / COOL / GREAT` 一路抬到 `UNBELIEVABLE`；高连击还会触发短暂节油窗口。
- 碰撞惩罚：撞上前车不会直接结算，而是把对方撞飞、让玩家车辆重刹减速并清空当前连击；真正结束条件只有燃油耗尽。
- 劫持大车：与大型车辆同车道并贴近时起跳，会直接接管并合并为当前受控大车；期间无敌且不耗油，还能直接撞飞挡路车辆。
- 隐身穿车：赛道会周期性刷新隐身道具，拾取后玩家车辆进入透明状态，可直接穿过车流并把穿车本身计入 Combo、分数和续航回补。
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
- `tools/generate_audio.py`：本地生成背景音乐、发动机循环和玩法提示音的脚本。
- `DESIGN.md`：首版范围和设计取舍。
- `REFERENCES.md`：使用过的本地参考资料和外部素材入口。
- `CREDITS.md`：第三方资源来源与授权说明。

## 当前实现范围

- 已实现五车道高速闪避、持续加速、燃油消耗、分数与距离结算。
- 已实现“贴尾后变线”的险超连击判定，并把燃油回补和连击奖励绑定到同一个动作上。
- 已实现按连击数量递进的 Combo 特效和英语语音鼓励，让高连击反馈更有爬升感。
- 已实现可劫持大型车辆的短暂无敌/免油耗状态，以及劫持后的撞飞清路玩法。
- 已实现蓝色隐身拾取物；激活后玩家车辆会进入透明穿车状态，并能把穿车转换成高收益 Combo。
- 已实现最小成长层：credits、三项升级、五档车阶，以及基于 `user://demo_racing_save.cfg` 的持久化。
- 已接入 Quaternius `Cars Pack`、`Public Transport Pack`、`Modular Streets Pack` 的 CC0 资源，并把车流明确区分为轿车、服务车和大车三类轮廓。
- 已把路侧装饰升级为双头路灯、交通信号灯和路牌，让赛道不再只有程序化盒体。
- 已按仓库内其他 demo 的展示习惯，在首页右下角补充作者署名 `Created by Gerry`。
- 已加入背景音乐、发车/跳跃/险超/劫持/隐身拾取等玩法音效，以及 Combo 分级语音提示。
- 当前仍未加入 BOSS 关卡或可点击的完整主菜单；这些适合留到下一轮 polish。
