extends Area3D

signal collected(beacon: Area3D)

@onready var _visual: Node3D = $Visual


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	_visual.rotate_y(2.6 * delta)
	_visual.position.y = 0.12 + sin(Time.get_ticks_msec() * 0.006) * 0.08


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(&"player"):
		monitoring = false
		collected.emit(self)
