extends Node2D

const BEACON_SCENE = preload("res://scenes/beacon.tscn")
const DRONE_SCENE = preload("res://scenes/drone.tscn")

const ARENA_RECT = Rect2(Vector2(64.0, 112.0), Vector2(832.0, 464.0))
const PLAYER_START = Vector2(480.0, 344.0)
const TARGET_BEACONS = 8
const STARTING_SHIELDS = 3
const STARTING_TIME = 45
const PLAYER_INVULNERABILITY = 1.2
const STATE_READY_COLOR = Color(0.337255, 0.94902, 1.0, 1.0)
const STATE_PLAYING_COLOR = Color(0.4, 1.0, 0.721569, 1.0)
const STATE_WON_COLOR = Color(0.541176, 1.0, 0.65098, 1.0)
const STATE_LOST_COLOR = Color(1.0, 0.411765, 0.427451, 1.0)
const SCORE_BASE_COLOR = Color(0.556863, 1.0, 0.603922, 1.0)
const SCORE_COMPLETE_COLOR = Color(0.85098, 1.0, 0.917647, 1.0)
const SHIELD_BASE_COLOR = Color(1.0, 0.905882, 0.505882, 1.0)
const SHIELD_WARNING_COLOR = Color(1.0, 0.458824, 0.388235, 1.0)
const TIME_BASE_COLOR = Color(0.972549, 0.917647, 0.623529, 1.0)
const TIME_WARNING_COLOR = Color(1.0, 0.501961, 0.364706, 1.0)
const COLLECTION_MESSAGE = "Signal captured. Next lock acquired."
const COLLECTION_WIN_MESSAGE = "Final lock secured."
const RADAR_OVERLAY_BASE_ALPHA = 0.15

@export_group("VFX")
@export var enable_scan_overlay := true
@export_range(0.0, 1.0, 0.05) var scan_overlay_strength := 1.0
@export var enable_screen_flash := true
@export_range(0.0, 1.0, 0.05) var screen_flash_strength := 1.0
@export var enable_edge_pulses := true
@export_range(0.0, 1.0, 0.05) var edge_pulse_strength := 1.0
@export var enable_collection_burst := true
@export_range(0.0, 1.0, 0.05) var collection_burst_strength := 1.0

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
}

var _state := GameState.READY
var _finish_reason := FinishReason.NONE
var _signals_collected := 0
var _shields := STARTING_SHIELDS
var _remaining_time := STARTING_TIME
var _current_beacon: Area2D
var _drone_spawn_count := 0
var _flash_alpha := 0.0
var _flash_color := Color(1.0, 0.18, 0.22, 0.0)
var _ui_anim_time := 0.0
var _north_pulse_alpha := 0.0
var _south_pulse_alpha := 0.0
var _west_pulse_alpha := 0.0
var _east_pulse_alpha := 0.0
var _collection_burst_alpha := 0.0
var _collection_burst_time := 0.0

@onready var _player = $Player
@onready var _audio = $AudioRoot
@onready var _drone_spawn_timer: Timer = $DroneSpawnTimer
@onready var _game_tick_timer: Timer = $GameTickTimer
@onready var _north_pulse: ColorRect = $ArenaNorthPulse
@onready var _south_pulse: ColorRect = $ArenaSouthPulse
@onready var _west_pulse: ColorRect = $ArenaWestPulse
@onready var _east_pulse: ColorRect = $ArenaEastPulse
@onready var _radar_overlay: ColorRect = $RadarOverlay
@onready var _collection_burst: Node2D = $CollectionBurst
@onready var _burst_ring: Line2D = $CollectionBurst/BurstRing
@onready var _burst_arc: Line2D = $CollectionBurst/BurstArc
@onready var _burst_spark: Polygon2D = $CollectionBurst/BurstSpark
@onready var _screen_flash: ColorRect = $CanvasLayer/ScreenFlash
@onready var _score_label: Label = $CanvasLayer/ScoreLabel
@onready var _shield_label: Label = $CanvasLayer/ShieldLabel
@onready var _time_label: Label = $CanvasLayer/TimeLabel
@onready var _state_panel: Panel = $CanvasLayer/StatePanel
@onready var _state_accent: ColorRect = $CanvasLayer/StatePanel/StateAccent
@onready var _state_label: Label = $CanvasLayer/StatePanel/StateLabel
@onready var _hint_label: Label = $CanvasLayer/StatePanel/HintLabel
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


func _ready() -> void:
	randomize()
	_player.arena_rect = ARENA_RECT
	_player.beacon_collected.connect(_on_player_beacon_collected)
	_player.drone_hit.connect(_on_player_drone_hit)
	_drone_spawn_timer.timeout.connect(_on_drone_spawn_timer_timeout)
	_game_tick_timer.timeout.connect(_on_game_tick_timer_timeout)
	_apply_vfx_configuration()
	_show_ready_screen()


func _process(delta: float) -> void:
	_ui_anim_time += delta
	_update_screen_flash(delta)
	_update_edge_pulses(delta)
	_update_collection_burst(delta)
	_update_hud_animation()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"start_game") and _state != GameState.PLAYING:
		new_game()
		get_viewport().set_input_as_handled()


func new_game() -> void:
	_state = GameState.PLAYING
	_finish_reason = FinishReason.NONE
	_signals_collected = 0
	_shields = STARTING_SHIELDS
	_remaining_time = STARTING_TIME
	_drone_spawn_count = 0
	_ui_anim_time = 0.0
	_flash_alpha = 0.0
	_screen_flash.color = Color(1.0, 1.0, 1.0, 0.0)
	_clear_edge_pulses()
	_reset_collection_burst()

	_clear_group(&"drones")
	_clear_group(&"beacons")
	_hide_start_screen()
	_hide_end_screen()

	_audio.play_deploy_confirm()
	_audio.play_gameplay_music()
	_player.start(PLAYER_START)
	_spawn_beacon()
	_spawn_drone(false)

	_drone_spawn_timer.wait_time = 2.0
	_drone_spawn_timer.start()
	_game_tick_timer.start()

	_message_label.text = "Collect green signals. Avoid red patrol drones."
	_update_hud()


func _show_ready_screen() -> void:
	_state = GameState.READY
	_finish_reason = FinishReason.NONE
	_signals_collected = 0
	_shields = STARTING_SHIELDS
	_remaining_time = STARTING_TIME
	_drone_spawn_count = 0
	_flash_alpha = 0.0
	_ui_anim_time = 0.0
	_player.set_active(false)
	_drone_spawn_timer.stop()
	_game_tick_timer.stop()
	_clear_group(&"drones")
	_clear_group(&"beacons")
	_current_beacon = null
	_clear_edge_pulses()
	_reset_collection_burst()
	_show_start_screen()
	_hide_end_screen()
	_audio.play_briefing_music()
	_message_label.text = "Mission briefing loaded. Press Space or Enter to deploy."
	_update_hud()


func _spawn_beacon() -> void:
	if is_instance_valid(_current_beacon):
		_current_beacon.queue_free()

	_current_beacon = BEACON_SCENE.instantiate()
	_current_beacon.position = _find_spawn_position(140.0)
	add_child(_current_beacon)


func _spawn_drone(play_spawn_alert: bool = true) -> void:
	var drone = DRONE_SCENE.instantiate()
	var speed := randf_range(150.0, 240.0) + float(_drone_spawn_count) * 8.0
	var start_position := _random_perimeter_position()

	drone.configure(start_position, _player.position, speed, ARENA_RECT)
	drone.bounced.connect(_on_drone_bounced)
	add_child(drone)

	_drone_spawn_count += 1
	_drone_spawn_timer.wait_time = maxf(0.75, 2.0 - float(_drone_spawn_count) * 0.08)
	if play_spawn_alert and _state == GameState.PLAYING:
		_audio.play_drone_spawn_alert(_drone_spawn_count)


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

	var beacon_position := beacon.global_position
	_signals_collected += 1
	beacon.queue_free()
	if beacon == _current_beacon:
		_current_beacon = null

	_start_collection_burst(beacon_position)
	_audio.play_beacon_collect(float(_signals_collected) / float(TARGET_BEACONS))

	if _signals_collected >= TARGET_BEACONS:
		_message_label.text = COLLECTION_WIN_MESSAGE
		_trigger_flash(Color(0.31, 1.0, 0.56, 1.0), 0.16)
		_finish_game(FinishReason.SUCCESS)
	else:
		_message_label.text = COLLECTION_MESSAGE
		_trigger_flash(Color(0.36, 1.0, 0.66, 1.0), 0.1)
		_spawn_beacon()
		_update_hud()


func _on_player_drone_hit() -> void:
	if _state != GameState.PLAYING:
		return

	_shields -= 1
	_player.start_invulnerability(PLAYER_INVULNERABILITY)
	_audio.play_player_hit()

	if _shields <= 0:
		_trigger_flash(Color(1.0, 0.22, 0.28, 1.0), 0.34)
		_finish_game(FinishReason.SHIELDS)
	else:
		_trigger_flash(Color(1.0, 0.24, 0.31, 1.0), 0.24)
		_message_label.text = "Shield hit! Keep moving."
		_update_hud()


func _on_drone_spawn_timer_timeout() -> void:
	if _state == GameState.PLAYING:
		_spawn_drone(true)


func _on_game_tick_timer_timeout() -> void:
	if _state != GameState.PLAYING:
		return

	_remaining_time -= 1
	if _remaining_time <= 0:
		_finish_game(FinishReason.SUCCESS if _signals_collected >= TARGET_BEACONS else FinishReason.TIME)
	else:
		_audio.play_countdown_warning(_remaining_time)
		_update_hud()


func _finish_game(finish_reason: int) -> void:
	_finish_reason = finish_reason
	var player_won := finish_reason == FinishReason.SUCCESS
	_state = GameState.WON if player_won else GameState.LOST
	_drone_spawn_timer.stop()
	_game_tick_timer.stop()
	_player.set_active(false)

	if is_instance_valid(_current_beacon):
		_current_beacon.queue_free()
		_current_beacon = null

	for drone in get_tree().get_nodes_in_group(&"drones"):
		drone.set_physics_process(false)

	_audio.play_result(player_won)
	_message_label.text = "Training complete! Press Space to replay." if player_won else "Signal lost. Press Space to retry."
	_trigger_flash(Color(0.3, 1.0, 0.62, 1.0), 0.18 if player_won else 0.26)
	_show_end_screen()
	_update_hud()


func _update_hud() -> void:
	_score_label.text = "Signals: %d/%d" % [_signals_collected, TARGET_BEACONS]
	_shield_label.text = "Shields: %d" % _shields
	_time_label.text = "Time: %d" % max(0, _remaining_time)
	_update_state_panel()


func _clear_group(group_name: StringName) -> void:
	for node in get_tree().get_nodes_in_group(group_name):
		node.queue_free()


func _trigger_flash(color: Color, alpha: float) -> void:
	if not enable_screen_flash or screen_flash_strength <= 0.0:
		return

	_flash_color = color
	_flash_alpha = maxf(_flash_alpha, alpha * screen_flash_strength)
	_screen_flash.color = Color(color.r, color.g, color.b, _flash_alpha)


func _on_drone_bounced(edge: StringName, _world_position: Vector2) -> void:
	if _state == GameState.PLAYING:
		_audio.play_bounce(edge)
		_trigger_edge_pulse(edge, 0.42)


func _update_screen_flash(delta: float) -> void:
	if _flash_alpha <= 0.0:
		return

	_flash_alpha = maxf(0.0, _flash_alpha - delta * 1.6)
	_screen_flash.color = Color(_flash_color.r, _flash_color.g, _flash_color.b, _flash_alpha)


func _trigger_edge_pulse(edge: StringName, alpha: float) -> void:
	if not enable_edge_pulses or edge_pulse_strength <= 0.0:
		return

	alpha *= edge_pulse_strength
	match edge:
		&"north":
			_north_pulse_alpha = maxf(_north_pulse_alpha, alpha)
		&"south":
			_south_pulse_alpha = maxf(_south_pulse_alpha, alpha)
		&"west":
			_west_pulse_alpha = maxf(_west_pulse_alpha, alpha)
		&"east":
			_east_pulse_alpha = maxf(_east_pulse_alpha, alpha)


func _clear_edge_pulses() -> void:
	_north_pulse_alpha = 0.0
	_south_pulse_alpha = 0.0
	_west_pulse_alpha = 0.0
	_east_pulse_alpha = 0.0
	_north_pulse.color.a = 0.0
	_south_pulse.color.a = 0.0
	_west_pulse.color.a = 0.0
	_east_pulse.color.a = 0.0


func _update_edge_pulses(delta: float) -> void:
	_north_pulse_alpha = maxf(0.0, _north_pulse_alpha - delta * 2.2)
	_south_pulse_alpha = maxf(0.0, _south_pulse_alpha - delta * 2.2)
	_west_pulse_alpha = maxf(0.0, _west_pulse_alpha - delta * 2.2)
	_east_pulse_alpha = maxf(0.0, _east_pulse_alpha - delta * 2.2)

	_north_pulse.color = Color(0.352941, 0.980392, 1.0, _north_pulse_alpha)
	_south_pulse.color = Color(0.352941, 0.980392, 1.0, _south_pulse_alpha)
	_west_pulse.color = Color(0.352941, 0.980392, 1.0, _west_pulse_alpha)
	_east_pulse.color = Color(0.352941, 0.980392, 1.0, _east_pulse_alpha)


func _update_hud_animation() -> void:
	var pulse := 0.5 + 0.5 * sin(_ui_anim_time * 5.2)
	var progress := float(_signals_collected) / float(TARGET_BEACONS)

	_score_label.modulate = SCORE_BASE_COLOR.lerp(SCORE_COMPLETE_COLOR, progress)
	_message_label.modulate = Color(0.72549, 0.968627, 1.0, 0.88 + pulse * 0.12)

	if _state == GameState.PLAYING and _shields <= 1:
		_shield_label.modulate = SHIELD_BASE_COLOR.lerp(SHIELD_WARNING_COLOR, 0.6 + pulse * 0.4)
	else:
		_shield_label.modulate = SHIELD_BASE_COLOR

	if _state == GameState.PLAYING and _remaining_time <= 10:
		_time_label.modulate = TIME_BASE_COLOR.lerp(TIME_WARNING_COLOR, 0.62 + pulse * 0.38)
	else:
		_time_label.modulate = TIME_BASE_COLOR

	var state_color := _get_state_color()
	_state_panel.modulate = Color(1.0, 1.0, 1.0, 0.92 + pulse * 0.05)
	_state_accent.color = Color(state_color.r, state_color.g, state_color.b, 0.78 + pulse * 0.18)
	_state_label.modulate = state_color
	_hint_label.modulate = state_color.lerp(Color(0.86, 0.94, 1.0, 1.0), 0.42)


func _update_state_panel() -> void:
	match _state:
		GameState.READY:
			_state_label.text = "READY"
			_hint_label.text = "Awaiting deploy"
		GameState.PLAYING:
			_state_label.text = "TRACKING"
			if _remaining_time <= 10:
				_hint_label.text = "Low time window"
			elif _shields <= 1:
				_hint_label.text = "Shield critical"
			elif _drone_spawn_count >= 4:
				_hint_label.text = "Traffic saturated"
			else:
				_hint_label.text = "Sweep stable"
		GameState.WON:
			_state_label.text = "LOCKED"
			_hint_label.text = "Route complete"
		GameState.LOST:
			_state_label.text = "FAILED"
			_hint_label.text = "Signal dropped"


func _get_state_color() -> Color:
	match _state:
		GameState.READY:
			return STATE_READY_COLOR
		GameState.PLAYING:
			return STATE_PLAYING_COLOR
		GameState.WON:
			return STATE_WON_COLOR
		GameState.LOST:
			return STATE_LOST_COLOR
	return STATE_READY_COLOR


func _show_end_screen() -> void:
	_hide_start_screen()
	var player_won := _finish_reason == FinishReason.SUCCESS
	var accent_color := STATE_WON_COLOR if player_won else STATE_LOST_COLOR
	var report_tag := "MISSION SUCCESS" if player_won else "MISSION FAILED"
	var report_title := ""
	var report_summary := ""
	var report_status := ""

	match _finish_reason:
		FinishReason.SUCCESS:
			report_title = "SIGNAL LOCKED"
			report_summary = "All target signals were secured before hostile traffic could saturate the sweep lane."
			report_status = "Status: Recovery route complete."
		FinishReason.SHIELDS:
			report_title = "SHIELDS COLLAPSED"
			report_summary = "Repeated drone contact broke the hull shield before the sweep could be finished."
			report_status = "Failure cause: Shield reserve exhausted."
		FinishReason.TIME:
			report_title = "WINDOW CLOSED"
			report_summary = "The recovery timer expired before the remaining signals could be captured."
			report_status = "Failure cause: Countdown expired."
		_:
			report_title = "RUN ENDED"
			report_summary = "The exercise has concluded."
			report_status = "Status: Awaiting redeploy."

	var report_lines := PackedStringArray([
		"Signals captured: %d/%d" % [_signals_collected, TARGET_BEACONS],
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


func _start_collection_burst(world_position: Vector2) -> void:
	if not enable_collection_burst or collection_burst_strength <= 0.0:
		return

	_collection_burst.visible = true
	_collection_burst.global_position = world_position
	_collection_burst_alpha = collection_burst_strength
	_collection_burst_time = 0.0


func _reset_collection_burst() -> void:
	_collection_burst.visible = false
	_collection_burst_alpha = 0.0
	_collection_burst_time = 0.0
	_burst_ring.default_color = Color(0.517647, 1.0, 0.678431, 0.0)
	_burst_arc.default_color = Color(0.901961, 1.0, 0.760784, 0.0)
	_burst_spark.color = Color(0.92549, 1.0, 0.792157, 0.0)
	_collection_burst.scale = Vector2.ONE
	_collection_burst.rotation = 0.0


func _update_collection_burst(delta: float) -> void:
	if _collection_burst_alpha <= 0.0:
		return

	_collection_burst_time += delta
	_collection_burst_alpha = maxf(0.0, _collection_burst_alpha - delta * 2.8)

	var pulse := 0.5 + 0.5 * sin(_collection_burst_time * 16.0)
	_collection_burst.scale = Vector2.ONE * (1.0 + _collection_burst_time * 1.8)
	_collection_burst.rotation += delta * 2.2
	_burst_ring.width = 2.0 + _collection_burst_time * 4.0
	_burst_ring.default_color = Color(0.517647, 1.0, 0.678431, _collection_burst_alpha * 0.75)
	_burst_arc.rotation += delta * 4.4
	_burst_arc.default_color = Color(0.901961, 1.0, 0.760784, _collection_burst_alpha * (0.45 + pulse * 0.35))
	_burst_spark.scale = Vector2.ONE * (0.92 + pulse * 0.18)
	_burst_spark.color = Color(0.92549, 1.0, 0.792157, _collection_burst_alpha * 0.92)

	if _collection_burst_alpha <= 0.0:
		_collection_burst.visible = false


func _apply_vfx_configuration() -> void:
	_radar_overlay.visible = enable_scan_overlay and scan_overlay_strength > 0.0

	var overlay_material := _radar_overlay.material as ShaderMaterial
	if overlay_material:
		overlay_material.set_shader_parameter(
			"scan_color",
			Color(0.16, 0.93, 1.0, RADAR_OVERLAY_BASE_ALPHA * clampf(scan_overlay_strength, 0.0, 1.0))
		)

	if not enable_screen_flash or screen_flash_strength <= 0.0:
		_flash_alpha = 0.0
		_screen_flash.color = Color(1.0, 1.0, 1.0, 0.0)

	_north_pulse.visible = enable_edge_pulses and edge_pulse_strength > 0.0
	_south_pulse.visible = enable_edge_pulses and edge_pulse_strength > 0.0
	_west_pulse.visible = enable_edge_pulses and edge_pulse_strength > 0.0
	_east_pulse.visible = enable_edge_pulses and edge_pulse_strength > 0.0
	if not enable_edge_pulses or edge_pulse_strength <= 0.0:
		_clear_edge_pulses()

	if not enable_collection_burst or collection_burst_strength <= 0.0:
		_reset_collection_burst()
