extends Node3D

const BEACON_SCENE = preload("res://scenes/beacon.tscn")
const DRONE_SCENE = preload("res://scenes/drone.tscn")

const PLAYER_START = Vector3(0.0, 1.1, 5.8)
const CAMERA_OFFSET = Vector3(0.0, 9.0, 12.0)
const CAMERA_LOOK_OFFSET = Vector3(0.0, 1.0, -1.5)
const TARGET_BEACONS = 5
const STARTING_SHIELDS = 3
const STARTING_TIME = 60
const PLAYER_INVULNERABILITY = 1.2
const FLASH_FADE_SPEED = 1.8
const HUD_SCORE_COLOR = Color(0.576471, 1.0, 0.847059, 1)
const HUD_SCORE_DONE_COLOR = Color(0.823529, 1.0, 0.901961, 1)
const HUD_SHIELD_COLOR = Color(1.0, 0.760784, 0.486275, 1)
const HUD_SHIELD_DANGER_COLOR = Color(1.0, 0.384314, 0.384314, 1)
const HUD_TIME_COLOR = Color(0.862745, 0.929412, 1.0, 1)
const HUD_TIME_WARNING_COLOR = Color(1.0, 0.478431, 0.419608, 1)

const BEACON_POINTS = [
	Vector3(-8.0, 1.0, 3.4),
	Vector3(7.4, 1.0, 3.8),
	Vector3(-6.2, 1.0, -5.2),
	Vector3(0.0, 1.0, -6.8),
	Vector3(7.2, 1.0, -4.5),
]

enum GameState {
	READY,
	PLAYING,
	WON,
	LOST,
}

var _state := GameState.READY
var _signals_collected := 0
var _shields := STARTING_SHIELDS
var _remaining_time := STARTING_TIME
var _flash_alpha := 0.0

@onready var _player = $Player
@onready var _camera: Camera3D = $Camera3D
@onready var _game_tick_timer: Timer = $GameTickTimer
@onready var _score_label: Label = $CanvasLayer/ScoreLabel
@onready var _shield_label: Label = $CanvasLayer/ShieldLabel
@onready var _time_label: Label = $CanvasLayer/TimeLabel
@onready var _message_label: Label = $CanvasLayer/MessageLabel
@onready var _screen_flash: ColorRect = $CanvasLayer/ScreenFlash


func _ready() -> void:
	_player.fell_out.connect(_on_player_fell_out)
	_game_tick_timer.timeout.connect(_on_game_tick_timer_timeout)
	_screen_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	_show_ready_screen()


func _process(delta: float) -> void:
	_update_camera(delta)
	_update_screen_flash(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"start_game") and _state != GameState.PLAYING:
		new_game()
		get_viewport().set_input_as_handled()


func new_game() -> void:
	_state = GameState.PLAYING
	_signals_collected = 0
	_shields = STARTING_SHIELDS
	_remaining_time = STARTING_TIME

	_clear_group(&"beacons")
	_clear_group(&"drones")

	_player.start(PLAYER_START)
	_spawn_all_beacons()
	_spawn_drone(Vector3(-9.0, 1.0, -1.5), Vector3(9.0, 1.0, -1.5), 4.6)
	_spawn_drone(Vector3(6.0, 1.0, -7.0), Vector3(-6.0, 1.0, 5.0), 3.5)

	_game_tick_timer.start()
	_message_label.text = "Collect 5 glowing beacons. Avoid patrol drones."
	_update_hud()


func _show_ready_screen() -> void:
	_state = GameState.READY
	_player.set_active(false)
	_clear_group(&"beacons")
	_clear_group(&"drones")
	_game_tick_timer.stop()
	_message_label.text = "Press Space or Enter to start. WASD/Arrows move, Space jumps."
	_update_hud()


func _spawn_all_beacons() -> void:
	for beacon_position in BEACON_POINTS:
		var beacon = BEACON_SCENE.instantiate()
		beacon.global_position = beacon_position
		beacon.collected.connect(_on_beacon_collected)
		add_child(beacon)


func _spawn_drone(point_a: Vector3, point_b: Vector3, speed: float) -> void:
	var drone = DRONE_SCENE.instantiate()
	drone.player_hit.connect(_on_drone_player_hit)
	add_child(drone)
	drone.configure(point_a, point_b, speed)


func _on_beacon_collected(beacon: Area3D) -> void:
	if _state != GameState.PLAYING:
		return

	_signals_collected += 1
	beacon.queue_free()

	if _signals_collected >= TARGET_BEACONS:
		_finish_game(true)
	else:
		_message_label.text = "Beacon synced. Keep running."
		_flash_screen(Color(0.337255, 1.0, 0.568627, 1), 0.18)
		_update_hud()


func _on_drone_player_hit() -> void:
	if _state != GameState.PLAYING or _player.is_invulnerable():
		return

	_shields -= 1
	_player.start_invulnerability(PLAYER_INVULNERABILITY)

	if _shields <= 0:
		_finish_game(false)
	else:
		_message_label.text = "Drone contact! Shields flickering."
		_flash_screen(Color(1.0, 0.290196, 0.360784, 1), 0.24)
		_update_hud()


func _on_player_fell_out() -> void:
	if _state == GameState.PLAYING:
		_message_label.text = "You fell below the training platform."
		_finish_game(false)


func _on_game_tick_timer_timeout() -> void:
	if _state != GameState.PLAYING:
		return

	_remaining_time -= 1
	if _remaining_time <= 0:
		_finish_game(false)
	else:
		_update_hud()


func _finish_game(player_won: bool) -> void:
	_state = GameState.WON if player_won else GameState.LOST
	_game_tick_timer.stop()
	_player.set_active(false)

	for drone in get_tree().get_nodes_in_group(&"drones"):
		drone.set_physics_process(false)

	_message_label.text = "Route complete! Press Space to replay." if player_won else "Training failed. Press Space to retry."
	_flash_screen(Color(0.337255, 1.0, 0.568627, 1) if player_won else Color(1.0, 0.290196, 0.360784, 1), 0.32)
	_update_hud()


func _update_camera(delta: float) -> void:
	var target_position := PLAYER_START
	if _player.visible:
		target_position = _player.global_position

	var desired_camera_position := target_position + CAMERA_OFFSET
	_camera.global_position = _camera.global_position.lerp(desired_camera_position, minf(1.0, 5.0 * delta))
	_camera.look_at(target_position + CAMERA_LOOK_OFFSET, Vector3.UP)


func _update_hud() -> void:
	_score_label.text = "Beacons: %d/%d" % [_signals_collected, TARGET_BEACONS]
	_shield_label.text = "Shields: %d" % _shields
	_time_label.text = "Time: %d" % max(0, _remaining_time)

	var progress := float(_signals_collected) / float(TARGET_BEACONS)
	_score_label.modulate = HUD_SCORE_COLOR.lerp(HUD_SCORE_DONE_COLOR, progress)
	_shield_label.modulate = HUD_SHIELD_DANGER_COLOR if _state == GameState.PLAYING and _shields <= 1 else HUD_SHIELD_COLOR
	_time_label.modulate = HUD_TIME_WARNING_COLOR if _state == GameState.PLAYING and _remaining_time <= 10 else HUD_TIME_COLOR


func _clear_group(group_name: StringName) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		node.queue_free()


func _flash_screen(color: Color, alpha: float) -> void:
	_flash_alpha = maxf(_flash_alpha, alpha)
	color.a = _flash_alpha
	_screen_flash.color = color


func _update_screen_flash(delta: float) -> void:
	if _flash_alpha <= 0.0:
		return

	_flash_alpha = maxf(0.0, _flash_alpha - FLASH_FADE_SPEED * delta)
	var flash_color := _screen_flash.color
	flash_color.a = _flash_alpha
	_screen_flash.color = flash_color
