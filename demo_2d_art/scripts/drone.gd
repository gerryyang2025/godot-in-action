extends Area2D

signal bounced(edge: StringName, world_position: Vector2)

var arena_rect: Rect2
var velocity := Vector2.ZERO
var _age := 0.0
var _impact_flash := 0.0

@onready var _body: Polygon2D = $Visual/Body
@onready var _wing_top: Line2D = $Visual/WingTop
@onready var _wing_bottom: Line2D = $Visual/WingBottom
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
	_impact_flash = maxf(0.0, _impact_flash - delta * 3.2)
	position += velocity * delta

	if position.x <= arena_rect.position.x or position.x >= arena_rect.end.x:
		velocity.x *= -1.0
		_emit_bounce(&"west" if position.x <= arena_rect.position.x else &"east")
		position.x = clampf(position.x, arena_rect.position.x, arena_rect.end.x)

	if position.y <= arena_rect.position.y or position.y >= arena_rect.end.y:
		velocity.y *= -1.0
		_emit_bounce(&"north" if position.y <= arena_rect.position.y else &"south")
		position.y = clampf(position.y, arena_rect.position.y, arena_rect.end.y)

	if velocity != Vector2.ZERO:
		rotation = velocity.angle()

	var pulse := 0.6 + sin(_age * 8.0) * 0.4
	var bounce_mix := _impact_flash
	_body.color = Color(1.0, 0.28 + bounce_mix * 0.18, 0.3 + bounce_mix * 0.14, 1.0)
	_wing_top.default_color = Color(0.95, 0.2 + bounce_mix * 0.12, 0.28 + bounce_mix * 0.1, 0.8 + bounce_mix * 0.16)
	_wing_bottom.default_color = Color(0.95, 0.2 + bounce_mix * 0.12, 0.28 + bounce_mix * 0.1, 0.8 + bounce_mix * 0.16)
	_scanner.width = 2.8 + pulse * 2.0
	_scanner.default_color = Color(1.0, 0.84 + bounce_mix * 0.06, 0.31, 0.45 + pulse * 0.5)
	_danger_ring.width = 1.4 + pulse
	_danger_ring.scale = Vector2.ONE * (0.95 + pulse * 0.14 + bounce_mix * 0.08)
	_danger_ring.default_color = Color(1.0, 0.33 + bounce_mix * 0.16, 0.38 + bounce_mix * 0.1, 0.28 + pulse * 0.18 + bounce_mix * 0.16)
	_thruster_trail.width = 2.2 + pulse * 2.5
	_thruster_trail.default_color = Color(1.0, 0.4, 0.52, 0.22 + pulse * 0.3)


func _emit_bounce(edge: StringName) -> void:
	_impact_flash = 1.0
	bounced.emit(edge, global_position)
