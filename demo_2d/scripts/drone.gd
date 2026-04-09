extends Area2D

var arena_rect: Rect2
var velocity := Vector2.ZERO


func configure(start_position: Vector2, target_position: Vector2, speed: float, movement_bounds: Rect2) -> void:
	arena_rect = movement_bounds
	position = start_position

	var direction := start_position.direction_to(target_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

	velocity = direction * speed
	rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	position += velocity * delta

	if position.x <= arena_rect.position.x or position.x >= arena_rect.end.x:
		velocity.x *= -1.0
		position.x = clampf(position.x, arena_rect.position.x, arena_rect.end.x)

	if position.y <= arena_rect.position.y or position.y >= arena_rect.end.y:
		velocity.y *= -1.0
		position.y = clampf(position.y, arena_rect.position.y, arena_rect.end.y)

	if velocity != Vector2.ZERO:
		rotation = velocity.angle()
