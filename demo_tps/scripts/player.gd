extends CharacterBody3D

signal health_changed(current_health: int, max_health: int)
signal died
signal fell_out
signal mouse_capture_changed(captured: bool)

const BULLET_SCENE := preload("res://scenes/bullet.tscn")
const HITBOX_LAYER_MASK := 128
const MOUSE_SENSITIVITY := 0.0024
const CAMERA_PITCH_MIN := deg_to_rad(-65.0)
const CAMERA_PITCH_MAX := deg_to_rad(40.0)
const CAMERA_DEFAULT_PITCH := deg_to_rad(-14.0)
const CAMERA_FAR_OFFSET := Vector3(0.0, 1.15, 5.8)
const CAMERA_AIM_OFFSET := Vector3(0.72, 0.38, 2.85)
const CAMERA_FAR_FOV := 72.0
const CAMERA_AIM_FOV := 58.0
const CAMERA_LERP_SPEED := 10.0
const AIM_TAP_THRESHOLD := 0.22
const STARTING_INVULNERABILITY_TIME := 3.0
const FOOTSTEP_INTERVAL := 0.42

@export var move_speed: float = 7.5
@export var aim_move_speed: float = 5.7
@export var acceleration: float = 28.0
@export var jump_velocity: float = 6.2
@export var jump_cut_gravity_multiplier: float = 1.35
@export var fall_gravity_multiplier: float = 1.7
@export var turn_speed: float = 12.0
@export var shoot_cooldown: float = 0.22
@export var max_health: int = 100
@export var fall_limit: float = -8.0

var current_health: int = max_health

var _gravity := 9.8
var _controls_enabled := false
var _aiming := false
var _toggled_aim := false
var _aim_press_time := 0.0
var _shoot_timer := 0.0
var _invulnerability_timer := 0.0
var _muzzle_flash_timer := 0.0
var _mouse_captured := false
var _step_timer := 0.0
var _was_on_floor := false

@onready var _visual: Node3D = $Visual
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _hitboxes_root: Node3D = $Hitboxes
@onready var _camera_yaw: Node3D = $CameraYaw
@onready var _camera_pitch: Node3D = $CameraYaw/CameraPitch
@onready var _camera_shake = $CameraYaw/CameraPitch/ShakePivot
@onready var _camera: Camera3D = $CameraYaw/CameraPitch/ShakePivot/Camera3D
@onready var _muzzle: Marker3D = $Visual/Gun/Muzzle
@onready var _muzzle_flash: MeshInstance3D = $Visual/Gun/Muzzle/MuzzleFlash
@onready var _crosshair: TextureRect = $CanvasLayer/Crosshair
@onready var _hit_flash: ColorRect = $CanvasLayer/HitFlash
@onready var _jump_audio: AudioStreamPlayer3D = $JumpAudio
@onready var _land_audio: AudioStreamPlayer3D = $LandAudio
@onready var _step_audio: AudioStreamPlayer3D = $StepAudio
@onready var _shoot_audio: AudioStreamPlayer3D = $Visual/Gun/Muzzle/ShootAudio


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	_camera.make_current()
	_was_on_floor = is_on_floor()
	show_preview(global_position)


func _process(delta: float) -> void:
	_shoot_timer = maxf(0.0, _shoot_timer - delta)
	_muzzle_flash_timer = maxf(0.0, _muzzle_flash_timer - delta)
	_muzzle_flash.visible = _muzzle_flash_timer > 0.0
	_update_hit_feedback(delta)
	_update_aim_state(delta)
	_update_camera(delta)


func _physics_process(delta: float) -> void:
	_invulnerability_timer = maxf(0.0, _invulnerability_timer - delta)

	if not _controls_enabled:
		velocity = Vector3.ZERO
		_step_timer = 0.0
		_was_on_floor = is_on_floor()
		return

	var was_on_floor := is_on_floor()
	var vertical_velocity_before_move := velocity.y
	_apply_movement(delta)

	if _aiming and _mouse_captured and Input.is_action_pressed(&"shoot") and _shoot_timer <= 0.0:
		_fire()

	move_and_slide()
	var on_floor := is_on_floor()
	if not was_on_floor and on_floor and vertical_velocity_before_move < -3.2:
		_play_land_feedback()
	_update_footsteps(delta, on_floor)
	_was_on_floor = on_floor

	if global_position.y < fall_limit:
		stop_round()
		fell_out.emit()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"toggle_mouse_capture"):
		set_mouse_captured(not _mouse_captured)
		get_viewport().set_input_as_handled()
		return

	if not _controls_enabled:
		return

	if not _mouse_captured and (event.is_action_pressed(&"aim") or event.is_action_pressed(&"shoot")):
		set_mouse_captured(true)
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton and event.pressed and not _mouse_captured:
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_RIGHT:
			set_mouse_captured(true)
			get_viewport().set_input_as_handled()
			return

	if event is InputEventMouseMotion and _mouse_captured:
		var sensitivity := MOUSE_SENSITIVITY * (0.7 if _aiming else 1.0)
		_camera_yaw.rotate_y(-event.screen_relative.x * sensitivity)
		_camera_pitch.rotation.x = clampf(
			_camera_pitch.rotation.x - event.screen_relative.y * sensitivity,
			CAMERA_PITCH_MIN,
			CAMERA_PITCH_MAX
		)


func reset_for_round(start_position: Vector3) -> void:
	global_position = start_position
	velocity = Vector3.ZERO
	current_health = max_health
	_controls_enabled = true
	_toggled_aim = false
	_aim_press_time = 0.0
	_shoot_timer = 0.0
	_invulnerability_timer = STARTING_INVULNERABILITY_TIME
	_step_timer = 0.0
	_set_hit_flash_alpha(0.0)
	_visual.visible = true
	_visual.rotation = Vector3.ZERO
	_camera_yaw.rotation = Vector3.ZERO
	_camera_pitch.rotation = Vector3(CAMERA_DEFAULT_PITCH, 0.0, 0.0)
	_set_aiming(false)
	_camera_shake.reset_shake()
	_update_camera_immediate()
	_collision_shape.set_deferred(&"disabled", false)
	set_mouse_captured(true)
	_was_on_floor = false
	health_changed.emit(current_health, max_health)


func show_preview(start_position: Vector3) -> void:
	global_position = start_position
	velocity = Vector3.ZERO
	current_health = max_health
	_controls_enabled = false
	_toggled_aim = false
	_aim_press_time = 0.0
	_shoot_timer = 0.0
	_invulnerability_timer = 0.0
	_step_timer = 0.0
	_set_hit_flash_alpha(0.0)
	_visual.visible = true
	_visual.rotation = Vector3.ZERO
	_camera_yaw.rotation = Vector3.ZERO
	_camera_pitch.rotation = Vector3(CAMERA_DEFAULT_PITCH, 0.0, 0.0)
	_set_aiming(false)
	_camera_shake.reset_shake()
	_update_camera_immediate()
	set_mouse_captured(false)
	_was_on_floor = false
	health_changed.emit(current_health, max_health)


func stop_round() -> void:
	_controls_enabled = false
	_toggled_aim = false
	_aim_press_time = 0.0
	_step_timer = 0.0
	velocity = Vector3.ZERO
	_set_aiming(false)
	set_mouse_captured(false)


func take_hit(
	hit_zone: StringName,
	damage: int,
	_hit_direction: Vector3 = Vector3.ZERO,
	_hit_position: Vector3 = Vector3.ZERO,
	fatal: bool = false
) -> void:
	if not _controls_enabled or _invulnerability_timer > 0.0:
		return

	var applied_damage := damage
	if fatal or hit_zone == &"head":
		applied_damage = current_health

	current_health = max(0, current_health - applied_damage)
	_set_hit_flash_alpha(0.58 if applied_damage >= 40 else 0.42)
	var trauma := 0.6 if fatal or hit_zone == &"head" else (0.48 if hit_zone == &"torso" else 0.32)
	_add_camera_trauma(trauma)
	health_changed.emit(current_health, max_health)

	if current_health <= 0:
		stop_round()
		died.emit()


func take_damage(amount: int = 1) -> void:
	take_hit(&"torso", amount)


func set_mouse_captured(captured: bool) -> void:
	if not _controls_enabled:
		captured = false

	if _mouse_captured == captured:
		return

	_mouse_captured = captured
	if DisplayServer.get_name() != "headless":
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE)
	mouse_capture_changed.emit(_mouse_captured)


func _apply_movement(delta: float) -> void:
	if not is_on_floor():
		var gravity_scale := 1.0
		if velocity.y > 0.0 and not Input.is_action_pressed(&"jump"):
			gravity_scale = jump_cut_gravity_multiplier
		elif velocity.y < 0.0:
			gravity_scale = fall_gravity_multiplier
		velocity.y -= _gravity * gravity_scale * delta
	elif Input.is_action_just_pressed(&"jump") and _mouse_captured:
		velocity.y = jump_velocity
		_play_jump_feedback()

	var input_vector := Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")
	var camera_basis := _camera.global_transform.basis
	var right := camera_basis.x
	var forward := -camera_basis.z
	right.y = 0.0
	forward.y = 0.0
	right = right.normalized()
	forward = forward.normalized()

	var move_direction := (right * input_vector.x) + (forward * -input_vector.y)
	var direction := move_direction.normalized() if move_direction.length_squared() > 0.0 else Vector3.ZERO
	var target_speed := aim_move_speed if _aiming else move_speed
	var target_velocity := direction * target_speed

	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if _aiming:
		_visual.rotation.y = lerp_angle(
			_visual.rotation.y,
			_camera_yaw.rotation.y,
			minf(1.0, turn_speed * delta)
		)
	elif direction.length_squared() > 0.01:
		var target_yaw := atan2(-direction.x, -direction.z)
		_visual.rotation.y = lerp_angle(
			_visual.rotation.y,
			target_yaw,
			minf(1.0, turn_speed * delta)
		)


func _update_aim_state(delta: float) -> void:
	if not _controls_enabled or not _mouse_captured:
		_aim_press_time = 0.0
		_set_aiming(false)
		return

	if Input.is_action_just_pressed(&"aim"):
		_aim_press_time = 0.0

	if Input.is_action_pressed(&"aim"):
		_aim_press_time += delta

	if Input.is_action_just_released(&"aim"):
		if _aim_press_time <= AIM_TAP_THRESHOLD:
			_toggled_aim = not _toggled_aim
		_aim_press_time = 0.0

	var holding_aim := Input.is_action_pressed(&"aim") and _aim_press_time > AIM_TAP_THRESHOLD and not _toggled_aim
	_set_aiming(_toggled_aim or holding_aim)


func _set_aiming(value: bool) -> void:
	_aiming = value
	_crosshair.visible = value and _controls_enabled


func _update_camera(delta: float) -> void:
	var target_offset := CAMERA_AIM_OFFSET if _aiming else CAMERA_FAR_OFFSET
	var target_fov := CAMERA_AIM_FOV if _aiming else CAMERA_FAR_FOV
	var weight := minf(1.0, CAMERA_LERP_SPEED * delta)
	_camera.position = _camera.position.lerp(target_offset, weight)
	_camera.fov = lerpf(_camera.fov, target_fov, weight)


func _update_camera_immediate() -> void:
	_camera.position = CAMERA_AIM_OFFSET if _aiming else CAMERA_FAR_OFFSET
	_camera.fov = CAMERA_AIM_FOV if _aiming else CAMERA_FAR_FOV


func _update_hit_feedback(delta: float) -> void:
	if _invulnerability_timer > 0.0:
		_visual.visible = int(Time.get_ticks_msec() / 90) % 2 == 0
	else:
		_visual.visible = true

	_set_hit_flash_alpha(move_toward(_hit_flash.color.a, 0.0, delta * 1.8))


func _fire() -> void:
	var viewport_center := get_viewport().get_visible_rect().size * 0.5
	var ray_from := _camera.project_ray_origin(viewport_center)
	var ray_dir := _camera.project_ray_normal(viewport_center)
	var ray_to := ray_from + ray_dir * 200.0
	var query := PhysicsRayQueryParameters3D.create(ray_from, ray_to, 1 | HITBOX_LAYER_MASK, get_hitbox_exclusions())
	query.collide_with_areas = true
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	var hit_position := ray_to
	if not collision.is_empty():
		hit_position = collision.position

	var muzzle_position := _muzzle.global_position
	var shoot_direction := (hit_position - muzzle_position).normalized()
	var bullet = BULLET_SCENE.instantiate()
	get_tree().current_scene.add_child(bullet)
	bullet.configure(muzzle_position, shoot_direction, self)

	_muzzle_flash_timer = 0.06
	_shoot_timer = shoot_cooldown
	_shoot_audio.play()
	_add_camera_trauma(0.18)


func get_hitbox_exclusions() -> Array:
	var exclude: Array = [self]
	for hitbox in _hitboxes_root.get_children():
		exclude.append(hitbox)
	return exclude


func _set_hit_flash_alpha(alpha: float) -> void:
	var color := _hit_flash.color
	color.a = alpha
	_hit_flash.color = color


func _play_jump_feedback() -> void:
	_jump_audio.play()
	_add_camera_trauma(0.12)


func _play_land_feedback() -> void:
	_land_audio.play()
	_add_camera_trauma(0.2)


func _update_footsteps(delta: float, on_floor: bool) -> void:
	var horizontal_speed := Vector2(velocity.x, velocity.z).length()
	if not on_floor or horizontal_speed < 1.2 or not _mouse_captured:
		_step_timer = 0.0
		return

	_step_timer -= delta
	if _step_timer > 0.0:
		return

	_step_audio.pitch_scale = randf_range(0.96, 1.04)
	_step_audio.play()
	var cadence := FOOTSTEP_INTERVAL
	if _aiming:
		cadence += 0.08
	cadence *= clampf(move_speed / maxf(horizontal_speed, 0.01), 0.68, 1.18)
	_step_timer = cadence


func _add_camera_trauma(amount: float) -> void:
	_camera_shake.add_trauma(amount)
