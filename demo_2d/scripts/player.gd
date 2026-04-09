extends Area2D

signal beacon_collected(beacon: Area2D)
signal drone_hit

@export var speed: float = 360.0

var arena_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(960.0, 640.0))
var _is_active := false
var _is_invulnerable := false
var _invulnerable_time := 0.0

@onready var _hull: Polygon2D = $Hull
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	set_active(false)


func _physics_process(delta: float) -> void:
	if _is_invulnerable:
		_invulnerable_time -= delta
		_hull.visible = int(Time.get_ticks_msec() / 120) % 2 == 0
		if _invulnerable_time <= 0.0:
			_is_invulnerable = false
			_hull.visible = true

	if not _is_active:
		return

	var input_vector := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_vector != Vector2.ZERO:
		rotation = input_vector.angle()

	position += input_vector * speed * delta
	position = position.clamp(arena_rect.position, arena_rect.end)


func start(start_position: Vector2) -> void:
	position = start_position
	rotation = 0.0
	_is_invulnerable = false
	_invulnerable_time = 0.0
	_hull.visible = true
	set_active(true)


func set_active(is_active: bool) -> void:
	_is_active = is_active
	visible = is_active
	_collision_shape.set_deferred(&"disabled", not is_active)


func start_invulnerability(duration: float) -> void:
	_is_invulnerable = true
	_invulnerable_time = duration


func _on_area_entered(area: Area2D) -> void:
	if not _is_active:
		return

	if area.is_in_group(&"beacons"):
		beacon_collected.emit(area)
	elif area.is_in_group(&"drones") and not _is_invulnerable:
		drone_hit.emit()
