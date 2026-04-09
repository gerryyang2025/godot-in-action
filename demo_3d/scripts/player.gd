extends CharacterBody3D

signal fell_out

@export var speed: float = 8.0
@export var acceleration: float = 28.0
@export var jump_velocity: float = 8.5
@export var fall_limit: float = -8.0

var _is_active := false
var _is_invulnerable := false
var _invulnerable_time := 0.0
var _gravity := 18.0

@onready var _visual: Node3D = $Visual
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2.4
	set_active(false)


func _physics_process(delta: float) -> void:
	_update_invulnerability(delta)

	if not _is_active:
		return

	_apply_movement(delta)
	move_and_slide()

	if global_position.y < fall_limit:
		set_active(false)
		fell_out.emit()


func start(start_position: Vector3) -> void:
	global_position = start_position
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	_is_invulnerable = false
	_invulnerable_time = 0.0
	_visual.visible = true
	set_active(true)


func set_active(is_active: bool) -> void:
	_is_active = is_active
	visible = is_active
	_collision_shape.set_deferred(&"disabled", not is_active)


func start_invulnerability(duration: float) -> void:
	_is_invulnerable = true
	_invulnerable_time = duration


func is_invulnerable() -> bool:
	return _is_invulnerable


func _apply_movement(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= _gravity * delta
	elif Input.is_action_just_pressed(&"jump"):
		velocity.y = jump_velocity

	var input_vector := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var direction := Vector3(input_vector.x, 0.0, input_vector.y).normalized()
	var target_velocity := direction * speed

	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if direction.length_squared() > 0.01:
		var target_yaw := atan2(-direction.x, -direction.z)
		rotation.y = lerp_angle(rotation.y, target_yaw, minf(1.0, 12.0 * delta))


func _update_invulnerability(delta: float) -> void:
	if not _is_invulnerable:
		return

	_invulnerable_time -= delta
	_visual.visible = int(Time.get_ticks_msec() / 120) % 2 == 0

	if _invulnerable_time <= 0.0:
		_is_invulnerable = false
		_visual.visible = true
