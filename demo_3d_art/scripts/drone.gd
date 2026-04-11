extends Area3D

signal player_hit

@export var speed: float = 4.0
@export var can_chase: bool = false
@export var detection_radius: float = 5.8
@export var chase_speed_multiplier: float = 1.45
@export var chase_lock_time: float = 1.9
@export var chase_forget_distance: float = 9.5
@export var line_of_sight_required: bool = true

var _point_a := Vector3.ZERO
var _point_b := Vector3.ZERO
var _target := Vector3.ZERO
var _age := 0.0
var _is_chasing := false
var _chase_timer := 0.0
var _alert_level := 0.0
var _player: Node3D
var _chase_disabled_time := 0.0

@onready var _visual: Node3D = $Visual
@onready var _rotor_left: Node3D = $Visual/RotorLeftPivot
@onready var _rotor_right: Node3D = $Visual/RotorRightPivot
@onready var _danger_ring: Node3D = $Visual/DangerRing
@onready var _signal_light: OmniLight3D = $Visual/OmniLight3D


func _ready() -> void:
	_player = get_tree().get_first_node_in_group(&"player") as Node3D
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	_update_chase_state(delta)

	var active_target := _get_active_target()
	var active_speed := _get_active_speed()
	global_position = global_position.move_toward(active_target, active_speed * delta)

	if not _is_chasing and global_position.distance_to(_target) < 0.15:
		_target = _point_a if _target == _point_b else _point_b

	var flat_target := Vector3(active_target.x, global_position.y, active_target.z)
	if global_position.distance_to(flat_target) > 0.05:
		look_at(flat_target, Vector3.UP)

	_visual.position.y = 0.08 + sin(_age * (7.0 + _alert_level * 3.0)) * (0.05 + _alert_level * 0.015)
	_rotor_left.rotate_y((18.0 + _alert_level * 10.0) * delta)
	_rotor_right.rotate_y((-18.0 - _alert_level * 10.0) * delta)
	_danger_ring.rotate_y((2.8 + _alert_level * 2.4) * delta)

	var danger_pulse := 0.5 + 0.5 * sin(_age * (5.2 + _alert_level * 4.0))
	var patrol_scale := 0.94 + 0.1 * danger_pulse
	var chase_scale := 1.1 + 0.16 * danger_pulse
	_danger_ring.scale = Vector3.ONE * lerpf(patrol_scale, chase_scale, _alert_level)

	var patrol_light := 0.46 + 0.35 * (0.5 + 0.5 * sin(_age * 8.6))
	var chase_light := 0.9 + 0.5 * (0.5 + 0.5 * sin(_age * 12.5))
	_signal_light.light_energy = lerpf(patrol_light, chase_light, _alert_level)


func _update_chase_state(delta: float) -> void:
	if not can_chase:
		_alert_level = move_toward(_alert_level, 0.0, delta * 2.2)
		return

	if _chase_disabled_time > 0.0:
		_chase_disabled_time = maxf(0.0, _chase_disabled_time - delta)
		_is_chasing = false
		_alert_level = move_toward(_alert_level, 0.0, delta * 3.6)
		return

	if not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group(&"player") as Node3D
		_alert_level = move_toward(_alert_level, 0.0, delta * 2.2)
		return

	var player_position := _player.global_position
	var planar_distance := Vector2(player_position.x - global_position.x, player_position.z - global_position.z).length()
	var has_line_of_sight := _has_line_of_sight_to_player(player_position)

	if planar_distance <= detection_radius and has_line_of_sight:
		_is_chasing = true
		_chase_timer = chase_lock_time
	elif _is_chasing:
		_chase_timer -= delta * (2.1 if not has_line_of_sight else 1.0)
		if _chase_timer <= 0.0 or planar_distance >= chase_forget_distance:
			_is_chasing = false

	_alert_level = move_toward(_alert_level, 1.0 if _is_chasing else 0.0, delta * 2.8)


func _get_active_target() -> Vector3:
	if _is_chasing and is_instance_valid(_player):
		return Vector3(_player.global_position.x, global_position.y, _player.global_position.z)

	return _target


func _get_active_speed() -> float:
	return speed * chase_speed_multiplier if _is_chasing else speed


func _has_line_of_sight_to_player(player_position: Vector3) -> bool:
	if not line_of_sight_required:
		return true

	var space_state := get_world_3d().direct_space_state
	var ray_query := PhysicsRayQueryParameters3D.create(
		global_position + Vector3.UP * 0.25,
		player_position + Vector3.UP * 0.4
	)
	ray_query.exclude = [self]
	ray_query.collision_mask = 1

	var hit := space_state.intersect_ray(ray_query)
	return hit.is_empty() or hit.get("collider") == _player


func force_break_chase(disable_duration: float) -> void:
	_is_chasing = false
	_chase_timer = 0.0
	_chase_disabled_time = maxf(_chase_disabled_time, disable_duration)
	_alert_level = 0.0


func configure(point_a: Vector3, point_b: Vector3, new_speed: float, behavior: Dictionary = {}) -> void:
	_point_a = point_a
	_point_b = point_b
	_target = point_b
	speed = new_speed
	can_chase = behavior.get("can_chase", can_chase)
	detection_radius = behavior.get("detection_radius", detection_radius)
	chase_speed_multiplier = behavior.get("chase_speed_multiplier", chase_speed_multiplier)
	chase_lock_time = behavior.get("chase_lock_time", chase_lock_time)
	chase_forget_distance = behavior.get("chase_forget_distance", chase_forget_distance)
	line_of_sight_required = behavior.get("line_of_sight_required", line_of_sight_required)
	_is_chasing = false
	_chase_timer = 0.0
	_alert_level = 0.0
	_chase_disabled_time = 0.0
	global_position = point_a


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		player_hit.emit()
