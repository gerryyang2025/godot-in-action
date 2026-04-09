extends Node2D

const BEACON_SCENE = preload("res://scenes/beacon.tscn")
const DRONE_SCENE = preload("res://scenes/drone.tscn")

const ARENA_RECT = Rect2(Vector2(64.0, 112.0), Vector2(832.0, 464.0))
const PLAYER_START = Vector2(480.0, 344.0)
const TARGET_BEACONS = 8
const STARTING_SHIELDS = 3
const STARTING_TIME = 45
const PLAYER_INVULNERABILITY = 1.2

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
var _current_beacon: Area2D
var _drone_spawn_count := 0

@onready var _player = $Player
@onready var _drone_spawn_timer: Timer = $DroneSpawnTimer
@onready var _game_tick_timer: Timer = $GameTickTimer
@onready var _score_label: Label = $CanvasLayer/ScoreLabel
@onready var _shield_label: Label = $CanvasLayer/ShieldLabel
@onready var _time_label: Label = $CanvasLayer/TimeLabel
@onready var _message_label: Label = $CanvasLayer/MessageLabel


func _ready() -> void:
	randomize()
	_player.arena_rect = ARENA_RECT
	_player.beacon_collected.connect(_on_player_beacon_collected)
	_player.drone_hit.connect(_on_player_drone_hit)
	_drone_spawn_timer.timeout.connect(_on_drone_spawn_timer_timeout)
	_game_tick_timer.timeout.connect(_on_game_tick_timer_timeout)
	_show_ready_screen()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"start_game") and _state != GameState.PLAYING:
		new_game()
		get_viewport().set_input_as_handled()


func new_game() -> void:
	_state = GameState.PLAYING
	_signals_collected = 0
	_shields = STARTING_SHIELDS
	_remaining_time = STARTING_TIME
	_drone_spawn_count = 0

	_clear_group(&"drones")
	_clear_group(&"beacons")

	_player.start(PLAYER_START)
	_spawn_beacon()
	_spawn_drone()

	_drone_spawn_timer.wait_time = 2.0
	_drone_spawn_timer.start()
	_game_tick_timer.start()

	_message_label.text = "Collect green signals. Avoid red patrol drones."
	_update_hud()


func _show_ready_screen() -> void:
	_state = GameState.READY
	_player.set_active(false)
	_message_label.text = "Press Space or Enter to start"
	_update_hud()


func _spawn_beacon() -> void:
	if is_instance_valid(_current_beacon):
		_current_beacon.queue_free()

	_current_beacon = BEACON_SCENE.instantiate()
	_current_beacon.position = _find_spawn_position(140.0)
	add_child(_current_beacon)


func _spawn_drone() -> void:
	var drone = DRONE_SCENE.instantiate()
	var speed := randf_range(150.0, 240.0) + float(_drone_spawn_count) * 8.0
	var start_position := _random_perimeter_position()

	drone.configure(start_position, _player.position, speed, ARENA_RECT)
	add_child(drone)

	_drone_spawn_count += 1
	_drone_spawn_timer.wait_time = maxf(0.75, 2.0 - float(_drone_spawn_count) * 0.08)


func _find_spawn_position(minimum_distance_from_player: float) -> Vector2:
	for _attempt in 16:
		var candidate := _random_arena_position()
		if candidate.distance_to(_player.position) >= minimum_distance_from_player:
			return candidate

	return _random_arena_position()


func _random_arena_position() -> Vector2:
	return Vector2(
		randf_range(ARENA_RECT.position.x, ARENA_RECT.end.x),
		randf_range(ARENA_RECT.position.y, ARENA_RECT.end.y)
	)


func _random_perimeter_position() -> Vector2:
	var side := randi_range(0, 3)
	match side:
		0:
			return Vector2(randf_range(ARENA_RECT.position.x, ARENA_RECT.end.x), ARENA_RECT.position.y)
		1:
			return Vector2(ARENA_RECT.end.x, randf_range(ARENA_RECT.position.y, ARENA_RECT.end.y))
		2:
			return Vector2(randf_range(ARENA_RECT.position.x, ARENA_RECT.end.x), ARENA_RECT.end.y)
		_:
			return Vector2(ARENA_RECT.position.x, randf_range(ARENA_RECT.position.y, ARENA_RECT.end.y))


func _on_player_beacon_collected(beacon: Area2D) -> void:
	if _state != GameState.PLAYING:
		return

	_signals_collected += 1
	beacon.queue_free()
	if beacon == _current_beacon:
		_current_beacon = null

	if _signals_collected >= TARGET_BEACONS:
		_finish_game(true)
	else:
		_spawn_beacon()
		_update_hud()


func _on_player_drone_hit() -> void:
	if _state != GameState.PLAYING:
		return

	_shields -= 1
	_player.start_invulnerability(PLAYER_INVULNERABILITY)

	if _shields <= 0:
		_finish_game(false)
	else:
		_message_label.text = "Shield hit! Keep moving."
		_update_hud()


func _on_drone_spawn_timer_timeout() -> void:
	if _state == GameState.PLAYING:
		_spawn_drone()


func _on_game_tick_timer_timeout() -> void:
	if _state != GameState.PLAYING:
		return

	_remaining_time -= 1
	if _remaining_time <= 0:
		_finish_game(_signals_collected >= TARGET_BEACONS)
	else:
		_update_hud()


func _finish_game(player_won: bool) -> void:
	_state = GameState.WON if player_won else GameState.LOST
	_drone_spawn_timer.stop()
	_game_tick_timer.stop()
	_player.set_active(false)

	if is_instance_valid(_current_beacon):
		_current_beacon.queue_free()

	_message_label.text = "Training complete! Press Space to replay." if player_won else "Signal lost. Press Space to retry."
	_update_hud()


func _update_hud() -> void:
	_score_label.text = "Signals: %d/%d" % [_signals_collected, TARGET_BEACONS]
	_shield_label.text = "Shields: %d" % _shields
	_time_label.text = "Time: %d" % max(0, _remaining_time)


func _clear_group(group_name: StringName) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		node.queue_free()
