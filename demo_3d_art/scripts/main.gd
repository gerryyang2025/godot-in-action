extends Node3D

const BEACON_SCENE = preload("res://scenes/beacon.tscn")
const DRONE_SCENE = preload("res://scenes/drone.tscn")

const PLAYER_START = Vector3(0.0, 1.1, 13.4)
const CAMERA_OFFSET = Vector3(0.0, 12.8, 18.6)
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
const NAV_CELL_SIZE = 1.35
const NAV_WORLD_MARGIN = 1.45
const NAV_AGENT_RADIUS = 0.82
const NAV_AGENT_HEIGHT = 1.2
const NAV_PROBE_Y = 0.95
const NAV_INVALID_ID = Vector2i(-1, -1)
const BEACON_MIN_SEPARATION = 3.2

const OPENING_DRONE_PATROLS = [
	{
		"point_a": Vector3(-18.5, 1.0, -2.6),
		"point_b": Vector3(18.5, 1.0, -2.6),
		"speed": 4.8,
		"behavior": {
			"drone_type": "hunter",
			"can_chase": true,
			"detection_radius": 8.0,
			"chase_speed_multiplier": 1.86,
			"chase_lock_time": 2.7,
			"chase_forget_distance": 13.8
		}
	},
	{
		"point_a": Vector3(15.8, 1.0, -12.8),
		"point_b": Vector3(-15.4, 1.0, 11.2),
		"speed": 3.7,
		"behavior": {
			"drone_type": "hunter",
			"can_chase": true,
			"detection_radius": 7.0,
			"chase_speed_multiplier": 1.92,
			"chase_lock_time": 2.9,
			"chase_forget_distance": 13.2
		}
	},
	{
		"point_a": Vector3(-18.0, 1.0, 13.2),
		"point_b": Vector3(-18.0, 1.0, -12.4),
		"speed": 3.2,
		"behavior": {
			"drone_type": "patrol",
			"can_chase": false,
			"detection_radius": 5.4,
			"chase_speed_multiplier": 1.38,
			"chase_lock_time": 1.7,
			"chase_forget_distance": 9.8
		}
	},
	{
		"point_a": Vector3(13.2, 1.0, 12.0),
		"point_b": Vector3(13.2, 1.0, -11.8),
		"speed": 3.6,
		"behavior": {
			"drone_type": "patrol",
			"can_chase": false,
			"detection_radius": 5.6,
			"chase_speed_multiplier": 1.42,
			"chase_lock_time": 1.8,
			"chase_forget_distance": 10.0
		}
	},
	{
		"point_a": Vector3(-19.4, 1.0, 15.6),
		"point_b": Vector3(19.4, 1.0, 15.6),
		"speed": 3.9,
		"behavior": {
			"drone_type": "blockade",
			"can_chase": false
		}
	},
	{
		"point_a": Vector3(-20.2, 1.0, -14.6),
		"point_b": Vector3(20.2, 1.0, -14.6),
		"speed": 3.8,
		"behavior": {
			"drone_type": "blockade",
			"can_chase": false,
			"detection_radius": 5.8,
			"chase_speed_multiplier": 1.4,
			"chase_lock_time": 1.8,
			"chase_forget_distance": 10.4
		}
	},
	{
		"point_a": Vector3(-8.4, 1.0, 15.4),
		"point_b": Vector3(8.8, 1.0, -14.4),
		"speed": 3.5,
		"behavior": {
			"drone_type": "hunter",
			"can_chase": true,
			"detection_radius": 6.5,
			"chase_speed_multiplier": 2.0,
			"chase_lock_time": 2.6,
			"chase_forget_distance": 12.4
		}
	},
]

const FIRST_REINFORCEMENT_DRONE_PATROLS = [
	{
		"point_a": Vector3(20.5, 1.0, -14.0),
		"point_b": Vector3(20.5, 1.0, 13.8),
		"speed": 4.0,
		"behavior": {
			"drone_type": "hunter",
			"can_chase": true,
			"detection_radius": 6.8,
			"chase_speed_multiplier": 1.96,
			"chase_lock_time": 2.8,
			"chase_forget_distance": 12.6
		}
	},
	{
		"point_a": Vector3(-18.2, 1.0, -15.2),
		"point_b": Vector3(18.2, 1.0, -15.2),
		"speed": 4.1,
		"behavior": {
			"drone_type": "blockade",
			"can_chase": false
		}
	},
	{
		"point_a": Vector3(-21.0, 1.0, 13.4),
		"point_b": Vector3(-21.0, 1.0, -13.6),
		"speed": 4.0,
		"behavior": {
			"drone_type": "patrol",
			"can_chase": false,
			"detection_radius": 5.7,
			"chase_speed_multiplier": 1.46,
			"chase_lock_time": 1.9,
			"chase_forget_distance": 10.0
		}
	},
]

const SECOND_REINFORCEMENT_DRONE_PATROLS = [
	{
		"point_a": Vector3(-20.0, 1.0, 14.8),
		"point_b": Vector3(20.0, 1.0, -13.8),
		"speed": 4.2,
		"behavior": {
			"drone_type": "hunter",
			"can_chase": true,
			"detection_radius": 7.6,
			"chase_speed_multiplier": 2.08,
			"chase_lock_time": 3.1,
			"chase_forget_distance": 14.8
		}
	},
	{
		"point_a": Vector3(19.8, 1.0, 14.4),
		"point_b": Vector3(-19.6, 1.0, 14.4),
		"speed": 4.3,
		"behavior": {
			"drone_type": "blockade",
			"can_chase": false,
			"detection_radius": 6.2,
			"chase_speed_multiplier": 1.52,
			"chase_lock_time": 2.0,
			"chase_forget_distance": 11.8
		}
	},
]

const BEACON_POINTS = [
	Vector3(-18.4, 1.0, 13.0),
	Vector3(17.8, 1.0, 12.8),
	Vector3(-17.8, 1.0, -13.2),
	Vector3(18.2, 1.0, -13.6),
	Vector3(-7.2, 1.0, -11.0),
	Vector3(7.6, 1.0, 2.8),
	Vector3(-0.8, 1.0, 14.8),
	Vector3(13.4, 1.0, -3.2),
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
var _nav_grid := AStarGrid2D.new()
var _nav_walkable_ids: Array[Vector2i] = []
var _nav_cell_positions: Dictionary = {}
var _nav_probe_shape: CylinderShape3D
var _nav_world_rect := Rect2()

@onready var _player = $Player
@onready var _audio = $AudioRoot
@onready var _camera: Camera3D = $Camera3D
@onready var _arena_floor: StaticBody3D = $Arena/Floor
@onready var _arena_floor_collision: CollisionShape3D = $Arena/Floor/CollisionShape3D
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
	_build_navigation_grid()
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


func get_drone_path(from_position: Vector3, target_position: Vector3, hover_height: float = 1.0) -> PackedVector3Array:
	var path := PackedVector3Array()
	if _nav_walkable_ids.is_empty():
		path.append(Vector3(target_position.x, hover_height, target_position.z))
		return path

	var start_id := _find_nearest_walkable_id(from_position)
	var target_id := _find_nearest_walkable_id(target_position)
	if start_id == NAV_INVALID_ID or target_id == NAV_INVALID_ID:
		path.append(Vector3(target_position.x, hover_height, target_position.z))
		return path

	var path_points_2d := _nav_grid.get_point_path(start_id, target_id, true)
	if path_points_2d.is_empty():
		path.append(_nav_id_to_world_position(target_id, hover_height))
		return path

	for path_point_2d in path_points_2d:
		path.append(Vector3(path_point_2d.x, hover_height, path_point_2d.y))

	return path


func _build_navigation_grid() -> void:
	_nav_walkable_ids.clear()
	_nav_cell_positions.clear()

	var floor_shape := _arena_floor_collision.shape as BoxShape3D
	if floor_shape == null:
		push_warning("Arena floor collision is not a BoxShape3D; drone navigation grid was skipped.")
		return

	var floor_center := Vector2(_arena_floor.global_position.x, _arena_floor.global_position.z)
	var half_extents := Vector2(floor_shape.size.x * 0.5, floor_shape.size.z * 0.5) - Vector2.ONE * NAV_WORLD_MARGIN
	if half_extents.x <= 0.0 or half_extents.y <= 0.0:
		push_warning("Arena floor is too small to build the drone navigation grid.")
		return

	_nav_world_rect = Rect2(floor_center - half_extents, half_extents * 2.0)
	var region_size := Vector2i(
			maxi(1, ceili(_nav_world_rect.size.x / NAV_CELL_SIZE)),
			maxi(1, ceili(_nav_world_rect.size.y / NAV_CELL_SIZE))
	)

	_nav_grid = AStarGrid2D.new()
	_nav_grid.region = Rect2i(Vector2i.ZERO, region_size)
	_nav_grid.cell_size = Vector2.ONE * NAV_CELL_SIZE
	_nav_grid.offset = _nav_world_rect.position + Vector2.ONE * (NAV_CELL_SIZE * 0.5)
	_nav_grid.diagonal_mode = AStarGrid2D.DIAGONAL_MODE_ONLY_IF_NO_OBSTACLES
	_nav_grid.default_compute_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_nav_grid.default_estimate_heuristic = AStarGrid2D.HEURISTIC_OCTILE
	_nav_grid.update()

	_nav_probe_shape = CylinderShape3D.new()
	_nav_probe_shape.radius = NAV_AGENT_RADIUS
	_nav_probe_shape.height = NAV_AGENT_HEIGHT

	for nav_x in region_size.x:
		for nav_y in region_size.y:
			var nav_id := Vector2i(nav_x, nav_y)
			var walkable := _is_nav_cell_walkable(nav_id)
			_nav_grid.set_point_solid(nav_id, not walkable)

			if not walkable:
				continue

			var point_2d := _nav_grid.get_point_position(nav_id)
			_nav_walkable_ids.append(nav_id)
			_nav_cell_positions[nav_id] = Vector3(point_2d.x, NAV_PROBE_Y, point_2d.y)

	if _nav_walkable_ids.is_empty():
		push_warning("Drone navigation grid finished with no walkable cells.")


func _is_nav_cell_walkable(nav_id: Vector2i) -> bool:
	var point_2d := _nav_grid.get_point_position(nav_id)
	var query := PhysicsShapeQueryParameters3D.new()
	query.shape = _nav_probe_shape
	query.transform = Transform3D(Basis.IDENTITY, Vector3(point_2d.x, NAV_PROBE_Y, point_2d.y))
	query.collision_mask = 1
	query.margin = 0.02
	return get_world_3d().direct_space_state.intersect_shape(query, 1).is_empty()


func _nav_id_to_world_position(nav_id: Vector2i, y_position: float = 1.0) -> Vector3:
	var cached_position: Vector3 = _nav_cell_positions.get(nav_id, Vector3.ZERO)
	if cached_position == Vector3.ZERO and not _nav_cell_positions.has(nav_id):
		var point_2d := _nav_grid.get_point_position(nav_id)
		cached_position = Vector3(point_2d.x, NAV_PROBE_Y, point_2d.y)

	return Vector3(cached_position.x, y_position, cached_position.z)


func _find_nearest_walkable_id(
		desired_position: Vector3,
		blocked_ids: Dictionary = {},
		reserved_positions: Array = [],
		min_separation: float = 0.0
	) -> Vector2i:
	if _nav_walkable_ids.is_empty():
		return NAV_INVALID_ID

	var desired_point := Vector2(desired_position.x, desired_position.z)
	var best_id := NAV_INVALID_ID
	var best_distance_sq := INF

	for nav_id in _nav_walkable_ids:
		if blocked_ids.has(nav_id):
			continue

		var candidate_position := _nav_id_to_world_position(nav_id, desired_position.y)
		if not _is_position_spaced(candidate_position, reserved_positions, min_separation):
			continue

		var distance_sq := desired_point.distance_squared_to(Vector2(candidate_position.x, candidate_position.z))
		if distance_sq >= best_distance_sq:
			continue

		best_distance_sq = distance_sq
		best_id = nav_id

	return best_id


func _is_position_spaced(candidate_position: Vector3, reserved_positions: Array, min_separation: float) -> bool:
	if min_separation <= 0.0:
		return true

	var min_separation_sq := min_separation * min_separation
	for reserved_position in reserved_positions:
		if Vector2(candidate_position.x - reserved_position.x, candidate_position.z - reserved_position.z).length_squared() < min_separation_sq:
			return false

	return true


func _resolve_beacon_positions() -> Array[Vector3]:
	var resolved_positions: Array[Vector3] = []
	var used_ids := {}

	for beacon_anchor in BEACON_POINTS:
		var beacon_id := _find_nearest_walkable_id(beacon_anchor, used_ids, resolved_positions, BEACON_MIN_SEPARATION)
		if beacon_id == NAV_INVALID_ID:
			continue

		used_ids[beacon_id] = true
		resolved_positions.append(_nav_id_to_world_position(beacon_id, beacon_anchor.y))

	if resolved_positions.size() < TARGET_BEACONS:
		for nav_id in _nav_walkable_ids:
			if used_ids.has(nav_id):
				continue

			var fallback_position := _nav_id_to_world_position(nav_id, 1.0)
			if not _is_position_spaced(fallback_position, resolved_positions, BEACON_MIN_SEPARATION):
				continue

			used_ids[nav_id] = true
			resolved_positions.append(fallback_position)
			if resolved_positions.size() >= TARGET_BEACONS:
				break

	if resolved_positions.size() < TARGET_BEACONS:
		push_warning("Only %d valid beacon positions were found on the current navigation grid." % resolved_positions.size())

	return resolved_positions


func _spawn_all_beacons() -> void:
	for beacon_position in _resolve_beacon_positions():
		var beacon = BEACON_SCENE.instantiate()
		beacon.collected.connect(_on_beacon_collected)
		add_child(beacon)
		beacon.position = beacon_position


func _spawn_drone(point_a: Vector3, point_b: Vector3, speed: float, behavior: Dictionary = {}) -> void:
	var point_a_id := _find_nearest_walkable_id(point_a)
	var point_b_id := _find_nearest_walkable_id(point_b, {point_a_id: true})
	if point_a_id == NAV_INVALID_ID:
		push_warning("Skipping drone spawn because no valid patrol start was found near %s." % str(point_a))
		return
	if point_b_id == NAV_INVALID_ID:
		point_b_id = point_a_id

	var resolved_point_a := _nav_id_to_world_position(point_a_id, point_a.y)
	var resolved_point_b := _nav_id_to_world_position(point_b_id, point_b.y)
	var drone = DRONE_SCENE.instantiate()
	drone.player_hit.connect(_on_drone_player_hit)
	add_child(drone)
	drone.configure(resolved_point_a, resolved_point_b, speed, behavior)


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
