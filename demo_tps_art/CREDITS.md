# Tactical Proxy Strike Art Credits

`demo_tps_art/` 复用了 `reference/tps-demo/` 的一批美术、音频和特效资源，并复制到当前项目内使用。

## 复用内容

- UI 与音频
  - `assets/ui/crosshair.png`
  - `assets/music/level_music.ogg`
  - `assets/audio/player/jump.wav`
  - `assets/audio/player/land.wav`
  - `assets/audio/player/shoot.wav`
  - `assets/audio/player/step.wav`
  - `assets/audio/enemy/charge.wav`
  - `assets/audio/enemy/shoot.wav`
  - `assets/audio/enemy/hit.wav`
  - `assets/audio/enemy/explosion.wav`

- 玩家资源
  - `assets/reference/player/model/player.glb`
  - `assets/reference/player/textures/player_robot_albedo.png`
  - `assets/reference/player/textures/player_robot_emissive.png`
  - `assets/reference/player/textures/player_robot_normal.png`
  - `assets/reference/player/textures/player_robot_orm.png`

- 敌人参考资源
  - `assets/reference/enemies/red_robot/model/red_robot.dae`
  - `assets/reference/enemies/red_robot/textures/red_robot_albedo.png`
  - `assets/reference/enemies/red_robot/textures/red_robot_emission.png`
  - `assets/reference/enemies/red_robot/textures/red_robot_normal.png`
  - `assets/reference/enemies/red_robot/textures/red_robot_orm.png`
  - `assets/reference/enemies/red_robot/textures/explosion.png`
  - `assets/reference/enemies/red_robot/textures/particle.png`
  - `assets/reference/enemies/red_robot/textures/ray_smoke_texture.png`
  - `assets/reference/enemies/red_robot/textures/ray_texture.png`
  - 上述资源当前主要保留为美术参考、兼容性别名来源和后续对比素材，运行时敌人已切换到 `player.glb` 人形基底。

- 场景与环境资源
  - `assets/reference/door/model/door.dae`
  - `assets/reference/door/textures/door_albedo.png`
  - `assets/reference/door/textures/door_emission.png`
  - `assets/reference/door/textures/door_normal.png`
  - `assets/reference/door/textures/door_orm.png`
  - `assets/reference/level/textures/structure/tile_scifi_floor_panel_*.png`
  - `assets/reference/level/textures/structure/tile_default_metal_*.png`
  - `assets/reference/level/textures/structure/tile_tech_panels_color_*.png`
  - `assets/reference/level/textures/structure/trim_emission_lights_*.png`

- 特效资源
  - `assets/reference/player/effects/FlarePolar.png`
  - `assets/reference/player/effects/FlareStraight.png`
  - `assets/reference/effects_shared/BlastMesh.glb`
  - `assets/reference/effects_shared/BlastTexture.png`

## 兼容性补充

- 为了让旧的 `red_robot.dae` 与 `door.dae` 在 Godot `4.6.2` 下按原有相对路径完成贴图解析，当前项目额外生成了以下同源贴图别名：
  - `assets/reference/enemies/red_robot/model/EvilRobo-BaseColor.png`
  - `assets/reference/enemies/red_robot/model/EvilRobo-Normal.png`
  - `assets/reference/door/model/doorsimple_d.png`
- 这些文件只是对已复制贴图的路径兼容副本，不代表新增授权来源。

## 原始授权

依据 `reference/tps-demo/LICENSE.md`：

- 资源与音乐版权归原作者所有，按 `CC-BY 3.0` 分发
- 代码部分按 `MIT` 分发

## 署名

- Assets: Juan Linietsky, Fernando Miguel Calabró
- Music: Christian Fernando Perucchi
- Original demo/code: Godot Engine contributors
