extends Area3D

signal player_hit

@export var speed: float = 4.0

var _point_a := Vector3.ZERO
var _point_b := Vector3.ZERO
var _target := Vector3.ZERO
var _age := 0.0

@onready var _visual: Node3D = $Visual
@onready var _rotor_left: Node3D = $Visual/RotorLeftPivot
@onready var _rotor_right: Node3D = $Visual/RotorRightPivot
@onready var _danger_ring: Node3D = $Visual/DangerRing
@onready var _signal_light: OmniLight3D = $Visual/OmniLight3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	_age += delta
	global_position = global_position.move_toward(_target, speed * delta)

	if global_position.distance_to(_target) < 0.15:
		_target = _point_a if _target == _point_b else _point_b

	var flat_target := Vector3(_target.x, global_position.y, _target.z)
	if global_position.distance_to(flat_target) > 0.05:
		look_at(flat_target, Vector3.UP)

	_visual.position.y = 0.08 + sin(_age * 7.0) * 0.05
	_rotor_left.rotate_y(18.0 * delta)
	_rotor_right.rotate_y(-18.0 * delta)
	_danger_ring.rotate_y(2.8 * delta)
	_danger_ring.scale = Vector3.ONE * (0.94 + 0.1 * (0.5 + 0.5 * sin(_age * 5.2)))
	_signal_light.light_energy = 0.46 + 0.35 * (0.5 + 0.5 * sin(_age * 8.6))


func configure(point_a: Vector3, point_b: Vector3, new_speed: float) -> void:
	_point_a = point_a
	_point_b = point_b
	_target = point_b
	speed = new_speed
	global_position = point_a


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		player_hit.emit()
