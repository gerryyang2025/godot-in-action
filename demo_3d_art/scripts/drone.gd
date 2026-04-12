extends CharacterBody3D

signal player_hit

const DRONE_TYPE_PATROL := &"patrol"
const DRONE_TYPE_HUNTER := &"hunter"
const DRONE_TYPE_BLOCKADE := &"blockade"
const PLAYER_LINE_OF_SIGHT_MASK := 3
const PATH_TARGET_REFRESH_DISTANCE := 1.1
const PATH_DEVIATION_DISTANCE := 2.4
const DRONE_AUDIO_MIX_RATE := 22050
const HUNTER_DETECTION_RADIUS_MULTIPLIER := 1.22
const HUNTER_CHASE_LOCK_MULTIPLIER := 1.5
const HUNTER_FORGET_DISTANCE_MULTIPLIER := 1.25
const HUNTER_LINE_BREAK_DECAY := 1.05
const HUNTER_REPATH_INTERVAL := 0.14
const HUNTER_TARGET_REFRESH_DISTANCE := 0.7
const HUNTER_SUPPORT_ALERT_RADIUS := 11.5
const HUNTER_SUPPORT_ALERT_COOLDOWN := 1.15
const HUNTER_SUPPORT_LOCK_TIME := 2.8

@export var speed: float = 4.0
@export var acceleration: float = 16.0
@export var can_chase: bool = false
@export var detection_radius: float = 5.8
@export var chase_speed_multiplier: float = 1.45
@export var chase_lock_time: float = 1.9
@export var chase_forget_distance: float = 9.5
@export var line_of_sight_required: bool = true
@export var target_reached_distance: float = 0.4
@export var path_point_reached_distance: float = 0.55
@export var patrol_repath_interval: float = 0.8
@export var chase_repath_interval: float = 0.22

var _point_a := Vector3.ZERO
var _point_b := Vector3.ZERO
var _target := Vector3.ZERO
var _hover_height := 1.0
var _age := 0.0
var _drone_type: StringName = DRONE_TYPE_PATROL
var _is_chasing := false
var _chase_timer := 0.0
var _alert_level := 0.0
var _player: Node3D
var _chase_disabled_time := 0.0
var _navigation_provider: Node
var _path_points := PackedVector3Array()
var _path_index := 0
var _path_refresh_remaining := 0.0
var _last_path_target := Vector3.ZERO
var _has_cached_path_target := false
var _danger_ring_scale_multiplier := 1.0
var _rotor_speed_multiplier := 1.0
var _light_energy_multiplier := 1.0
var _audio_enabled := false
var _support_alert_cooldown := 0.0

@onready var _visual: Node3D = $Visual
@onready var _body: MeshInstance3D = $Visual/Body
@onready var _wing: MeshInstance3D = $Visual/Wing
@onready var _hitbox: Area3D = $Hitbox
@onready var _rotor_left: Node3D = $Visual/RotorLeftPivot
@onready var _rotor_right: Node3D = $Visual/RotorRightPivot
@onready var _rotor_left_mesh: MeshInstance3D = $Visual/RotorLeftPivot/RotorLeft
@onready var _rotor_right_mesh: MeshInstance3D = $Visual/RotorRightPivot/RotorRight
@onready var _sensor: MeshInstance3D = $Visual/Sensor
@onready var _danger_ring: Node3D = $Visual/DangerRing
@onready var _danger_ring_mesh: MeshInstance3D = $Visual/DangerRing
@onready var _tail_fin: MeshInstance3D = $Visual/TailFin
@onready var _patrol_rig: Node3D = $Visual/PatrolRig
@onready var _patrol_mast: MeshInstance3D = $Visual/PatrolRig/Mast
@onready var _patrol_tip: MeshInstance3D = $Visual/PatrolRig/Tip
@onready var _hunter_rig: Node3D = $Visual/HunterRig
@onready var _hunter_blade_left: MeshInstance3D = $Visual/HunterRig/BladeLeft
@onready var _hunter_blade_right: MeshInstance3D = $Visual/HunterRig/BladeRight
@onready var _blockade_rig: Node3D = $Visual/BlockadeRig
@onready var _blockade_pod_left: MeshInstance3D = $Visual/BlockadeRig/PodLeft
@onready var _blockade_pod_right: MeshInstance3D = $Visual/BlockadeRig/PodRight
@onready var _blockade_fin_left: MeshInstance3D = $Visual/BlockadeRig/FinLeft
@onready var _blockade_fin_right: MeshInstance3D = $Visual/BlockadeRig/FinRight
@onready var _projection_root: Node3D = $ProjectionRoot
@onready var _patrol_projection: Node3D = $ProjectionRoot/PatrolProjection
@onready var _patrol_projection_ring: MeshInstance3D = $ProjectionRoot/PatrolProjection/Ring
@onready var _patrol_projection_disc: MeshInstance3D = $ProjectionRoot/PatrolProjection/Disc
@onready var _hunter_projection: Node3D = $ProjectionRoot/HunterProjection
@onready var _hunter_projection_left: MeshInstance3D = $ProjectionRoot/HunterProjection/LeftArm
@onready var _hunter_projection_right: MeshInstance3D = $ProjectionRoot/HunterProjection/RightArm
@onready var _hunter_projection_stem: MeshInstance3D = $ProjectionRoot/HunterProjection/Stem
@onready var _blockade_projection: Node3D = $ProjectionRoot/BlockadeProjection
@onready var _blockade_projection_left: MeshInstance3D = $ProjectionRoot/BlockadeProjection/LeftRail
@onready var _blockade_projection_right: MeshInstance3D = $ProjectionRoot/BlockadeProjection/RightRail
@onready var _blockade_projection_front: MeshInstance3D = $ProjectionRoot/BlockadeProjection/FrontCap
@onready var _blockade_projection_rear: MeshInstance3D = $ProjectionRoot/BlockadeProjection/RearCap
@onready var _signal_light: OmniLight3D = $Visual/OmniLight3D
@onready var _type_loop_player: AudioStreamPlayer3D = $TypeLoopPlayer


func _ready() -> void:
	_player = get_tree().get_first_node_in_group(&"player") as Node3D
	_navigation_provider = get_parent()
	_audio_enabled = not _is_headless_runtime()
	motion_mode = CharacterBody3D.MOTION_MODE_FLOATING
	_hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	_update_chase_state(delta)

	var active_target := _get_active_target()
	_update_navigation_path(active_target, delta)
	var movement_target := _get_movement_target(active_target)
	var movement_direction := _get_direction_to(movement_target)
	var active_speed := _get_active_speed()
	var target_velocity := movement_direction * active_speed
	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)
	velocity.y = 0.0
	move_and_slide()
	global_position.y = _hover_height

	var planar_target := Vector3(movement_target.x, global_position.y, movement_target.z)
	if not _is_chasing and global_position.distance_to(Vector3(_target.x, global_position.y, _target.z)) < target_reached_distance:
		_target = _point_a if _target == _point_b else _point_b
		_mark_path_dirty()

	if global_position.distance_to(planar_target) > 0.05:
		look_at(planar_target, Vector3.UP)

	_visual.position.y = 0.08 + sin(_age * (7.0 + _alert_level * 3.0)) * (0.05 + _alert_level * 0.015)
	_rotor_left.rotate_y((18.0 + _alert_level * 10.0) * _rotor_speed_multiplier * delta)
	_rotor_right.rotate_y((-18.0 - _alert_level * 10.0) * _rotor_speed_multiplier * delta)
	_danger_ring.rotate_y((2.8 + _alert_level * 2.4) * delta)

	var danger_pulse := 0.5 + 0.5 * sin(_age * (5.2 + _alert_level * 4.0))
	var patrol_scale := 0.94 + 0.1 * danger_pulse
	var chase_scale := 1.1 + 0.16 * danger_pulse
	_danger_ring.scale = Vector3.ONE * lerpf(patrol_scale, chase_scale, _alert_level) * _danger_ring_scale_multiplier

	var patrol_light := 0.46 + 0.35 * (0.5 + 0.5 * sin(_age * 8.6))
	var chase_light := 0.9 + 0.5 * (0.5 + 0.5 * sin(_age * 12.5))
	_signal_light.light_energy = lerpf(patrol_light, chase_light, _alert_level) * _light_energy_multiplier
	_update_projection_feedback()
	_update_type_audio()


func _update_chase_state(delta: float) -> void:
	var was_chasing := _is_chasing
	_support_alert_cooldown = maxf(0.0, _support_alert_cooldown - delta)

	if not can_chase:
		_alert_level = move_toward(_alert_level, 0.0, delta * 2.2)
		if was_chasing != _is_chasing:
			_mark_path_dirty()
		return

	if _chase_disabled_time > 0.0:
		_chase_disabled_time = maxf(0.0, _chase_disabled_time - delta)
		_is_chasing = false
		_alert_level = move_toward(_alert_level, 0.0, delta * 3.6)
		if was_chasing != _is_chasing:
			_mark_path_dirty()
		return

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player") as Node3D
		_alert_level = move_toward(_alert_level, 0.0, delta * 2.2)
		if was_chasing != _is_chasing:
			_mark_path_dirty()
		return

	var player_position := _player.global_position
	var planar_distance := Vector2(player_position.x - global_position.x, player_position.z - global_position.z).length()
	var has_line_of_sight := _has_line_of_sight_to_player(player_position)
	var effective_detection_radius := _get_effective_detection_radius()
	var effective_chase_lock_time := _get_effective_chase_lock_time()
	var effective_forget_distance := _get_effective_forget_distance()

	if planar_distance <= effective_detection_radius and has_line_of_sight:
		_is_chasing = true
		_chase_timer = effective_chase_lock_time
		if _is_hunter_type() and (not was_chasing or _support_alert_cooldown <= 0.0):
			_broadcast_hunter_alert(player_position)
	elif _is_chasing:
		var chase_decay := 1.0
		if not has_line_of_sight:
			chase_decay = HUNTER_LINE_BREAK_DECAY if _is_hunter_type() else 2.1
		_chase_timer -= delta * chase_decay
		if _chase_timer <= 0.0 or planar_distance >= effective_forget_distance:
			_is_chasing = false

	_alert_level = move_toward(_alert_level, 1.0 if _is_chasing else 0.0, delta * 2.8)
	if was_chasing != _is_chasing:
		_mark_path_dirty()


func _get_active_target() -> Vector3:
	if _is_chasing and is_instance_valid(_player):
		return Vector3(_player.global_position.x, global_position.y, _player.global_position.z)

	return _target


func _get_active_speed() -> float:
	return speed * chase_speed_multiplier if _is_chasing else speed


func _update_navigation_path(active_target: Vector3, delta: float) -> void:
	if not is_instance_valid(_navigation_provider) or not _navigation_provider.has_method("get_drone_path"):
		_path_points = PackedVector3Array()
		_path_index = 0
		return

	_path_refresh_remaining = maxf(0.0, _path_refresh_remaining - delta)

	var should_refresh := _path_points.is_empty() or _path_index >= _path_points.size()
	if not should_refresh and _path_index < _path_points.size():
		var current_waypoint := _path_points[_path_index]
		var deviation := Vector2(global_position.x - current_waypoint.x, global_position.z - current_waypoint.z).length()
		should_refresh = deviation >= PATH_DEVIATION_DISTANCE

	var target_refresh_distance := _get_target_refresh_distance()
	var goal_changed := not _has_cached_path_target \
			or Vector2(active_target.x - _last_path_target.x, active_target.z - _last_path_target.z).length() >= target_refresh_distance
	if _path_refresh_remaining <= 0.0 and (_is_chasing or goal_changed):
		should_refresh = true

	if not should_refresh:
		return

	_refresh_navigation_path(active_target)


func _refresh_navigation_path(active_target: Vector3) -> void:
	_path_refresh_remaining = _get_active_repath_interval()
	_last_path_target = active_target
	_has_cached_path_target = true
	_path_points = _navigation_provider.get_drone_path(global_position, active_target, _hover_height)
	_path_index = 0
	_advance_path_index()


func _advance_path_index() -> void:
	while _path_index < _path_points.size():
		var waypoint := _path_points[_path_index]
		var waypoint_position := Vector3(waypoint.x, _hover_height, waypoint.z)
		if global_position.distance_to(waypoint_position) > path_point_reached_distance:
			return
		_path_index += 1


func _get_movement_target(active_target: Vector3) -> Vector3:
	_advance_path_index()
	if _path_points.is_empty():
		return Vector3(active_target.x, _hover_height, active_target.z)

	if _path_index < _path_points.size():
		var next_waypoint := _path_points[_path_index]
		return Vector3(next_waypoint.x, _hover_height, next_waypoint.z)

	var last_waypoint := _path_points[_path_points.size() - 1]
	return Vector3(last_waypoint.x, _hover_height, last_waypoint.z)


func _get_direction_to(target_position: Vector3) -> Vector3:
	var to_target := Vector3(target_position.x - global_position.x, 0.0, target_position.z - global_position.z)
	if to_target.length_squared() <= 0.0001:
		return Vector3.ZERO

	return to_target.normalized()


func _mark_path_dirty() -> void:
	_path_refresh_remaining = 0.0
	_has_cached_path_target = false


func _is_hunter_type() -> bool:
	return _drone_type == DRONE_TYPE_HUNTER


func _get_effective_detection_radius() -> float:
	return detection_radius * HUNTER_DETECTION_RADIUS_MULTIPLIER if _is_hunter_type() else detection_radius


func _get_effective_chase_lock_time() -> float:
	return chase_lock_time * HUNTER_CHASE_LOCK_MULTIPLIER if _is_hunter_type() else chase_lock_time


func _get_effective_forget_distance() -> float:
	return chase_forget_distance * HUNTER_FORGET_DISTANCE_MULTIPLIER if _is_hunter_type() else chase_forget_distance


func _get_target_refresh_distance() -> float:
	if _is_hunter_type() and _is_chasing:
		return HUNTER_TARGET_REFRESH_DISTANCE

	return PATH_TARGET_REFRESH_DISTANCE


func _get_active_repath_interval() -> float:
	if _is_hunter_type() and _is_chasing:
		return minf(chase_repath_interval, HUNTER_REPATH_INTERVAL)

	return chase_repath_interval if _is_chasing else patrol_repath_interval


func _broadcast_hunter_alert(player_position: Vector3) -> void:
	if not _is_hunter_type():
		return
	if _support_alert_cooldown > 0.0:
		return

	_support_alert_cooldown = HUNTER_SUPPORT_ALERT_COOLDOWN

	for drone in get_tree().get_nodes_in_group(&"drones"):
		if drone == self:
			continue
		if not drone.has_method("receive_hunter_alert"):
			continue
		if drone.global_position.distance_to(global_position) > HUNTER_SUPPORT_ALERT_RADIUS:
			continue
		drone.receive_hunter_alert(player_position, HUNTER_SUPPORT_LOCK_TIME)


func receive_hunter_alert(player_position: Vector3, alert_lock_time: float) -> void:
	if not can_chase or not _is_hunter_type():
		return
	if _chase_disabled_time > 0.0:
		return

	_is_chasing = true
	_chase_timer = maxf(_chase_timer, alert_lock_time)
	_alert_level = maxf(_alert_level, 0.45)
	_last_path_target = player_position
	_has_cached_path_target = true
	_mark_path_dirty()


func _sanitize_drone_type(configured_type: StringName) -> StringName:
	if configured_type == DRONE_TYPE_PATROL or configured_type == DRONE_TYPE_HUNTER or configured_type == DRONE_TYPE_BLOCKADE:
		return configured_type

	return DRONE_TYPE_HUNTER if can_chase else DRONE_TYPE_PATROL


func _apply_visual_profile() -> void:
	if _body == null:
		return

	var body_color := Color(0.188235, 0.094118, 0.117647, 1.0)
	var trim_color := Color(1.0, 0.290196, 0.360784, 1.0)
	var light_color := trim_color
	var body_scale := Vector3.ONE
	var wing_scale := Vector3.ONE
	var sensor_scale := Vector3.ONE
	var tail_scale := Vector3.ONE
	_danger_ring_scale_multiplier = 1.0
	_rotor_speed_multiplier = 1.0
	_light_energy_multiplier = 1.0

	_patrol_rig.visible = false
	_hunter_rig.visible = false
	_blockade_rig.visible = false
	_patrol_projection.visible = false
	_hunter_projection.visible = false
	_blockade_projection.visible = false

	match _drone_type:
		DRONE_TYPE_PATROL:
			body_color = Color(0.211765, 0.129412, 0.070588, 1.0)
			trim_color = Color(1.0, 0.67451, 0.258824, 1.0)
			light_color = trim_color
			body_scale = Vector3(0.9, 0.9, 0.9)
			wing_scale = Vector3(1.08, 0.82, 0.86)
			sensor_scale = Vector3(0.8, 0.8, 0.84)
			tail_scale = Vector3(0.88, 1.08, 0.88)
			_danger_ring_scale_multiplier = 0.9
			_rotor_speed_multiplier = 1.06
			_light_energy_multiplier = 0.92
			_patrol_rig.visible = true
			_patrol_projection.visible = true
		DRONE_TYPE_BLOCKADE:
			body_color = Color(0.25098, 0.180392, 0.058824, 1.0)
			trim_color = Color(1.0, 0.835294, 0.309804, 1.0)
			light_color = trim_color
			body_scale = Vector3(1.14, 1.08, 1.12)
			wing_scale = Vector3(1.22, 1.34, 1.0)
			sensor_scale = Vector3(0.92, 0.92, 1.02)
			tail_scale = Vector3(1.08, 1.2, 1.08)
			_danger_ring_scale_multiplier = 1.3
			_rotor_speed_multiplier = 0.94
			_light_energy_multiplier = 1.18
			_blockade_rig.visible = true
			_blockade_projection.visible = true
		_:
			body_color = Color(0.196078, 0.070588, 0.105882, 1.0)
			trim_color = Color(1.0, 0.239216, 0.337255, 1.0)
			light_color = trim_color
			body_scale = Vector3(1.02, 1.02, 1.02)
			wing_scale = Vector3(1.0, 1.0, 1.0)
			sensor_scale = Vector3(1.12, 1.0, 1.22)
			tail_scale = Vector3(1.0, 1.02, 1.0)
			_danger_ring_scale_multiplier = 1.08
			_rotor_speed_multiplier = 1.16
			_light_energy_multiplier = 1.08
			_hunter_rig.visible = true
			_hunter_projection.visible = true

	_body.scale = body_scale
	_wing.scale = wing_scale
	_sensor.scale = sensor_scale
	_tail_fin.scale = tail_scale
	_patrol_rig.scale = Vector3.ONE
	_hunter_rig.scale = Vector3.ONE
	_blockade_rig.scale = Vector3.ONE

	_apply_mesh_palette(_body, body_color, body_color.lerp(trim_color, 0.28), 0.46)
	_apply_mesh_palette(_wing, body_color.darkened(0.04), body_color.lerp(trim_color, 0.22), 0.42)
	_apply_mesh_palette(_tail_fin, body_color.darkened(0.08), trim_color, 0.32)
	_apply_mesh_palette(_sensor, trim_color, trim_color, 1.28)
	_apply_mesh_palette(_rotor_left_mesh, trim_color.darkened(0.16), trim_color, 0.82)
	_apply_mesh_palette(_rotor_right_mesh, trim_color.darkened(0.16), trim_color, 0.82)
	_apply_mesh_palette(_danger_ring_mesh, trim_color, trim_color, 1.48)
	_apply_mesh_palette(_patrol_mast, trim_color.darkened(0.12), trim_color, 1.05)
	_apply_mesh_palette(_patrol_tip, trim_color, trim_color, 1.34)
	_apply_mesh_palette(_hunter_blade_left, trim_color, trim_color, 1.2)
	_apply_mesh_palette(_hunter_blade_right, trim_color, trim_color, 1.2)
	_apply_mesh_palette(_blockade_pod_left, body_color.darkened(0.05), trim_color, 0.58)
	_apply_mesh_palette(_blockade_pod_right, body_color.darkened(0.05), trim_color, 0.58)
	_apply_mesh_palette(_blockade_fin_left, trim_color, trim_color, 1.16)
	_apply_mesh_palette(_blockade_fin_right, trim_color, trim_color, 1.16)
	_apply_projection_palette(_patrol_projection_ring, trim_color, 1.1)
	_apply_projection_palette(_patrol_projection_disc, trim_color, 1.2)
	_apply_projection_palette(_hunter_projection_left, trim_color, 1.18)
	_apply_projection_palette(_hunter_projection_right, trim_color, 1.18)
	_apply_projection_palette(_hunter_projection_stem, trim_color, 1.12)
	_apply_projection_palette(_blockade_projection_left, trim_color, 1.18)
	_apply_projection_palette(_blockade_projection_right, trim_color, 1.18)
	_apply_projection_palette(_blockade_projection_front, trim_color, 1.12)
	_apply_projection_palette(_blockade_projection_rear, trim_color, 1.12)
	_signal_light.light_color = light_color
	_update_projection_feedback()
	_apply_type_audio_stream()


func _apply_mesh_palette(
		mesh_instance: MeshInstance3D,
		albedo_color: Color,
		emission_color: Color,
		emission_energy: float
	) -> void:
	var source_material := mesh_instance.get_surface_override_material(0)
	if source_material == null and mesh_instance.mesh != null:
		source_material = mesh_instance.mesh.surface_get_material(0)
	if source_material == null:
		return

	var instance_material := source_material.duplicate() as StandardMaterial3D
	if instance_material == null:
		return

	instance_material.albedo_color = albedo_color
	instance_material.emission_enabled = true
	instance_material.emission = emission_color
	instance_material.emission_energy_multiplier = emission_energy
	mesh_instance.set_surface_override_material(0, instance_material)


func _apply_projection_palette(mesh_instance: MeshInstance3D, color: Color, emission_energy: float) -> void:
	var source_material := mesh_instance.get_surface_override_material(0)
	if source_material == null and mesh_instance.mesh != null:
		source_material = mesh_instance.mesh.surface_get_material(0)
	if source_material == null:
		return

	var instance_material := source_material.duplicate() as StandardMaterial3D
	if instance_material == null:
		return

	instance_material.albedo_color = color.darkened(0.28)
	instance_material.emission_enabled = true
	instance_material.emission = color
	instance_material.emission_energy_multiplier = emission_energy
	instance_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	instance_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	instance_material.disable_receive_shadows = true
	instance_material.roughness = 0.18
	instance_material.metallic = 0.0
	mesh_instance.set_surface_override_material(0, instance_material)


func _set_mesh_alpha(mesh_instance: MeshInstance3D, alpha: float) -> void:
	var projection_material := mesh_instance.get_surface_override_material(0) as StandardMaterial3D
	if projection_material == null:
		return

	projection_material.emission_energy_multiplier = 0.45 + clampf(alpha, 0.0, 1.0) * 1.55


func _update_projection_feedback() -> void:
	var base_pulse := 0.5 + 0.5 * sin(_age * 2.8)
	var fast_pulse := 0.5 + 0.5 * sin(_age * 5.6 + 0.6)

	match _drone_type:
		DRONE_TYPE_PATROL:
			var patrol_scale := 0.94 + base_pulse * 0.08
			_patrol_projection.scale = Vector3.ONE * patrol_scale
			_patrol_projection_disc.scale = Vector3.ONE * (0.9 + fast_pulse * 0.16)
			var patrol_alpha := 0.18 + base_pulse * 0.08
			_set_mesh_alpha(_patrol_projection_ring, patrol_alpha)
			_set_mesh_alpha(_patrol_projection_disc, patrol_alpha + 0.06)
		DRONE_TYPE_BLOCKADE:
			var blockade_lane_scale := 0.96 + fast_pulse * 0.06
			_blockade_projection_left.scale.z = blockade_lane_scale
			_blockade_projection_right.scale.z = blockade_lane_scale
			_blockade_projection_front.scale.x = 0.96 + base_pulse * 0.08
			_blockade_projection_rear.scale.x = 0.96 + base_pulse * 0.08
			var blockade_alpha := 0.24 + base_pulse * 0.08
			_set_mesh_alpha(_blockade_projection_left, blockade_alpha)
			_set_mesh_alpha(_blockade_projection_right, blockade_alpha)
			_set_mesh_alpha(_blockade_projection_front, blockade_alpha + 0.04)
			_set_mesh_alpha(_blockade_projection_rear, blockade_alpha + 0.04)
		_:
			var hunter_scale_z := 0.92 + fast_pulse * 0.14 + _alert_level * 0.08
			_hunter_projection.scale = Vector3(1.0, 1.0, hunter_scale_z)
			var hunter_alpha := lerpf(0.24 + base_pulse * 0.05, 0.6 + fast_pulse * 0.08, _alert_level)
			_set_mesh_alpha(_hunter_projection_left, hunter_alpha)
			_set_mesh_alpha(_hunter_projection_right, hunter_alpha)
			_set_mesh_alpha(_hunter_projection_stem, hunter_alpha + 0.05)


func _apply_type_audio_stream() -> void:
	if not _audio_enabled:
		_type_loop_player.stop()
		_type_loop_player.stream = null
		return

	var stream := _generate_type_loop_stream()
	_type_loop_player.stop()
	_type_loop_player.stream = stream
	_type_loop_player.pitch_scale = 1.0
	_type_loop_player.play()


func _update_type_audio() -> void:
	if not _audio_enabled or _type_loop_player.stream == null:
		return

	var target_volume := -24.0
	var target_pitch := 1.0

	match _drone_type:
		DRONE_TYPE_PATROL:
			target_volume = lerpf(-24.0, -21.8, _alert_level)
			target_pitch = 0.98 + _alert_level * 0.04
		DRONE_TYPE_BLOCKADE:
			target_volume = lerpf(-21.5, -19.2, _alert_level)
			target_pitch = 0.92 + _alert_level * 0.03
		_:
			target_volume = lerpf(-21.0, -16.4, _alert_level)
			target_pitch = 1.03 + _alert_level * 0.11

	_type_loop_player.volume_db = lerpf(_type_loop_player.volume_db, target_volume, 0.14)
	_type_loop_player.pitch_scale = lerpf(_type_loop_player.pitch_scale, target_pitch, 0.12)


func _generate_type_loop_stream() -> AudioStreamWAV:
	match _drone_type:
		DRONE_TYPE_PATROL:
			return _generate_patrol_loop_stream()
		DRONE_TYPE_BLOCKADE:
			return _generate_blockade_loop_stream()
		_:
			return _generate_hunter_loop_stream()


func _generate_patrol_loop_stream() -> AudioStreamWAV:
	var duration := 1.6
	var sample_count := maxi(1, int(duration * DRONE_AUDIO_MIX_RATE))
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / DRONE_AUDIO_MIX_RATE
		var hover := sin(TAU * t * 84.0) * 0.045
		var rotor := sin(TAU * t * 126.0) * 0.038 * (0.55 + 0.45 * sin(TAU * t * 0.9))
		var pulse_phase := fmod(t * 1.25, 1.0)
		var pulse_env := pow(maxf(0.0, 1.0 - pulse_phase * 4.0), 2.5)
		var ping := sin(TAU * t * 860.0) * 0.024 * pulse_env
		var hiss := _hash_noise(float(i) * 0.52 + 5.0) * 0.012 * (0.45 + 0.55 * pulse_env)
		samples[i] = clampf((hover + rotor + ping + hiss) * 0.82, -1.0, 1.0)

	return _samples_to_stream(samples, true)


func _generate_hunter_loop_stream() -> AudioStreamWAV:
	var duration := 1.24
	var sample_count := maxi(1, int(duration * DRONE_AUDIO_MIX_RATE))
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / DRONE_AUDIO_MIX_RATE
		var sweep := fmod(t * 2.35, 1.0)
		var sweep_freq := lerpf(168.0, 244.0, sweep)
		var buzz := sin(TAU * t * sweep_freq) * 0.052
		buzz += sin(TAU * t * sweep_freq * 2.18) * 0.03
		var lock_env := pow(maxf(0.0, 1.0 - fmod(t * 3.9, 1.0) * 4.4), 2.1)
		var click := _hash_noise(float(i) * 1.74 + 13.0) * 0.024 * lock_env
		var whine := sin(TAU * t * 720.0) * 0.02 * pow(sin(sweep * PI), 1.6)
		samples[i] = clampf((buzz + click + whine) * 0.9, -1.0, 1.0)

	return _samples_to_stream(samples, true)


func _generate_blockade_loop_stream() -> AudioStreamWAV:
	var duration := 1.9
	var sample_count := maxi(1, int(duration * DRONE_AUDIO_MIX_RATE))
	var samples := PackedFloat32Array()
	samples.resize(sample_count)

	for i in range(sample_count):
		var t := float(i) / DRONE_AUDIO_MIX_RATE
		var rumble := sin(TAU * t * 58.0) * 0.072
		var heavy := sin(TAU * t * 86.0) * 0.042 * (0.7 + 0.3 * sin(TAU * t * 0.34))
		var sweep_phase := fmod(t * 1.1, 1.0)
		var sweep_env := pow(maxf(0.0, 1.0 - sweep_phase * 2.8), 2.3)
		var scan := sin(TAU * t * 118.0) * 0.038 * sweep_env
		var servo := _hash_noise(float(i) * 0.44 + 29.0) * 0.014 * (0.4 + 0.6 * sweep_env)
		samples[i] = clampf((rumble + heavy + scan + servo) * 0.84, -1.0, 1.0)

	return _samples_to_stream(samples, true)


func _samples_to_stream(samples: PackedFloat32Array, loop: bool) -> AudioStreamWAV:
	var data := PackedByteArray()
	data.resize(samples.size() * 2)

	for i in range(samples.size()):
		data.encode_s16(i * 2, int(clampf(samples[i], -1.0, 1.0) * 32767.0))

	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = DRONE_AUDIO_MIX_RATE
	stream.stereo = false
	stream.data = data

	if loop:
		stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
		stream.loop_begin = 0
		stream.loop_end = samples.size()

	return stream


func _hash_noise(seed: float) -> float:
	return _fraction(sin(seed * 12.9898 + 78.233) * 43758.5453) * 2.0 - 1.0


func _fraction(value: float) -> float:
	return value - floor(value)


func _is_headless_runtime() -> bool:
	return OS.has_feature("headless") or DisplayServer.get_name() == "headless"


func _has_line_of_sight_to_player(player_position: Vector3) -> bool:
	if not line_of_sight_required:
		return true

	var space_state := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.create(
			global_position + Vector3.UP * 0.25,
			player_position + Vector3.UP * 0.4
		)
	ray_query.exclude = [self, _hitbox]
	ray_query.collision_mask = PLAYER_LINE_OF_SIGHT_MASK

	var hit := space_state.intersect_ray(ray_query)
	return hit.is_empty() or hit.get("collider") == _player


func force_break_chase(disable_duration: float) -> void:
	_is_chasing = false
	_chase_timer = 0.0
	_chase_disabled_time = maxf(_chase_disabled_time, disable_duration)
	_alert_level = 0.0
	_mark_path_dirty()


func configure(point_a: Vector3, point_b: Vector3, new_speed: float, behavior: Dictionary = {}) -> void:
	_point_a = point_a
	_point_b = point_b
	_target = point_b
	speed = new_speed
	can_chase = behavior.get("can_chase", can_chase)
	_drone_type = _sanitize_drone_type(StringName(String(behavior.get(
			"drone_type",
			DRONE_TYPE_HUNTER if can_chase else DRONE_TYPE_PATROL
		))))
	detection_radius = behavior.get("detection_radius", detection_radius)
	chase_speed_multiplier = behavior.get("chase_speed_multiplier", chase_speed_multiplier)
	chase_lock_time = behavior.get("chase_lock_time", chase_lock_time)
	chase_forget_distance = behavior.get("chase_forget_distance", chase_forget_distance)
	line_of_sight_required = behavior.get("line_of_sight_required", line_of_sight_required)
	_is_chasing = false
	_chase_timer = 0.0
	_alert_level = 0.0
	_chase_disabled_time = 0.0
	_navigation_provider = get_parent()
	_path_points = PackedVector3Array()
	_path_index = 0
	_path_refresh_remaining = 0.0
	_has_cached_path_target = false
	_hover_height = point_a.y
	_support_alert_cooldown = 0.0
	velocity = Vector3.ZERO
	global_position = point_a
	_apply_visual_profile()
	_mark_path_dirty()


func _on_hitbox_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		player_hit.emit()
