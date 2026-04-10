extends Area2D

var arena_rect: Rect2
var velocity := Vector2.ZERO
var _age := 0.0

@onready var _scanner: Line2D = $Visual/Scanner
@onready var _danger_ring: Line2D = $Visual/DangerRing
@onready var _thruster_trail: Line2D = $Visual/ThrusterTrail


func configure(start_position: Vector2, target_position: Vector2, speed: float, movement_bounds: Rect2) -> void:
	arena_rect = movement_bounds
	position = start_position
	_age = randf_range(0.0, TAU)

	var direction := start_position.direction_to(target_position)
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT.rotated(randf_range(0.0, TAU))

	velocity = direction * speed
	rotation = velocity.angle()


func _physics_process(delta: float) -> void:
	_age += delta
	position += velocity * delta

	if position.x <= arena_rect.position.x or position.x >= arena_rect.end.x:
		velocity.x *= -1.0
		position.x = clampf(position.x, arena_rect.position.x, arena_rect.end.x)

	if position.y <= arena_rect.position.y or position.y >= arena_rect.end.y:
		velocity.y *= -1.0
		position.y = clampf(position.y, arena_rect.position.y, arena_rect.end.y)

	if velocity != Vector2.ZERO:
		rotation = velocity.angle()

	var pulse := 0.6 + sin(_age * 8.0) * 0.4
	_scanner.width = 2.8 + pulse * 2.0
	_scanner.default_color = Color(1.0, 0.84, 0.31, 0.45 + pulse * 0.5)
	_danger_ring.width = 1.4 + pulse
	_danger_ring.scale = Vector2.ONE * (0.95 + pulse * 0.14)
	_danger_ring.default_color = Color(1.0, 0.33, 0.38, 0.28 + pulse * 0.18)
	_thruster_trail.width = 2.2 + pulse * 2.5
	_thruster_trail.default_color = Color(1.0, 0.4, 0.52, 0.22 + pulse * 0.3)
