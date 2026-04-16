# References

本项目首版主要参考了以下本地资料与外部素材入口，并以 Godot `4.6.2` 作为最终实现版本：

- `demo_3d/`
  - 参考原因：沿用当前仓库独立 3D demo 的目录划分、`project.godot` 结构、单场景 + 少量脚本的实现尺度。
- `demo_tps_art/`
  - 参考原因：借用开始页、结算页、HUD 节奏和 art-pass 组织方式。
- `godot-docs-stable/classes/class_node3d.rst`
  - 参考原因：核对 3D 节点变换、层级和资源挂接方式。
- `godot-docs-stable/getting_started/first_3d_game/`
  - 参考原因：复查 Godot 官方对于 3D 原型项目组织、节点和脚本职责的推荐写法。
- `https://www.youtube.com/watch?v=IvXmbU-GYkI`
  - 参考原因：作为正式《天天飞车》实机视频记录，用来对照原作的高速镜头语言、车流密度、险超节奏和界面反馈。
- `https://quaternius.com/packs/cars.html`
  - 参考原因：提供玩家跑车与普通交通车的 CC0 低多边形模型资源。
- `https://quaternius.com/packs/publictransport.html`
  - 参考原因：提供救护车、巴士、校车等更大轮廓的 CC0 载具资源。
- `https://quaternius.com/packs/modularstreets.html`
  - 参考原因：提供路灯、交通灯、路牌等赛道两侧装饰资源。

额外说明：

- 当前实现没有复用腾讯《天天飞车》的任何素材、音频、字体或界面资源。
- 玩法灵感仅体现在“高速闪避、险超连击、大车保命、车辆成长”的高层循环抽象上。
- 第三方资源授权与项目内的实际接入文件见 `CREDITS.md`。
