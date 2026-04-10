extends Area2D

var _age := 0.0

@onready var _visual: Node2D = $Visual
@onready var _outer_pulse: Line2D = $Visual/OuterPulse
@onready var _scan_arc: Line2D = $Visual/ScanArc
@onready var _core: Polygon2D = $Visual/Core
@onready var _ring: Line2D = $Visual/Ring


func _process(delta: float) -> void:
	_age += delta
	var pulse := 1.0 + sin(_age * 5.0) * 0.08
	scale = Vector2.ONE * pulse
	rotation += delta * 0.5
	_visual.position.y = sin(_age * 2.0) * 1.8
	_outer_pulse.scale = Vector2.ONE * (1.05 + sin(_age * 3.0) * 0.18)
	_outer_pulse.default_color = Color(0.47, 1.0, 0.62, 0.2 + sin(_age * 2.2) * 0.05)
	_scan_arc.rotation += delta * 2.8
	_ring.default_color = Color(0.62, 1.0, 0.5, 0.7 + sin(_age * 6.0) * 0.12)
	_core.scale = Vector2.ONE * (0.95 + sin(_age * 7.0) * 0.08)
