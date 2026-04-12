extends Node3D

const MAX_TRAUMA := 1.0
const DECAY_RATE := 2.6
const SPEED := 18.0

@export var max_pitch := deg_to_rad(0.9)
@export var max_yaw := deg_to_rad(0.7)
@export var max_roll := deg_to_rad(1.5)
@export var max_offset := Vector3(0.03, 0.04, 0.0)

var _trauma := 0.0
var _time := 0.0
var _base_rotation := Vector3.ZERO
var _base_position := Vector3.ZERO
var _noise := FastNoiseLite.new()


func _ready() -> void:
	_base_rotation = rotation
	_base_position = position
	_noise.seed = randi()
	_noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	_noise.frequency = 0.85


func _process(delta: float) -> void:
	if _trauma <= 0.0:
		rotation = _base_rotation
		position = _base_position
		return

	_trauma = maxf(0.0, _trauma - DECAY_RATE * delta)
	_time += delta * SPEED

	var shake := _trauma * _trauma
	rotation = _base_rotation + Vector3(
		max_pitch * shake * _noise.get_noise_1d(_time + 11.0),
		max_yaw * shake * _noise.get_noise_1d(_time + 29.0),
		max_roll * shake * _noise.get_noise_1d(_time + 53.0)
	)
	position = _base_position + Vector3(
		max_offset.x * shake * _noise.get_noise_1d(_time + 71.0),
		max_offset.y * shake * _noise.get_noise_1d(_time + 101.0),
		0.0
	)


func add_trauma(amount: float) -> void:
	_trauma = minf(MAX_TRAUMA, _trauma + maxf(0.0, amount))


func reset_shake() -> void:
	_trauma = 0.0
	rotation = _base_rotation
	position = _base_position
