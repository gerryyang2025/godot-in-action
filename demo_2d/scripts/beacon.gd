extends Area2D

var _age := 0.0


func _process(delta: float) -> void:
	_age += delta
	var pulse := 1.0 + sin(_age * 5.0) * 0.08
	scale = Vector2.ONE * pulse
	rotation += delta * 1.4
