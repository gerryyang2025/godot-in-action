extends CharacterBody3D

signal destroyed

const IMPACT_EFFECT_SCENE := preload("res://scenes/impact_effect.tscn")
const HITBOX_LAYER_MASK := 128
const ENEMY_MODEL_ALBEDO := preload("res://assets/reference/player/textures/player_robot_albedo.png")
const ENEMY_MODEL_NORMAL := preload("res://assets/reference/player/textures/player_robot_normal.png")
const ENEMY_MODEL_ORM := preload("res://assets/reference/player/textures/player_robot_orm.png")
const DEATH_FALL_DURATION := 0.34
const DEATH_HOLD_DURATION := 0.78
const DEATH_FADE_DURATION := 0.42
const MODEL_YAW_OFFSET := PI

enum State {
	PATROL,
	ALERT,
	AIM,
}

@export var patrol_speed: float = 3.2
@export var acceleration: float = 14.0
@export var detection_range: float = 16.0
@export var spot_time: float = 0.55
@export var target_memory_time: float = 0.75
@export var aim_time: float = 1.15
@export var telegraph_time: float = 0.48
@export var fire_cooldown: float = 2.6
@export var near_shot_spread: float = 0.28
@export var far_shot_spread: float = 1.15
@export var shot_miss_chance: float = 0.3
@export var min_fire_alignment: float = 0.9
@export var max_health: int = 100

var _gravity := 9.8
var _state := State.PATROL
var _player: Node3D = null
var _point_a := Vector3.ZERO
var _point_b := Vector3.ZERO
var _patrol_target := Vector3.ZERO
var _heading_to_b := true
var _spot_timer := 0.0
var _target_memory_timer := 0.0
var _aim_timer := 0.0
var _cooldown_timer := 0.0
var _beam_timer := 0.0
var _health := max_health
var _dead := false
var _charge_started := false
var _charge_ratio := 0.0
var _muzzle_flash_timer := 0.0
var _death_elapsed := 0.0
var _death_landed := false
var _death_start_rotation := Vector3.ZERO
var _death_target_rotation := Vector3.ZERO
var _death_start_position := Vector3.ZERO
var _death_target_position := Vector3.ZERO
var _death_light_energy := 0.0
var _last_seen_position := Vector3.ZERO
var _fade_materials: Array[StandardMaterial3D] = []

@onready var _visual: Node3D = $Visual
@onready var _model_root: Node3D = $Visual/Model
@onready var _collision_shape: CollisionShape3D = $CollisionShape3D
@onready var _hitboxes_root: Node3D = $Hitboxes
@onready var _muzzle: Marker3D = $Visual/Model/Robot_Skeleton/Skeleton3D/RightHandGrip/Gun/Muzzle
@onready var _charge_orb: MeshInstance3D = $Visual/Model/Robot_Skeleton/Skeleton3D/RightHandGrip/Gun/Muzzle/ChargeOrb
@onready var _muzzle_flash: MeshInstance3D = $Visual/Model/Robot_Skeleton/Skeleton3D/RightHandGrip/Gun/Muzzle/MuzzleFlash
@onready var _state_light: OmniLight3D = $Visual/StateLight
@onready var _charge_audio: AudioStreamPlayer3D = $Visual/ChargeAudio
@onready var _shoot_audio: AudioStreamPlayer3D = $Visual/ShootAudio
@onready var _hit_audio: AudioStreamPlayer3D = $Visual/HitAudio
@onready var _explosion_audio: AudioStreamPlayer3D = $Visual/ExplosionAudio
@onready var _beam_pivot: Node3D = $BeamPivot
@onready var _beam_mesh: MeshInstance3D = $BeamPivot/Beam


func _ready() -> void:
	_gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
	_aim_timer = aim_time
	_beam_pivot.visible = false
	_charge_orb.visible = false
	_muzzle_flash.visible = false
	_setup_enemy_model()
	_capture_unique_materials()


func configure(point_a: Vector3, point_b: Vector3, player: Node3D) -> void:
	_point_a = point_a
	_point_b = point_b
	_player = player
	_heading_to_b = true
	_patrol_target = _point_b
	_health = max_health
	_dead = false
	_state = State.PATROL
	_spot_timer = spot_time
	_target_memory_timer = 0.0
	_aim_timer = aim_time
	_cooldown_timer = 0.0
	_beam_timer = 0.0
	_muzzle_flash_timer = 0.0
	_charge_started = false
	_charge_ratio = 0.0
	_death_elapsed = 0.0
	_death_landed = false
	_last_seen_position = point_a
	global_position = point_a
	velocity = Vector3.ZERO
	_visual.rotation = Vector3.ZERO
	_visual.position = Vector3(0.0, 0.95, 0.0)
	_visual.visible = true
	_collision_shape.set_deferred(&"disabled", false)
	_beam_pivot.visible = false
	_charge_orb.visible = false
	_muzzle_flash.visible = false
	_set_fade_alpha(1.0)
	_set_hitboxes_enabled(true)
	_state_light.light_energy = 0.65


func _setup_enemy_model() -> void:
	_model_root.rotation.y = MODEL_YAW_OFFSET
	var model_material := StandardMaterial3D.new()
	model_material.transparency = BaseMaterial3D.TRANSPARENCY_DISABLED
	model_material.cull_mode = BaseMaterial3D.CULL_BACK
	model_material.albedo_texture = ENEMY_MODEL_ALBEDO
	model_material.albedo_color = Color(0.98, 0.82, 0.78, 1.0)
	model_material.normal_enabled = true
	model_material.normal_texture = ENEMY_MODEL_NORMAL
	model_material.orm_texture = ENEMY_MODEL_ORM
	model_material.metallic = 0.28
	model_material.roughness = 0.98

	for mesh in _collect_visual_meshes(_model_root):
		mesh.material_override = model_material


func _process(delta: float) -> void:
	if _dead:
		_update_death_sequence(delta)


func _physics_process(delta: float) -> void:
	if _dead:
		return

	_cooldown_timer = maxf(0.0, _cooldown_timer - delta)
	_muzzle_flash_timer = maxf(0.0, _muzzle_flash_timer - delta)
	_muzzle_flash.visible = _muzzle_flash_timer > 0.0
	_update_beam(delta)

	if not is_on_floor():
		velocity.y -= _gravity * delta
	else:
		velocity.y = minf(velocity.y, 0.0)

	var sees_player := _has_visible_player()
	if sees_player:
		_last_seen_position = _player.global_position
		_target_memory_timer = target_memory_time
	else:
		_target_memory_timer = maxf(0.0, _target_memory_timer - delta)

	if sees_player or _target_memory_timer > 0.0:
		velocity.x = move_toward(velocity.x, 0.0, acceleration * delta)
		velocity.z = move_toward(velocity.z, 0.0, acceleration * delta)
		_face_toward(_last_seen_position, delta)

		if sees_player:
			if _spot_timer > 0.0:
				_state = State.ALERT
				_spot_timer = maxf(0.0, _spot_timer - delta)
				_aim_timer = aim_time
				_stop_charge_telegraph()
			else:
				_state = State.AIM
				_aim_timer = maxf(0.0, _aim_timer - delta)
				_update_charge_state()
				if _aim_timer <= 0.0 and _cooldown_timer <= 0.0 and _is_facing_target(_last_seen_position):
					_fire()
					_aim_timer = aim_time
					_cooldown_timer = fire_cooldown
		else:
			_state = State.ALERT
			_spot_timer = minf(spot_time, _spot_timer + delta * 0.75)
			_aim_timer = aim_time
			_stop_charge_telegraph()
	else:
		_state = State.PATROL
		_spot_timer = spot_time
		_aim_timer = aim_time
		_stop_charge_telegraph()
		_patrol(delta)

	move_and_slide()
	_update_state_light()


func take_hit(
	hit_zone: StringName,
	damage: int,
	hit_direction: Vector3 = Vector3.ZERO,
	hit_position: Vector3 = Vector3.ZERO,
	fatal: bool = false
) -> void:
	if _dead:
		return

	var applied_damage := damage
	if fatal or hit_zone == &"head":
		applied_damage = _health

	_health = max(0, _health - applied_damage)
	if _health > 0:
		_hit_audio.play()
		_aim_timer = aim_time
		var impact_origin := hit_position if not hit_position.is_zero_approx() else global_position + Vector3.UP * (1.55 if hit_zone == &"head" else (0.95 if hit_zone == &"torso" else 0.38))
		var impact_size := 0.48 if hit_zone == &"torso" else 0.36
		_spawn_impact(impact_origin, Vector3.UP, Color(1.0, 0.7, 0.35), impact_size, 0.16, 1.6)
		_beam_timer = 0.05
		_beam_pivot.visible = false
		_stop_charge_telegraph()
		return

	_start_death_sequence(hit_direction)


func take_damage(amount: int = 1, hit_direction: Vector3 = Vector3.ZERO) -> void:
	take_hit(&"torso", amount, hit_direction)


func _patrol(delta: float) -> void:
	var to_target := _patrol_target - global_position
	to_target.y = 0.0
	if to_target.length() < 0.65:
		_heading_to_b = not _heading_to_b
		_patrol_target = _point_b if _heading_to_b else _point_a
		to_target = _patrol_target - global_position
		to_target.y = 0.0

	var direction := to_target.normalized() if to_target.length_squared() > 0.0 else Vector3.ZERO
	velocity.x = move_toward(velocity.x, direction.x * patrol_speed, acceleration * delta)
	velocity.z = move_toward(velocity.z, direction.z * patrol_speed, acceleration * delta)

	if direction.length_squared() > 0.01:
		_face_toward(global_position + direction, delta)


func _has_visible_player() -> bool:
	if not _player or not is_instance_valid(_player):
		return false

	var target_point := _player.global_position + Vector3.UP * 0.8
	if _muzzle.global_position.distance_to(target_point) > detection_range:
		return false

	var query := PhysicsRayQueryParameters3D.create(_muzzle.global_position, target_point, 1 | 2 | HITBOX_LAYER_MASK, get_hitbox_exclusions())
	query.collide_with_areas = true
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if collision.is_empty():
		return false

	if collision.collider == _player:
		return true

	if collision.collider and collision.collider.has_method(&"get_damage_receiver"):
		return collision.collider.get_damage_receiver() == _player

	return false


func _fire() -> void:
	if not _player or not is_instance_valid(_player):
		return

	var target_point := _get_shot_target_point()
	var query := PhysicsRayQueryParameters3D.create(_muzzle.global_position, target_point, 1 | HITBOX_LAYER_MASK, get_hitbox_exclusions())
	query.collide_with_areas = true
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	var impact_position := target_point
	var impact_normal := (target_point - _muzzle.global_position).normalized()
	if not collision.is_empty():
		impact_position = collision.position
		impact_normal = collision.normal
		if collision.collider and collision.collider.has_method(&"get_damage_receiver"):
			var receiver = collision.collider.get_damage_receiver()
			if receiver and receiver.has_method(&"take_hit"):
				receiver.take_hit(
					collision.collider.zone,
					collision.collider.damage,
					(impact_position - _muzzle.global_position).normalized(),
					impact_position,
					collision.collider.instant_kill
				)

	_shoot_audio.play()
	_muzzle_flash_timer = 0.08
	_stop_charge_telegraph()
	_show_beam(impact_position)
	_spawn_impact(impact_position, impact_normal, Color(1.0, 0.76, 0.33), 0.5, 0.18, 2.4)


func _show_beam(target: Vector3) -> void:
	var beam_length := _muzzle.global_position.distance_to(target)
	_beam_pivot.visible = true
	_beam_pivot.global_position = _muzzle.global_position
	_beam_pivot.look_at(target, Vector3.UP)
	_beam_mesh.position = Vector3(0.0, 0.0, -beam_length * 0.5)
	_beam_mesh.scale = Vector3(1.0, 1.0, beam_length)
	_beam_timer = 0.1


func _get_shot_target_point() -> Vector3:
	var base_point := _player.global_position + Vector3(0.0, randf_range(0.72, 1.02), 0.0)
	var to_target := base_point - _muzzle.global_position
	var distance := to_target.length()
	if distance <= 0.01:
		return base_point

	var forward := to_target / distance
	var right := forward.cross(Vector3.UP).normalized()
	if right.length_squared() <= 0.001:
		right = Vector3.RIGHT
	var up := right.cross(forward).normalized()

	var spread_ratio := clampf((distance - 6.0) / 12.0, 0.0, 1.0)
	var horizontal_spread := lerpf(near_shot_spread, far_shot_spread, spread_ratio)
	var vertical_spread := horizontal_spread * 0.55

	if randf() < shot_miss_chance:
		horizontal_spread *= 1.8
		vertical_spread *= 1.5
		base_point.y = _player.global_position.y + randf_range(0.45, 0.95)

	return (
		base_point
		+ right * randf_range(-horizontal_spread, horizontal_spread)
		+ up * randf_range(-vertical_spread, vertical_spread)
	)


func _update_beam(delta: float) -> void:
	_beam_timer = maxf(0.0, _beam_timer - delta)
	if _beam_timer <= 0.0:
		_beam_pivot.visible = false


func _face_toward(world_target: Vector3, delta: float) -> void:
	var flat_target := world_target - global_position
	flat_target.y = 0.0
	if flat_target.length_squared() <= 0.001:
		return

	var target_yaw := atan2(-flat_target.x, -flat_target.z)
	_visual.rotation.y = lerp_angle(_visual.rotation.y, target_yaw, minf(1.0, 8.0 * delta))


func _update_state_light() -> void:
	if _beam_pivot.visible:
		_state_light.light_color = Color(1.0, 0.95, 0.72, 1.0)
		_state_light.light_energy = 1.5
	elif _charge_ratio > 0.0:
		_state_light.light_color = Color(1.0, 0.72, 0.28, 1.0)
		_state_light.light_energy = lerpf(1.0, 1.8, _charge_ratio)
	elif _state == State.AIM:
		_state_light.light_color = Color(1.0, 0.72, 0.28, 1.0)
		_state_light.light_energy = 1.0
	elif _state == State.ALERT:
		_state_light.light_color = Color(0.980392, 0.568627, 0.258824, 1.0)
		_state_light.light_energy = 0.82
	else:
		_state_light.light_color = Color(0.95, 0.25, 0.22, 1.0)
		_state_light.light_energy = 0.65


func _update_charge_state() -> void:
	if _cooldown_timer > 0.0 or _aim_timer > telegraph_time:
		_stop_charge_telegraph()
		return

	var ratio := 1.0 - clampf(_aim_timer / maxf(telegraph_time, 0.01), 0.0, 1.0)
	if not _charge_started:
		_charge_started = true
		_charge_audio.play()

	_charge_ratio = ratio
	_charge_orb.visible = true
	var orb_scale := lerpf(0.45, 1.25, ratio)
	_charge_orb.scale = Vector3.ONE * orb_scale


func _stop_charge_telegraph() -> void:
	_charge_started = false
	_charge_ratio = 0.0
	_charge_orb.visible = false
	_charge_orb.scale = Vector3.ONE


func _spawn_impact(
	position: Vector3,
	normal: Vector3,
	color: Color,
	size: float,
	duration: float,
	light_energy: float
) -> void:
	var effect = IMPACT_EFFECT_SCENE.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.configure(position, normal, color, size, duration, light_energy)


func _play_detached_sound(stream: AudioStream, position: Vector3, volume_db: float = 0.0) -> void:
	if stream == null:
		return

	var player := AudioStreamPlayer3D.new()
	get_tree().current_scene.add_child(player)
	player.stream = stream
	player.bus = &"SFX"
	player.volume_db = volume_db
	player.max_distance = 32.0
	player.global_position = position
	player.finished.connect(player.queue_free)
	player.play()


func _start_death_sequence(hit_direction: Vector3) -> void:
	_dead = true
	_death_elapsed = 0.0
	_death_landed = false
	velocity = Vector3.ZERO
	_beam_pivot.visible = false
	_charge_orb.visible = false
	_muzzle_flash.visible = false
	_charge_audio.stop()
	_shoot_audio.stop()
	_collision_shape.set_deferred(&"disabled", true)
	_set_hitboxes_enabled(false)
	_stop_charge_telegraph()
	_play_detached_sound(_explosion_audio.stream, global_position, -2.0)
	_spawn_impact(global_position + Vector3.UP * 0.9, Vector3.UP, Color(1.0, 0.6, 0.24), 0.95, 0.26, 3.2)
	_death_start_rotation = _visual.rotation
	_death_start_position = _visual.position
	_death_target_rotation = _compute_death_rotation(hit_direction)
	_death_target_rotation.y = _death_start_rotation.y
	_death_target_position = Vector3(0.0, 0.42, 0.08)
	_death_light_energy = _state_light.light_energy
	destroyed.emit()


func _compute_death_rotation(hit_direction: Vector3) -> Vector3:
	var fall_rotation := Vector3.ZERO
	var direction := hit_direction.normalized()
	if direction.length_squared() <= 0.001 and _player and is_instance_valid(_player):
		direction = (_player.global_position - global_position).normalized()

	if direction.length_squared() <= 0.001:
		fall_rotation.z = deg_to_rad(90.0)
		return fall_rotation

	var local_direction := _visual.global_basis.inverse() * direction
	if absf(local_direction.x) > absf(local_direction.z):
		fall_rotation.z = deg_to_rad(-88.0 if local_direction.x > 0.0 else 88.0)
	else:
		fall_rotation.x = deg_to_rad(92.0 if local_direction.z > 0.0 else -92.0)
	return fall_rotation


func _update_death_sequence(delta: float) -> void:
	_death_elapsed += delta

	if _death_elapsed <= DEATH_FALL_DURATION:
		var fall_t := _ease_out_cubic(_death_elapsed / DEATH_FALL_DURATION)
		_visual.position = _death_start_position.lerp(_death_target_position, fall_t)
		_visual.rotation = Vector3(
			lerp_angle(_death_start_rotation.x, _death_target_rotation.x, fall_t),
			lerp_angle(_death_start_rotation.y, _death_target_rotation.y, fall_t),
			lerp_angle(_death_start_rotation.z, _death_target_rotation.z, fall_t)
		)
		_state_light.light_energy = lerpf(_death_light_energy, 0.12, fall_t)
		if fall_t >= 0.98 and not _death_landed:
			_death_landed = true
			_spawn_impact(global_position + Vector3.UP * 0.18, Vector3.UP, Color(1.0, 0.52, 0.2), 0.5, 0.12, 1.4)
		return

	if _death_elapsed <= DEATH_FALL_DURATION + DEATH_HOLD_DURATION:
		var flicker := 0.06 if int(Time.get_ticks_msec() / 65) % 2 == 0 else 0.0
		_state_light.light_energy = flicker
		return

	var fade_elapsed := _death_elapsed - DEATH_FALL_DURATION - DEATH_HOLD_DURATION
	var fade_t := clampf(fade_elapsed / DEATH_FADE_DURATION, 0.0, 1.0)
	_state_light.light_energy = lerpf(0.05, 0.0, fade_t)
	_set_fade_alpha(1.0 - fade_t)

	if fade_t >= 1.0:
		queue_free()


func _capture_unique_materials() -> void:
	_fade_materials.clear()
	for mesh in _collect_visual_meshes(_visual):
		for surface_index in range(mesh.mesh.get_surface_count()):
			var material: Material = mesh.get_active_material(surface_index)
			if material is StandardMaterial3D:
				var instance_material := material.duplicate() as StandardMaterial3D
				instance_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
				mesh.set_surface_override_material(surface_index, instance_material)
				_fade_materials.append(instance_material)


func _set_fade_alpha(alpha: float) -> void:
	for material in _fade_materials:
		var albedo := material.albedo_color
		albedo.a = alpha
		material.albedo_color = albedo
		var emission := material.emission
		emission.a = alpha
		material.emission = emission


func _collect_visual_meshes(root: Node) -> Array[MeshInstance3D]:
	var result: Array[MeshInstance3D] = []
	for child in root.get_children():
		if child == _charge_orb or child == _muzzle_flash:
			continue
		if child is MeshInstance3D and child.mesh:
			result.append(child)
		result.append_array(_collect_visual_meshes(child))
	return result


func get_hitbox_exclusions() -> Array:
	var exclude: Array = [self]
	for hitbox in _hitboxes_root.get_children():
		exclude.append(hitbox)
	return exclude


func _set_hitboxes_enabled(enabled: bool) -> void:
	for hitbox in _hitboxes_root.get_children():
		if hitbox is Area3D:
			hitbox.monitorable = enabled


func _is_facing_target(world_target: Vector3) -> bool:
	var flat_target := world_target - global_position
	flat_target.y = 0.0
	if flat_target.length_squared() <= 0.001:
		return true

	var facing := -_visual.global_basis.z
	facing.y = 0.0
	facing = facing.normalized()
	return facing.dot(flat_target.normalized()) >= min_fire_alignment


func _ease_out_cubic(value: float) -> float:
	var t := clampf(value, 0.0, 1.0)
	return 1.0 - pow(1.0 - t, 3.0)
