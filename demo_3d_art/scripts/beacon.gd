extends Area3D

signal collected(beacon: Area3D)

var _age := 0.0

@onready var _visual: Node3D = $Visual
@onready var _core: Node3D = $Visual/Core
@onready var _halo: Node3D = $Visual/Halo
@onready var _orbit_ring: Node3D = $Visual/OrbitRing
@onready var _beam: Node3D = $Visual/Beam
@onready var _light: OmniLight3D = $Visual/OmniLight3D


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_age += delta
	_visual.rotate_y(1.8 * delta)
	_visual.position.y = 0.18 + sin(_age * 2.4) * 0.08
	_halo.rotate_y(-3.1 * delta)
	_orbit_ring.rotate_x(2.4 * delta)

	var pulse := 0.92 + 0.12 * (0.5 + 0.5 * sin(_age * 5.4))
	_core.scale = Vector3.ONE * pulse
	_beam.scale.y = 0.86 + 0.18 * (0.5 + 0.5 * sin(_age * 4.0))
	_light.light_energy = 0.7 + 0.4 * (0.5 + 0.5 * sin(_age * 6.2))


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		monitoring = false
		collected.emit(self)
