extends Area2D

signal beacon_collected(beacon: Area2D)
signal drone_hit

@export var speed: float = 360.0

var arena_rect: Rect2 = Rect2(Vector2.ZERO, Vector2(960.0, 640.0))
var _is_active := false
var _is_invulnerable := false
var _invulnerable_time := 0.0
var _thruster_time := 0.0

@onready var _visual: Node2D = $Visual
@onready var _hull: Polygon2D = $Visual/Hull
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _thruster_glow: Polygon2D = $Visual/ThrusterGlow
@onready var _thruster_trail: Line2D = $Visual/ThrusterTrail
@onready var _shield_ring: Line2D = $Visual/ShieldRing
@onready var _hit_flash: Line2D = $Visual/HitFlash
@onready var _cockpit: Polygon2D = $Visual/Cockpit


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	set_active(false)


func _physics_process(delta: float) -> void:
	var input_vector := Vector2.ZERO

	if _is_invulnerable:
		_invulnerable_time -= delta
		_visual.visible = int(Time.get_ticks_msec() / 120) % 2 == 0
		if _invulnerable_time <= 0.0:
			_is_invulnerable = false
			_visual.visible = true

	if not _is_active:
		_update_visuals(delta, input_vector)
		return

	input_vector = Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if input_vector != Vector2.ZERO:
		rotation = input_vector.angle()

	position += input_vector * speed * delta
	position = position.clamp(arena_rect.position, arena_rect.end)
	_update_visuals(delta, input_vector)


func start(start_position: Vector2) -> void:
	position = start_position
	rotation = 0.0
	_is_invulnerable = false
	_invulnerable_time = 0.0
	_thruster_time = 0.0
	_visual.visible = true
	set_active(true)
	_update_visuals(0.0, Vector2.ZERO)


func set_active(is_active: bool) -> void:
	_is_active = is_active
	visible = is_active
	_collision_shape.set_deferred(&"disabled", not is_active)
	if not is_active:
		_visual.visible = false


func start_invulnerability(duration: float) -> void:
	_is_invulnerable = true
	_invulnerable_time = duration


func _update_visuals(delta: float, input_vector: Vector2) -> void:
	_thruster_time += delta
	var thrust_strength := input_vector.length()
	var pulse := 0.7 + sin(_thruster_time * 18.0) * 0.3
	var trail_length := 10.0 + thrust_strength * 22.0 + pulse * 4.0

	_thruster_glow.scale = Vector2(1.0, 0.8 + thrust_strength * 0.75 + pulse * 0.15)
	_thruster_glow.modulate = Color(1.0, 0.8, 0.35, 0.25 + thrust_strength * 0.7)
	_thruster_trail.points = PackedVector2Array([
		Vector2(-16.0, -4.0),
		Vector2(-16.0 - trail_length, 0.0),
		Vector2(-16.0, 4.0),
	])
	_thruster_trail.width = 1.8 + thrust_strength * 4.2
	_thruster_trail.default_color = Color(0.38, 0.98, 1.0, 0.2 + thrust_strength * 0.55)

	_shield_ring.scale = Vector2.ONE * (1.0 + pulse * 0.05)
	_shield_ring.default_color = Color(0.34, 0.94, 1.0, 0.14 + float(_is_invulnerable) * 0.5)
	_hit_flash.default_color = Color(1.0, 0.64, 0.25, 0.0 if not _is_invulnerable else 0.8)
	_cockpit.modulate = Color(1.0, 1.0, 1.0, 0.9 + pulse * 0.1)


func _on_area_entered(area: Area2D) -> void:
	if not _is_active:
		return

	if area.is_in_group(&"beacons"):
		beacon_collected.emit(area)
	elif area.is_in_group(&"drones") and not _is_invulnerable:
		drone_hit.emit()
