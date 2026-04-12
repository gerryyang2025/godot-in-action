extends CharacterBody3D

const IMPACT_EFFECT_SCENE := preload("res://scenes/impact_effect.tscn")
const HITBOX_LAYER_MASK := 128
const TRACER_LENGTH_RATIO := 0.38
const TRACER_MIN_LENGTH := 0.12
const TRACER_MAX_LENGTH := 1.35
const INITIAL_TRACER_LENGTH := 0.14

@export var speed: float = 220.0
@export var lifetime: float = 1.1

var _direction := Vector3.FORWARD
var _life_left := lifetime
var _exclude: Array = []

@onready var _tracer: MeshInstance3D = $Tracer


func configure(start_position: Vector3, direction: Vector3, owner: Node) -> void:
	global_position = start_position
	_direction = direction.normalized()
	_life_left = lifetime
	_exclude.clear()
	look_at(start_position + _direction, Vector3.UP)
	_update_visuals(INITIAL_TRACER_LENGTH)

	if owner and owner.has_method(&"get_hitbox_exclusions"):
		_exclude = owner.get_hitbox_exclusions()
	elif owner:
		_exclude.append(owner)


func _physics_process(delta: float) -> void:
	_life_left -= delta
	if _life_left <= 0.0:
		queue_free()
		return

	var start_position := global_position
	var segment_length := speed * delta
	var end_position := start_position + _direction * segment_length
	_update_visuals(segment_length)
	var query := PhysicsRayQueryParameters3D.create(start_position, end_position, 1 | HITBOX_LAYER_MASK, _exclude)
	query.collide_with_areas = true
	var collision := get_world_3d().direct_space_state.intersect_ray(query)
	if collision.is_empty():
		global_position = end_position
		return

	var collider = collision.collider
	if collider and collider.has_method(&"get_damage_receiver"):
		var receiver = collider.get_damage_receiver()
		if receiver and receiver.has_method(&"take_hit"):
			receiver.take_hit(collider.zone, collider.damage, _direction, collision.position, collider.instant_kill)
	elif collider and collider.is_in_group(&"enemies"):
		collider.take_damage(22, _direction)
	elif collider and collider.has_method(&"take_damage"):
		collider.take_damage(22)
	else:
		_spawn_impact(collision.position, collision.normal)

	queue_free()


func _spawn_impact(position: Vector3, normal: Vector3) -> void:
	var effect = IMPACT_EFFECT_SCENE.instantiate()
	get_tree().current_scene.add_child(effect)
	effect.configure(position, normal, Color(1.0, 0.84, 0.66), 0.26, 0.08, 0.55)


func _update_visuals(segment_length: float) -> void:
	var tracer_length := clampf(segment_length * TRACER_LENGTH_RATIO, TRACER_MIN_LENGTH, TRACER_MAX_LENGTH)
	_tracer.scale = Vector3.ONE
	_tracer.scale.z = tracer_length
	_tracer.position = Vector3(0.0, 0.0, tracer_length * 0.5)
