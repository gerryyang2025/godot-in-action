extends Node3D

const BEACON_SCENE = preload("res://scenes/beacon.tscn")
const DRONE_SCENE = preload("res://scenes/drone.tscn")

const PLAYER_START = Vector3(0.0, 1.1, 9.6)
const CAMERA_OFFSET = Vector3(0.0, 11.2, 16.0)
const CAMERA_LOOK_OFFSET = Vector3(0.0, 1.0, -2.2)
const TARGET_BEACONS = 8
const STARTING_SHIELDS = 3
const STARTING_TIME = 90
const PLAYER_INVULNERABILITY = 1.2
const FLASH_FADE_SPEED = 1.8
const SCRAMBLE_COOLDOWN = 8.0
const SCRAMBLE_RADIUS = 12.5
const SCRAMBLE_DISABLE_DURATION = 2.8
const FIRST_REINFORCEMENT_BEACON_THRESHOLD = 4
const SECOND_REINFORCEMENT_BEACON_THRESHOLD = 6
const HUD_SCORE_COLOR = Color(0.576471, 1.0, 0.847059, 1)
const HUD_SCORE_DONE_COLOR = Color(0.823529, 1.0, 0.901961, 1)
const HUD_SHIELD_COLOR = Color(1.0, 0.760784, 0.486275, 1)
const HUD_SHIELD_DANGER_COLOR = Color(1.0, 0.384314, 0.384314, 1)
const HUD_TIME_COLOR = Color(0.862745, 0.929412, 1.0, 1)
const HUD_TIME_WARNING_COLOR = Color(1.0, 0.478431, 0.419608, 1)
const HUD_PATROL_COLOR = Color(1.0, 0.698039, 0.415686, 1)
const HUD_SCRAMBLE_READY_COLOR = Color(0.509804, 0.913725, 1.0, 1)
const HUD_SCRAMBLE_COOLDOWN_COLOR = Color(0.537255, 0.721569, 0.835294, 1)

const OPENING_DRONE_PATROLS = [
	{
		"point_a": Vector3(-13.5, 1.0, -2.2),
		"point_b": Vector3(13.5, 1.0, -2.2),
		"speed": 4.8,
		"behavior": {
			"can_chase": true,
			"detection_radius": 6.7,
			"chase_speed_multiplier": 1.5,
			"chase_lock_time": 2.0,
			"chase_forget_distance": 10.8
		}
	},
	{
		"point_a": Vector3(10.8, 1.0, -10.0),
		"point_b": Vector3(-10.2, 1.0, 8.4),
		"speed": 3.6,
		"behavior": {
			"can_chase": true,
			"detection_radius": 6.0,
			"chase_speed_multiplier": 1.48,
			"chase_lock_time": 2.1,
			"chase_forget_distance": 10.2
		}
	},
	{
		"point_a": Vector3(-13.0, 1.0, 10.0),
		"point_b": Vector3(-13.0, 1.0, -9.6),
		"speed": 3.1,
		"behavior": {
			"can_chase": true,
			"detection_radius": 5.0,
			"chase_speed_multiplier": 1.38,
			"chase_lock_time": 1.7,
			"chase_forget_distance": 8.8
		}
	},
	{
		"point_a": Vector3(8.8, 1.0, 8.2),
		"point_b": Vector3(8.8, 1.0, -8.6),
		"speed": 3.5,
		"behavior": {
			"can_chase": true,
			"detection_radius": 5.2,
			"chase_speed_multiplier": 1.42,
			"chase_lock_time": 1.8,
			"chase_forget_distance": 9.0
		}
	},
	{
		"point_a": Vector3(-14.2, 1.0, 11.4),
		"point_b": Vector3(14.2, 1.0, 11.4),
		"speed": 3.8,
		"behavior": {
			"can_chase": false
		}
	},
]

const FIRST_REINFORCEMENT_DRONE_PATROLS = [
	{
		"point_a": Vector3(14.4, 1.0, -10.5),
		"point_b": Vector3(14.4, 1.0, 10.5),
		"speed": 3.9,
		"behavior": {
			"can_chase": true,
			"detection_radius": 5.6,
			"chase_speed_multiplier": 1.45,
			"chase_lock_time": 1.9,
			"chase_forget_distance": 9.4
		}
	},
	{
		"point_a": Vector3(-12.0, 1.0, -11.6),
		"point_b": Vector3(12.0, 1.0, -11.6),
		"speed": 4.1,
		"behavior": {
			"can_chase": false
		}
	},
]

const SECOND_REINFORCEMENT_DRONE_PATROLS = [
	{
		"point_a": Vector3(-14.0, 1.0, 10.6),
		"point_b": Vector3(14.0, 1.0, -10.2),
		"speed": 4.2,
		"behavior": {
			"can_chase": true,
			"detection_radius": 6.4,
			"chase_speed_multiplier": 1.56,
			"chase_lock_time": 2.2,
			"chase_forget_distance": 11.2
		}
	},
]

const BEACON_POINTS = [
	Vector3(-13.0, 1.0, 8.8),
	Vector3(12.4, 1.0, 9.0),
	Vector3(-12.5, 1.0, -1.6),
	Vector3(-4.6, 1.0, -7.8),
	Vector3(3.8, 1.0, 1.6),
	Vector3(12.2, 1.0, -8.8),
	Vector3(-1.8, 1.0, 10.8),
	Vector3(6.8, 1.0, -11.2),
]

enum GameState {
	READY,
	PLAYING,
	WON,
	LOST,
}

enum FinishReason {
	NONE,
	SUCCESS,
	SHIELDS,
	TIME,
	FELL,
}

var _state := GameState.READY
var _finish_reason := FinishReason.NONE
var _signals_collected := 0
var _shields := STARTING_SHIELDS
var _remaining_time := STARTING_TIME
var _flash_alpha := 0.0
var _first_reinforcement_deployed := false
var _second_reinforcement_deployed := false
var _scramble_cooldown_remaining := 0.0

@onready var _player = $Player
@onready var _audio = $AudioRoot
@onready var _camera: Camera3D = $Camera3D
@onready var _game_tick_timer: Timer = $GameTickTimer
@onready var _score_label: Label = $CanvasLayer/TopContent/TopStack/StatsRow/ScoreLabel
@onready var _shield_label: Label = $CanvasLayer/TopContent/TopStack/StatsRow/ShieldLabel
@onready var _time_label: Label = $CanvasLayer/TopContent/TopStack/StatsRow/TimeLabel
@onready var _scramble_label: Label = $CanvasLayer/TopContent/TopStack/StatsRow/ScrambleLabel
@onready var _message_label: Label = $CanvasLayer/MessageLabel
@onready var _start_screen: Control = $CanvasLayer/StartScreen
@onready var _end_screen: Control = $CanvasLayer/EndScreen
@onready var _end_screen_shade: ColorRect = $CanvasLayer/EndScreen/Shade
@onready var _result_tag_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultTagLabel
@onready var _result_title_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultTitleLabel
@onready var _result_summary_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultSummaryLabel
@onready var _result_divider: ColorRect = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultDivider
@onready var _result_stats_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultStatsLabel
@onready var _result_prompt_label: Label = $CanvasLayer/EndScreen/Padding/Center/Panel/Content/ResultPromptLabel
@onready var _screen_flash: ColorRect = $CanvasLayer/ScreenFlash


func _ready() -> void:
	_player.fell_out.connect(_on_player_fell_out)
	_game_tick_timer.timeout.connect(_on_game_tick_timer_timeout)
	_screen_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	_show_ready_screen()


func _process(delta: float) -> void:
	_update_camera(delta)
	_update_screen_flash(delta)
	_update_scramble_cooldown(delta)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"start_game") and _state != GameState.PLAYING:
		new_game()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed(&"scramble_pulse") and _state == GameState.PLAYING:
		_use_scramble_pulse()
		get_viewport().set_input_as_handled()


func new_game() -> void:
	_state = GameState.PLAYING
	_finish_reason = FinishReason.NONE
	_signals_collected = 0
	_shields = STARTING_SHIELDS
	_remaining_time = STARTING_TIME
	_first_reinforcement_deployed = false
	_second_reinforcement_deployed = false
	_scramble_cooldown_remaining = 0.0

	_clear_group(&"beacons")
	_clear_group(&"drones")
	_hide_start_screen()
	_hide_end_screen()

	_audio.play_deploy_confirm()
	_audio.play_gameplay_music()
	_player.start(PLAYER_START)
	_spawn_all_beacons()
	_spawn_drone_patrols(OPENING_DRONE_PATROLS)

	_game_tick_timer.start()
	_message_label.text = "Collect 8 beacons. Break line of sight behind cover, or press Q to fire a scramble pulse."
	_update_hud()


func _show_ready_screen() -> void:
	_state = GameState.READY
	_finish_reason = FinishReason.NONE
	_player.set_active(false)
	_clear_group(&"beacons")
	_clear_group(&"drones")
	_game_tick_timer.stop()
	_scramble_cooldown_remaining = 0.0
	_show_start_screen()
	_hide_end_screen()
	_audio.play_briefing_music()
	_message_label.text = "Mission briefing loaded. Press Space or Enter to deploy."
	_update_hud()


func _spawn_all_beacons() -> void:
	for beacon_position in BEACON_POINTS:
		var beacon = BEACON_SCENE.instantiate()
		beacon.global_position = beacon_position
		beacon.collected.connect(_on_beacon_collected)
		add_child(beacon)


func _spawn_drone(point_a: Vector3, point_b: Vector3, speed: float, behavior: Dictionary = {}) -> void:
	var drone = DRONE_SCENE.instantiate()
	drone.player_hit.connect(_on_drone_player_hit)
	add_child(drone)
	drone.configure(point_a, point_b, speed, behavior)


func _spawn_drone_patrols(patrols: Array) -> void:
	for patrol in patrols:
		_spawn_drone(patrol["point_a"], patrol["point_b"], patrol["speed"], patrol.get("behavior", {}))


func _deploy_reinforcement_if_needed() -> String:
	if not _first_reinforcement_deployed and _signals_collected >= FIRST_REINFORCEMENT_BEACON_THRESHOLD:
		_first_reinforcement_deployed = true
		_spawn_drone_patrols(FIRST_REINFORCEMENT_DRONE_PATROLS)
		return "East and north lanes just went hot. Hunter patrols are locking routes."

	if not _second_reinforcement_deployed and _signals_collected >= SECOND_REINFORCEMENT_BEACON_THRESHOLD:
		_second_reinforcement_deployed = true
		_spawn_drone_patrols(SECOND_REINFORCEMENT_DRONE_PATROLS)
		return "Final hunter unit entered on a diagonal sweep. Break line and keep moving."

	return ""


func _use_scramble_pulse() -> void:
	if _scramble_cooldown_remaining > 0.0:
		_audio.play_scramble_denied()
		_message_label.text = "Scramble pulse recharging. Break line of sight behind pillars or blockers."
		return

	var disrupted_count := 0
	for drone in get_tree().get_nodes_in_group(&"drones"):
		if drone.global_position.distance_to(_player.global_position) > SCRAMBLE_RADIUS:
			continue
		if drone.has_method("force_break_chase"):
			drone.force_break_chase(SCRAMBLE_DISABLE_DURATION)
			disrupted_count += 1

	_scramble_cooldown_remaining = SCRAMBLE_COOLDOWN
	_audio.play_scramble_fire()
	_player.play_scramble_pulse()
	_message_label.text = "Scramble pulse fired. Nearby hunters lost lock." if disrupted_count > 0 else "Scramble pulse fired. No hunter was close enough to lock on."
	_flash_screen(Color(0.509804, 0.913725, 1.0, 1), 0.22)
	_update_hud()


func _on_beacon_collected(beacon: Area3D) -> void:
	if _state != GameState.PLAYING:
		return

	_signals_collected += 1
	_audio.play_beacon_collect(float(_signals_collected) / float(TARGET_BEACONS))
	beacon.queue_free()

	if _signals_collected >= TARGET_BEACONS:
		_finish_game(FinishReason.SUCCESS)
	else:
		var reinforcement_message := _deploy_reinforcement_if_needed()
		if not reinforcement_message.is_empty():
			_audio.play_reinforcement_alert()
		_message_label.text = reinforcement_message if not reinforcement_message.is_empty() else "Beacon synced. Keep running."
		_flash_screen(HUD_PATROL_COLOR if not reinforcement_message.is_empty() else Color(0.337255, 1.0, 0.568627, 1), 0.22 if not reinforcement_message.is_empty() else 0.18)
		_update_hud()


func _on_drone_player_hit() -> void:
	if _state != GameState.PLAYING or _player.is_invulnerable():
		return

	_shields -= 1
	_player.start_invulnerability(PLAYER_INVULNERABILITY)
	_audio.play_player_hit()

	if _shields <= 0:
		_finish_game(FinishReason.SHIELDS)
	else:
		_message_label.text = "Drone contact! Shields flickering."
		_flash_screen(Color(1.0, 0.290196, 0.360784, 1), 0.24)
		_update_hud()


func _on_player_fell_out() -> void:
	if _state == GameState.PLAYING:
		_message_label.text = "You fell below the training platform."
		_finish_game(FinishReason.FELL)


func _on_game_tick_timer_timeout() -> void:
	if _state != GameState.PLAYING:
		return

	_remaining_time -= 1
	if _remaining_time <= 0:
		_finish_game(FinishReason.TIME)
	else:
		_audio.play_countdown_warning(_remaining_time)
		_update_hud()


func _finish_game(finish_reason: int) -> void:
	_finish_reason = finish_reason
	var player_won := finish_reason == FinishReason.SUCCESS
	_state = GameState.WON if player_won else GameState.LOST
	_game_tick_timer.stop()
	_player.set_active(false)

	for drone in get_tree().get_nodes_in_group(&"drones"):
		drone.set_physics_process(false)

	_audio.play_result(player_won)
	_message_label.text = "Route complete. Review the report and press Space to replay." if player_won else "Training failed. Review the report and press Space to retry."
	_flash_screen(Color(0.337255, 1.0, 0.568627, 1) if player_won else Color(1.0, 0.290196, 0.360784, 1), 0.32)
	_show_end_screen()
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
	_scramble_label.text = "Pulse: READY" if _scramble_cooldown_remaining <= 0.0 else "Pulse: %.1fs" % _scramble_cooldown_remaining

	var progress := float(_signals_collected) / float(TARGET_BEACONS)
	_score_label.modulate = HUD_SCORE_COLOR.lerp(HUD_SCORE_DONE_COLOR, progress)
	_shield_label.modulate = HUD_SHIELD_DANGER_COLOR if _state == GameState.PLAYING and _shields <= 1 else HUD_SHIELD_COLOR
	_time_label.modulate = HUD_TIME_WARNING_COLOR if _state == GameState.PLAYING and _remaining_time <= 10 else HUD_TIME_COLOR
	_scramble_label.modulate = HUD_SCRAMBLE_READY_COLOR if _scramble_cooldown_remaining <= 0.0 else HUD_SCRAMBLE_COOLDOWN_COLOR


func _show_end_screen() -> void:
	_hide_start_screen()
	var accent_color := HUD_SCORE_DONE_COLOR if _finish_reason == FinishReason.SUCCESS else HUD_SHIELD_DANGER_COLOR
	var report_tag := "MISSION SUCCESS" if _finish_reason == FinishReason.SUCCESS else "MISSION FAILED"
	var report_title := ""
	var report_summary := ""
	var report_status := ""

	match _finish_reason:
		FinishReason.SUCCESS:
			report_title = "ROUTE COMPLETE"
			report_summary = "All beacons were synced before the patrol net could close around the platform."
			report_status = "Status: Training route secured."
		FinishReason.SHIELDS:
			report_title = "SHIELDS COLLAPSED"
			report_summary = "Sustained drone pressure broke the suit before the sweep could be finished."
			report_status = "Failure cause: Shield reserve exhausted."
		FinishReason.TIME:
			report_title = "WINDOW CLOSED"
			report_summary = "The uplink timer expired before the remaining beacon signals could be secured."
			report_status = "Failure cause: Countdown expired."
		FinishReason.FELL:
			report_title = "PLATFORM LOST"
			report_summary = "The route was interrupted after you dropped below the training deck."
			report_status = "Failure cause: Fell off the arena."
		_:
			report_title = "RUN ENDED"
			report_summary = "The exercise has concluded."
			report_status = "Status: Awaiting redeploy."

	var report_lines := PackedStringArray([
		"Beacons synced: %d/%d" % [_signals_collected, TARGET_BEACONS],
		"Shields remaining: %d" % max(0, _shields),
		"Time remaining: %ds" % max(0, _remaining_time),
		report_status,
	])

	_result_tag_label.text = report_tag
	_result_title_label.text = report_title
	_result_summary_label.text = report_summary
	_result_stats_label.text = "\n".join(report_lines)
	_result_prompt_label.text = "Press Space or Enter to redeploy."

	_result_tag_label.modulate = accent_color
	_result_title_label.modulate = accent_color
	_result_divider.color = accent_color
	_end_screen_shade.color = Color(accent_color.r * 0.12, accent_color.g * 0.12, accent_color.b * 0.16, 0.64)
	_end_screen.visible = true
	_message_label.visible = false


func _show_start_screen() -> void:
	_start_screen.visible = true
	_message_label.visible = false


func _hide_start_screen() -> void:
	_start_screen.visible = false
	if not _end_screen.visible:
		_message_label.visible = true


func _hide_end_screen() -> void:
	_end_screen.visible = false
	if not _start_screen.visible:
		_message_label.visible = true


func _update_scramble_cooldown(delta: float) -> void:
	if _scramble_cooldown_remaining <= 0.0:
		return

	_scramble_cooldown_remaining = maxf(0.0, _scramble_cooldown_remaining - delta)
	_update_hud()


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
