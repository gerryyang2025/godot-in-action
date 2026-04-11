extends CharacterBody3D

signal fell_out

const SCRAMBLE_RING_DURATION := 0.52
const SCRAMBLE_SHELL_DURATION := 0.34
const SCRAMBLE_RING_START_SCALE := 0.18
const SCRAMBLE_RING_END_SCALE := 18.0
const SCRAMBLE_SHELL_START_SCALE := 0.45
const SCRAMBLE_SHELL_END_SCALE := 2.6
const SCRAMBLE_CORE_BOOST := 1.9

@export var speed: float = 8.0
@export var acceleration: float = 28.0
@export var jump_velocity: float = 8.5
@export var fall_limit: float = -8.0

var _is_active := false
var _is_invulnerable := false
var _invulnerable_time := 0.0
var _gravity := 18.0
var _visual_age := 0.0
var _scramble_ring_age := SCRAMBLE_RING_DURATION
var _scramble_shell_age := SCRAMBLE_SHELL_DURATION

@onready var _visual: Node3D = $Visual
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _thruster_left: Node3D = $Visual/ThrusterLeft
@onready var _thruster_right: Node3D = $Visual/ThrusterRight
@onready var _core_light: OmniLight3D = $Visual/CoreLight
@onready var _scramble_ring: MeshInstance3D = $Visual/ScrambleRing
@onready var _scramble_shell: MeshInstance3D = $Visual/ScrambleShell


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity") * 2.4
	_reset_visuals()
	set_active(false)


func _physics_process(delta: float) -> void:
	_visual_age += delta
	_update_invulnerability(delta)

	if not _is_active:
		return

	_apply_movement(delta)
	move_and_slide()
	_update_visuals(delta)

	if global_position.y < fall_limit:
		set_active(false)
		fell_out.emit()


func start(start_position: Vector3) -> void:
	global_position = start_position
	rotation = Vector3.ZERO
	velocity = Vector3.ZERO
	_is_invulnerable = false
	_invulnerable_time = 0.0
	_visual_age = 0.0
	_reset_visuals()
	_visual.visible = true
	set_active(true)


func set_active(is_active: bool) -> void:
	_is_active = is_active
	visible = is_active
	_collision_shape.set_deferred(&"disabled", not is_active)
	if not is_active:
		_reset_visuals()


func start_invulnerability(duration: float) -> void:
	_is_invulnerable = true
	_invulnerable_time = duration


func is_invulnerable() -> bool:
	return _is_invulnerable


func play_scramble_pulse() -> void:
	if not _is_active:
		return

	_scramble_ring_age = 0.0
	_scramble_shell_age = 0.0
	_scramble_ring.visible = true
	_scramble_shell.visible = true
	_scramble_ring.scale = Vector3(SCRAMBLE_RING_START_SCALE, 1.0, SCRAMBLE_RING_START_SCALE)
	_scramble_shell.scale = Vector3.ONE * SCRAMBLE_SHELL_START_SCALE
	_scramble_ring.transparency = 0.0
	_scramble_shell.transparency = 0.0


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


func _update_visuals(delta: float) -> void:
	var planar_speed := Vector2(velocity.x, velocity.z).length()
	var move_ratio := clampf(planar_speed / maxf(speed, 0.001), 0.0, 1.0)
	var bob := sin(_visual_age * (4.0 + move_ratio * 10.0)) * (0.015 + move_ratio * 0.03)

	_visual.position.y = 0.05 + bob
	_visual.rotation.x = lerp(_visual.rotation.x, deg_to_rad(clampf(velocity.z * 1.8, -6.0, 6.0)), minf(1.0, 8.0 * delta))
	_visual.rotation.z = lerp(_visual.rotation.z, deg_to_rad(clampf(-velocity.x * 2.1, -8.0, 8.0)), minf(1.0, 8.0 * delta))

	var thruster_scale := 0.78 + move_ratio * 0.7
	if not is_on_floor():
		thruster_scale += 0.12

	_thruster_left.scale.z = thruster_scale
	_thruster_right.scale.z = thruster_scale
	var base_core_light_energy := 0.7 + move_ratio * 0.55 + (0.5 + 0.5 * sin(_visual_age * 11.0)) * 0.3
	_update_scramble_visuals(delta, base_core_light_energy)


func _update_scramble_visuals(delta: float, base_core_light_energy: float) -> void:
	var core_boost := 0.0

	if _scramble_ring_age < SCRAMBLE_RING_DURATION:
		_scramble_ring_age = minf(SCRAMBLE_RING_DURATION, _scramble_ring_age + delta)
		var ring_t := _scramble_ring_age / SCRAMBLE_RING_DURATION
		var ring_expansion := 1.0 - pow(1.0 - ring_t, 2.6)
		var ring_scale := lerpf(SCRAMBLE_RING_START_SCALE, SCRAMBLE_RING_END_SCALE, ring_expansion)
		_scramble_ring.visible = true
		_scramble_ring.scale = Vector3(ring_scale, 1.0, ring_scale)
		_scramble_ring.transparency = clampf(pow(ring_t, 0.75), 0.0, 1.0)
		core_boost = maxf(core_boost, pow(1.0 - ring_t, 0.45) * SCRAMBLE_CORE_BOOST)
	else:
		_scramble_ring.visible = false
		_scramble_ring.transparency = 1.0

	if _scramble_shell_age < SCRAMBLE_SHELL_DURATION:
		_scramble_shell_age = minf(SCRAMBLE_SHELL_DURATION, _scramble_shell_age + delta)
		var shell_t := _scramble_shell_age / SCRAMBLE_SHELL_DURATION
		var shell_expansion := 1.0 - pow(1.0 - shell_t, 2.0)
		var shell_scale := lerpf(SCRAMBLE_SHELL_START_SCALE, SCRAMBLE_SHELL_END_SCALE, shell_expansion)
		_scramble_shell.visible = true
		_scramble_shell.scale = Vector3.ONE * shell_scale
		_scramble_shell.transparency = clampf(pow(shell_t, 0.68), 0.0, 1.0)
		_scramble_shell.rotate_y(delta * 6.0)
		core_boost = maxf(core_boost, pow(1.0 - shell_t, 0.6) * SCRAMBLE_CORE_BOOST * 0.55)
	else:
		_scramble_shell.visible = false
		_scramble_shell.transparency = 1.0

	_core_light.light_energy = base_core_light_energy + core_boost


func _reset_visuals() -> void:
	_visual.position = Vector3.ZERO
	_visual.rotation = Vector3.ZERO
	_thruster_left.scale = Vector3.ONE
	_thruster_right.scale = Vector3.ONE
	_scramble_ring_age = SCRAMBLE_RING_DURATION
	_scramble_shell_age = SCRAMBLE_SHELL_DURATION
	_scramble_ring.visible = false
	_scramble_shell.visible = false
	_scramble_ring.scale = Vector3.ONE
	_scramble_shell.scale = Vector3.ONE
	_scramble_ring.transparency = 1.0
	_scramble_shell.transparency = 1.0
	_scramble_shell.rotation = Vector3.ZERO
	_core_light.light_energy = 0.9
