# Infinite Racer Credits

`demo_racing/` 当前主要使用 Quaternius 的 CC0 低多边形车辆与道路装饰资源，并在项目内重新组织为适合高速闪避玩法的轻量视觉场景。

## 第三方模型资源

### Quaternius Cars Pack

来源页：

- `https://quaternius.com/packs/cars.html`

当前接入文件：

- `assets/third_party/quaternius/cars/SportsCar.obj`
- `assets/third_party/quaternius/cars/NormalCar1.obj`
- `assets/third_party/quaternius/cars/NormalCar2.obj`
- `assets/third_party/quaternius/cars/Taxi.obj`
- `assets/third_party/quaternius/cars/Cop.obj`
- `assets/third_party/quaternius/cars/SUV.obj`
- `assets/third_party/quaternius/cars/License.txt`

当前用途：

- `SportsCar.obj`：玩家车视觉基底。
- `NormalCar1.obj` / `NormalCar2.obj`：普通交通轿车变体。
- `Taxi.obj` / `Cop.obj`：高识别度街机交通车变体。
- `SUV.obj`：服务车辆基础轮廓。

### Quaternius Public Transport Pack

来源页：

- `https://quaternius.com/packs/publictransport.html`

当前接入文件：

- `assets/third_party/quaternius/public_transport/Ambulance.obj`
- `assets/third_party/quaternius/public_transport/Bus.obj`
- `assets/third_party/quaternius/public_transport/SchoolBus.obj`

当前用途：

- `Ambulance.obj`：重型服务车辆变体。
- `Bus.obj` / `SchoolBus.obj`：可劫持大型车辆轮廓。

### Quaternius Modular Streets Pack

来源页：

- `https://quaternius.com/packs/modularstreets.html`

当前接入文件：

- `assets/third_party/quaternius/modular_streets/Streetlight_Double.obj`
- `assets/third_party/quaternius/modular_streets/TrafficLight.obj`
- `assets/third_party/quaternius/modular_streets/Sign_Stop.obj`
- `assets/third_party/quaternius/modular_streets/Sign_Triangle.obj`
- `assets/third_party/quaternius/modular_streets/License.txt`

当前用途：

- 双头路灯、交通信号灯与路牌，用于替换赛道两侧的纯盒体装饰。

## 自生成音频

以下音频由当前项目内脚本 `tools/generate_audio.py` 本地程序化生成，不依赖外部素材包：

- `assets/audio/music/highway_night_drive.wav`
- `assets/audio/gameplay/engine_loop.wav`
- `assets/audio/gameplay/jump.wav`
- `assets/audio/gameplay/near_miss.wav`
- `assets/audio/gameplay/hijack.wav`
- `assets/audio/ui/start_run.wav`
- `assets/audio/ui/upgrade.wav`
- `assets/audio/ui/promote.wav`
- `assets/audio/ui/crash.wav`
- `assets/audio/ui/fuel_empty.wav`

## 修改方式

- 当前项目没有直接复用外部完整车辆场景，只接入了模型资源，并在 `demo_racing/` 内重新组织节点、灯条、劫持标记和玩法判定。
- 当前视觉目标不是写实模拟，而是“真实轮廓 + 街机读图清晰度”：先让玩家一眼分清轿车、服务车和大车，再去叠加配色与发光反馈。

## 授权说明

- Quaternius 资源包页面标注为 `CC0`。
- 项目内保留了 `Cars Pack` 与 `Modular Streets Pack` 的原始 `License.txt`。
- 本项目对第三方模型仅做导入、缩放、组合与玩法语义层面的重新组织，没有把它们重新声明为自有资源。

## 额外说明

- `assets/vehicles/` 下仍保留一批早期尝试时复制的旧车辆资源，当前场景不再直接引用它们。
