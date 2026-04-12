extends Node3D

@export var duration: float = 0.16

var _time_left := duration
var _base_size := 0.55
var _base_light_energy := 2.0

@onready var _flash: MeshInstance3D = $Flash
@onready var _light: OmniLight3D = $Light


func _ready() -> void:
	_time_left = duration


func configure(
	world_position: Vector3,
	normal: Vector3,
	color: Color,
	size: float = 0.55,
	effect_duration: float = 0.16,
	light_energy: float = 2.0
) -> void:
	var direction := normal.normalized() if normal.length_squared() > 0.001 else Vector3.UP
	global_position = world_position + direction * 0.05
	duration = maxf(0.02, effect_duration)
	_time_left = duration
	_base_size = size
	_base_light_energy = light_energy
	scale = Vector3.ONE * (_base_size * 0.35)

	var material := _flash.material_override
	if material == null:
		material = _flash.mesh.surface_get_material(0)
	if material is StandardMaterial3D:
		var instance_material := material.duplicate()
		instance_material.albedo_color = color
		instance_material.emission = color
		_flash.material_override = instance_material

	_light.light_color = color
	_light.light_energy = light_energy


func _process(delta: float) -> void:
	_time_left -= delta
	if _time_left <= 0.0:
		queue_free()
		return

	var progress := 1.0 - (_time_left / duration)
	var current_scale := lerpf(0.35, 1.0, progress) * _base_size
	scale = Vector3.ONE * current_scale
	_light.light_energy = lerpf(_base_light_energy, 0.0, progress)
