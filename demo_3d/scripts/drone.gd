extends Area3D

signal player_hit

@export var speed: float = 4.0

var _point_a := Vector3.ZERO
var _point_b := Vector3.ZERO
var _target := Vector3.ZERO

@onready var _visual: Node3D = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _physics_process(delta: float) -> void:
	global_position = global_position.move_toward(_target, speed * delta)

	if global_position.distance_to(_target) < 0.15:
		_target = _point_a if _target == _point_b else _point_b

	var flat_target := Vector3(_target.x, global_position.y, _target.z)
	if global_position.distance_to(flat_target) > 0.05:
		look_at(flat_target, Vector3.UP)

	_visual.rotate_z(7.0 * delta)


func configure(point_a: Vector3, point_b: Vector3, new_speed: float) -> void:
	_point_a = point_a
	_point_b = point_b
	_target = point_b
	speed = new_speed
	global_position = point_a


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		player_hit.emit()
