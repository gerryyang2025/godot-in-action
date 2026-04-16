extends Node3D

signal lane_changed(from_lane: int, to_lane: int)

const BASE_HEIGHT := 0.55
const LANE_CHANGE_SPEED := 18.0
const JUMP_DURATION := 0.86
const JUMP_HEIGHT := 1.32

var _lane_positions: Array = [-4.8, -2.4, 0.0, 2.4, 4.8]
var _lane_index := 2
var _speed_ratio := 0.0
var _jump_timer := 0.0
var _hijack_timer := 0.0
var _grace_timer := 0.0
var _stealth_visual := false
var _pulse_time := 0.0
var _wheel_spin := 0.0
var _hijack_proxy_position := Vector3.ZERO
var _body_color := Color(0.227451, 0.788235, 0.917647, 1)
var _accent_color := Color(1, 0.67451, 0.184314, 1)

var _hero_overlay := StandardMaterial3D.new()
var _kit_material := StandardMaterial3D.new()
var _accent_material := StandardMaterial3D.new()
var _glow_material := StandardMaterial3D.new()

@onready var _visual_root: Node3D = $VisualRoot
@onready var _hero_body: MeshInstance3D = $VisualRoot/ModelRoot/HeroBody
@onready var _front_lip: MeshInstance3D = $VisualRoot/ModelRoot/FrontLip
@onready var _rear_wing: MeshInstance3D = $VisualRoot/ModelRoot/RearWing
@onready var _rear_wing_fin_l: MeshInstance3D = $VisualRoot/ModelRoot/RearWingFinL
@onready var _rear_wing_fin_r: MeshInstance3D = $VisualRoot/ModelRoot/RearWingFinR
@onready var _side_blade_l: MeshInstance3D = $VisualRoot/ModelRoot/SideBladeL
@onready var _side_blade_r: MeshInstance3D = $VisualRoot/ModelRoot/SideBladeR
@onready var _headlight_bar: MeshInstance3D = $VisualRoot/ModelRoot/HeadlightBar
@onready var _engine_glow: MeshInstance3D = $VisualRoot/ModelRoot/EngineGlow
@onready var _roof_light: MeshInstance3D = $VisualRoot/ModelRoot/RoofLight

var _wheels: Array[MeshInstance3D] = []


func _ready() -> void:
	_collect_optional_wheels()
	_configure_materials()
	_assign_materials()
	apply_palette(Color(0.227451, 0.788235, 0.917647, 1), Color(1, 0.67451, 0.184314, 1))
	position.y = BASE_HEIGHT


func _collect_optional_wheels() -> void:
	for path in [
		NodePath("VisualRoot/ModelRoot/WheelFL"),
		NodePath("VisualRoot/ModelRoot/WheelFR"),
		NodePath("VisualRoot/ModelRoot/WheelRL"),
		NodePath("VisualRoot/ModelRoot/WheelRR"),
	]:
		var wheel := get_node_or_null(path)
		if wheel is MeshInstance3D:
			_wheels.append(wheel)


func _process(delta: float) -> void:
	_pulse_time += delta

	var target_x := float(_lane_positions[_lane_index])
	position.x = move_toward(position.x, target_x, LANE_CHANGE_SPEED * delta)

	var body_height := 0.0
	if _hijack_timer > 0.0:
		_hijack_timer = maxf(0.0, _hijack_timer - delta)
		position = Vector3(_hijack_proxy_position.x, BASE_HEIGHT, _hijack_proxy_position.z)
	elif _jump_timer > 0.0:
		_jump_timer = maxf(0.0, _jump_timer - delta)
		var t := 1.0 - (_jump_timer / JUMP_DURATION)
		body_height = sin(t * PI) * JUMP_HEIGHT
	elif _grace_timer > 0.0:
		_grace_timer = maxf(0.0, _grace_timer - delta)

	position.y = lerpf(position.y, BASE_HEIGHT + body_height, minf(1.0, delta * 12.0))
	var grace_flash_on := _grace_timer <= 0.0 or fmod(_pulse_time * 18.0, 2.0) < 1.0
	_visual_root.visible = _hijack_timer <= 0.0 and grace_flash_on

	var lateral_offset := target_x - position.x
	_visual_root.rotation.z = lerpf(_visual_root.rotation.z, lateral_offset * 0.08, minf(1.0, delta * 10.0))
	_visual_root.rotation.x = lerpf(_visual_root.rotation.x, deg_to_rad(2.0 + _speed_ratio * 4.5), minf(1.0, delta * 4.0))

	_wheel_spin += delta * (7.0 + _speed_ratio * 28.0)
	for wheel in _wheels:
		wheel.rotation.x = _wheel_spin

	var pulse := 1.0 + 0.12 * sin(_pulse_time * 10.0)
	var glow_scale := 0.72 + _speed_ratio * 1.45
	_engine_glow.scale.z = lerpf(_engine_glow.scale.z, glow_scale, minf(1.0, delta * 8.0))
	_engine_glow.scale.x = lerpf(_engine_glow.scale.x, 0.95 + _speed_ratio * 0.22, minf(1.0, delta * 8.0))
	_headlight_bar.scale.x = lerpf(_headlight_bar.scale.x, 1.0 + _speed_ratio * 0.18, minf(1.0, delta * 8.0))

	_glow_material.emission_energy_multiplier = 0.55 + _speed_ratio * 1.35
	_accent_material.emission_energy_multiplier = 0.35 + _speed_ratio * 0.8

	if _stealth_visual:
		_refresh_material_palette()

	_roof_light.visible = _hijack_timer > 0.0 or _grace_timer > 0.0 or _stealth_visual
	var hijack_scale := pulse * (1.0 + _speed_ratio * 0.08)
	_roof_light.scale = Vector3(hijack_scale, 1.0, hijack_scale)
	_side_blade_l.scale.y = 1.0 + _speed_ratio * 0.28
	_side_blade_r.scale.y = 1.0 + _speed_ratio * 0.28


func _configure_materials() -> void:
	_hero_overlay.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_hero_overlay.albedo_color = Color(1, 1, 1, 0.18)
	_hero_overlay.metallic = 0.35
	_hero_overlay.roughness = 0.24
	_hero_overlay.emission_enabled = true
	_hero_overlay.emission_energy_multiplier = 0.15

	_kit_material.roughness = 0.18
	_kit_material.metallic = 0.45
	_kit_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_kit_material.emission_enabled = true
	_kit_material.emission_energy_multiplier = 0.25

	_accent_material.roughness = 0.14
	_accent_material.metallic = 0.1
	_accent_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_accent_material.emission_enabled = true
	_accent_material.emission_energy_multiplier = 0.35

	_glow_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_glow_material.roughness = 0.02
	_glow_material.emission_enabled = true
	_glow_material.emission_energy_multiplier = 0.55
	_glow_material.albedo_color = Color(1, 1, 1, 0.82)
	_glow_material.emission = Color(1, 1, 1, 1)


func _assign_materials() -> void:
	_hero_body.material_overlay = _hero_overlay
	for node in [_front_lip, _rear_wing, _rear_wing_fin_l, _rear_wing_fin_r]:
		node.material_override = _kit_material
	for node in [_side_blade_l, _side_blade_r]:
		node.material_override = _accent_material
	for node in [_headlight_bar, _engine_glow, _roof_light]:
		node.material_override = _glow_material


func set_lane_positions(lane_positions: Array) -> void:
	_lane_positions = lane_positions.duplicate()
	_lane_index = _default_lane_index()
	position.x = float(_lane_positions[_lane_index])


func reset_for_run(body_color: Color, accent_color: Color) -> void:
	_lane_index = _default_lane_index()
	_jump_timer = 0.0
	_hijack_timer = 0.0
	_grace_timer = 0.0
	_stealth_visual = false
	_wheel_spin = 0.0
	_hijack_proxy_position = Vector3(float(_lane_positions[_lane_index]), 0.0, 0.0)
	position = Vector3(float(_lane_positions[_lane_index]), BASE_HEIGHT, 0.0)
	_visual_root.visible = true
	_visual_root.rotation = Vector3.ZERO
	apply_palette(body_color, accent_color)


func _default_lane_index() -> int:
	return clampi(_lane_positions.size() / 2, 0, _lane_positions.size() - 1)


func apply_palette(body_color: Color, accent_color: Color) -> void:
	_body_color = body_color
	_accent_color = accent_color
	_refresh_material_palette()


func _refresh_material_palette() -> void:
	var body_color := _body_color
	var accent_color := _accent_color
	if _stealth_visual:
		var cloak_pulse := 0.12 + 0.05 * (0.5 + 0.5 * sin(_pulse_time * 11.0))
		var cloak_highlight := Color(0.447059, 0.968627, 1.0, 1.0)
		_hero_overlay.albedo_color = Color(cloak_highlight.r, cloak_highlight.g, cloak_highlight.b, cloak_pulse)
		_hero_overlay.emission = cloak_highlight.lightened(0.12)
		var kit_color := body_color.lerp(Color(0.168627, 0.360784, 0.505882, 1.0), 0.72)
		_kit_material.albedo_color = Color(kit_color.r, kit_color.g, kit_color.b, 0.2 + cloak_pulse * 0.35)
		_kit_material.emission = cloak_highlight.darkened(0.18)
		var stealth_accent := accent_color.lerp(cloak_highlight, 0.78)
		_accent_material.albedo_color = Color(stealth_accent.r, stealth_accent.g, stealth_accent.b, 0.36 + cloak_pulse * 0.32)
		_accent_material.emission = stealth_accent.lightened(0.14)
		_glow_material.albedo_color = Color(cloak_highlight.r, cloak_highlight.g, cloak_highlight.b, 0.56 + cloak_pulse * 0.28)
		_glow_material.emission = cloak_highlight.lightened(0.18)
		return

	_hero_overlay.albedo_color = Color(body_color.r, body_color.g, body_color.b, 0.22)
	_hero_overlay.emission = body_color.darkened(0.32)

	var kit_color := body_color.darkened(0.35)
	_kit_material.albedo_color = Color(kit_color.r, kit_color.g, kit_color.b, 1.0)
	_kit_material.emission = kit_color.darkened(0.55)

	_accent_material.albedo_color = Color(accent_color.r, accent_color.g, accent_color.b, 1.0)
	_accent_material.emission = accent_color

	_glow_material.albedo_color = Color(accent_color.r, accent_color.g, accent_color.b, 0.82)
	_glow_material.emission = accent_color.lightened(0.15)


func request_lane_change(direction: int) -> bool:
	var target_lane := clampi(_lane_index + direction, 0, _lane_positions.size() - 1)
	if target_lane == _lane_index:
		return false

	var previous_lane := _lane_index
	_lane_index = target_lane
	lane_changed.emit(previous_lane, _lane_index)
	return true


func begin_jump() -> bool:
	if _hijack_timer > 0.0 or _jump_timer > 0.12:
		return false

	_jump_timer = JUMP_DURATION
	return true


func begin_hijack(duration: float, proxy_position: Vector3) -> void:
	_jump_timer = 0.0
	_hijack_timer = duration
	_hijack_proxy_position = proxy_position
	position = Vector3(proxy_position.x, BASE_HEIGHT, proxy_position.z)
	_visual_root.visible = false


func extend_hijack(duration: float, max_duration: float = 6.0) -> void:
	if _hijack_timer <= 0.0:
		return

	_hijack_timer = minf(max_duration, _hijack_timer + duration)


func begin_recovery_invulnerability(duration: float) -> void:
	_grace_timer = maxf(_grace_timer, duration)
	_hijack_proxy_position = Vector3(position.x, 0.0, 0.0)
	position = Vector3(position.x, BASE_HEIGHT, 0.0)
	_visual_root.visible = true


func sync_hijack_proxy(proxy_position: Vector3) -> void:
	_hijack_proxy_position = proxy_position
	if _hijack_timer > 0.0:
		position = Vector3(proxy_position.x, BASE_HEIGHT, proxy_position.z)


func has_recovery_invulnerability() -> bool:
	return _grace_timer > 0.0


func set_speed_ratio(value: float) -> void:
	_speed_ratio = clampf(value, 0.0, 1.4)


func set_stealth_visual(active: bool) -> void:
	if _stealth_visual == active:
		return

	_stealth_visual = active
	_refresh_material_palette()


func get_lane_index() -> int:
	return _lane_index


func is_hijacked() -> bool:
	return _hijack_timer > 0.0


func is_airborne() -> bool:
	return _jump_timer > 0.0 or _hijack_timer > 0.0
