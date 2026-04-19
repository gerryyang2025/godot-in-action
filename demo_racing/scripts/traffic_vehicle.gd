extends Node3D

const TRUCK_HIJACK_ANCHOR_Z := 1.2
const TRUCK_HIJACK_BACK_BUFFER := 3.6
const TRUCK_HIJACK_FRONT_BUFFER := 3.0
const RAM_DURATION := 0.95
const RAM_GRAVITY := 16.5
const RAM_DESPAWN_X := 14.0
const NEAR_MISS_ARM_BACK_BUFFER := 13.5
const NEAR_MISS_ARM_FRONT_BUFFER := 0.8
const NEAR_MISS_CLEAR_BUFFER := 1.4
const CAR_COLLISION_DEPTH := 1.45
const VAN_COLLISION_DEPTH := 1.95
const TRUCK_COLLISION_DEPTH := 2.85

var lane_index := 1
var vehicle_kind: StringName = &"car"
var vehicle_variant: StringName = &"normal_1"
var speed_factor := 0.3
var near_miss_pending := false
var near_miss_awarded := false
var hijack_available := false
var _stealth_pass_awarded := false

var _ride_mode := false
var _rammed := false
var _pulse_time := 0.0
var _wheel_spin := 0.0
var _ram_timer := 0.0
var _ram_velocity := Vector3.ZERO
var _ram_vertical_velocity := 0.0
var _ram_pitch_speed := 0.0
var _ram_yaw_speed := 0.0
var _ram_roll_speed := 0.0

var _sedan_roof_tag_enabled := false
var _sedan_roof_tag_base_scale := Vector3.ONE
var _utility_beacon_base_scale := Vector3.ONE
var _utility_strip_base_scale := Vector3.ONE
var _truck_top_marker_base_scale := Vector3.ONE
var _hijack_marker_base_scale := Vector3.ONE

var _sedan_overlay := StandardMaterial3D.new()
var _utility_overlay := StandardMaterial3D.new()
var _truck_overlay := StandardMaterial3D.new()
var _sedan_accent_material := StandardMaterial3D.new()
var _utility_accent_material := StandardMaterial3D.new()
var _truck_accent_material := StandardMaterial3D.new()
var _marker_material := StandardMaterial3D.new()

var _active_wheels: Array = []

@onready var _visual_root: Node3D = $VisualRoot
@onready var _sedan_rig: Node3D = $VisualRoot/SedanRig
@onready var _utility_rig: Node3D = $VisualRoot/UtilityRig
@onready var _trailer_rig: Node3D = $VisualRoot/TrailerRig
@onready var _hijack_marker: MeshInstance3D = $VisualRoot/HijackMarker

@onready var _sedan_variants := {
	&"normal_1": $VisualRoot/SedanRig/ModelRoot/NormalCar1,
	&"normal_2": $VisualRoot/SedanRig/ModelRoot/NormalCar2,
	&"taxi": $VisualRoot/SedanRig/ModelRoot/Taxi,
	&"cop": $VisualRoot/SedanRig/ModelRoot/Cop,
}
@onready var _sedan_front_glow: MeshInstance3D = $VisualRoot/SedanRig/ModelRoot/FrontGlow
@onready var _sedan_rear_glow: MeshInstance3D = $VisualRoot/SedanRig/ModelRoot/RearGlow
@onready var _sedan_roof_tag: MeshInstance3D = $VisualRoot/SedanRig/ModelRoot/RoofTag

@onready var _utility_variants := {
	&"suv": $VisualRoot/UtilityRig/ModelRoot/SUV,
	&"ambulance": $VisualRoot/UtilityRig/ModelRoot/Ambulance,
}
@onready var _utility_roof_beacon: MeshInstance3D = $VisualRoot/UtilityRig/ModelRoot/RoofBeacon
@onready var _utility_safety_strip: MeshInstance3D = $VisualRoot/UtilityRig/ModelRoot/SafetyStrip

@onready var _truck_variants := {
	&"bus": $VisualRoot/TrailerRig/ModelRoot/Bus,
	&"school_bus": $VisualRoot/TrailerRig/ModelRoot/SchoolBus,
}
@onready var _truck_top_marker: MeshInstance3D = $VisualRoot/TrailerRig/ModelRoot/TopMarker


func _ready() -> void:
	_configure_materials()
	_assign_materials()
	_set_active_rig(&"car", &"normal_1")


func _configure_material(material: StandardMaterial3D, alpha: float) -> void:
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	material.albedo_color = Color(1, 1, 1, alpha)
	material.metallic = 0.18
	material.roughness = 0.32
	material.emission_enabled = true
	material.emission_energy_multiplier = 0.1


func _configure_materials() -> void:
	_configure_material(_sedan_overlay, 0.16)
	_configure_material(_utility_overlay, 0.12)
	_configure_material(_truck_overlay, 0.78)
	_truck_overlay.roughness = 0.2
	_truck_overlay.metallic = 0.24
	_truck_overlay.emission_energy_multiplier = 0.22

	for material in [_sedan_accent_material, _utility_accent_material, _truck_accent_material, _marker_material]:
		material.roughness = 0.12
		material.metallic = 0.08
		material.emission_enabled = true
		material.emission_energy_multiplier = 0.45

	_marker_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_marker_material.albedo_color = Color(0.95, 0.92, 0.4, 0.82)
	_marker_material.emission = Color(1, 0.9, 0.35, 1)
	_marker_material.emission_energy_multiplier = 0.7


func _assign_materials() -> void:
	for mesh in _sedan_variants.values():
		mesh.material_overlay = _sedan_overlay

	for mesh in _utility_variants.values():
		mesh.material_overlay = _utility_overlay

	for mesh in _truck_variants.values():
		mesh.material_overlay = _truck_overlay

	for node in [_sedan_front_glow, _sedan_rear_glow, _sedan_roof_tag]:
		node.material_override = _sedan_accent_material

	for node in [_utility_roof_beacon, _utility_safety_strip]:
		node.material_override = _utility_accent_material

	_truck_top_marker.material_override = _truck_accent_material
	_hijack_marker.material_override = _marker_material


func configure(kind: StringName, lane: int, lane_x: float, start_z: float, relative_speed: float, body_color: Color, accent_color: Color, variant: StringName = &"") -> void:
	vehicle_kind = kind
	vehicle_variant = _resolve_variant(kind, variant)
	lane_index = lane
	speed_factor = relative_speed
	position = Vector3(lane_x, 0.0, start_z)
	near_miss_pending = false
	near_miss_awarded = false
	hijack_available = vehicle_kind == &"truck"
	_stealth_pass_awarded = false
	_ride_mode = false
	_rammed = false
	_pulse_time = 0.0
	_wheel_spin = 0.0
	_ram_timer = 0.0
	_ram_velocity = Vector3.ZERO
	_ram_vertical_velocity = 0.0
	_ram_pitch_speed = 0.0
	_ram_yaw_speed = 0.0
	_ram_roll_speed = 0.0
	_visual_root.rotation = Vector3.ZERO

	_set_active_rig(vehicle_kind, vehicle_variant)
	_apply_palette(body_color, accent_color)


func _resolve_variant(kind: StringName, requested_variant: StringName) -> StringName:
	var variants: Dictionary = {}
	match kind:
		&"truck":
			variants = _truck_variants
		&"van":
			variants = _utility_variants
		_:
			variants = _sedan_variants

	if requested_variant != &"" and variants.has(requested_variant):
		return requested_variant

	return variants.keys()[0]


func _show_variant(variants: Dictionary, active_variant: StringName) -> void:
	for key in variants.keys():
		variants[key].visible = key == active_variant


func _set_active_rig(kind: StringName, variant: StringName) -> void:
	_sedan_rig.visible = kind == &"car"
	_utility_rig.visible = kind == &"van"
	_trailer_rig.visible = kind == &"truck"
	_hijack_marker.visible = kind == &"truck"

	match kind:
		&"truck":
			_show_variant(_truck_variants, variant)
			_show_variant(_utility_variants, &"")
			_show_variant(_sedan_variants, &"")
		&"van":
			_show_variant(_utility_variants, variant)
			_show_variant(_sedan_variants, &"")
			_show_variant(_truck_variants, &"")
		_:
			_show_variant(_sedan_variants, variant)
			_show_variant(_utility_variants, &"")
			_show_variant(_truck_variants, &"")

	_active_wheels = []
	_apply_variant_layout(kind, variant)


func _apply_variant_layout(kind: StringName, variant: StringName) -> void:
	_sedan_front_glow.position = Vector3(0, 0.48, 1.96)
	_sedan_rear_glow.position = Vector3(0, 0.54, -1.96)
	_sedan_roof_tag.position = Vector3(0, 1.18, -0.04)
	_sedan_roof_tag_base_scale = Vector3(1.0, 1.0, 1.0)
	_sedan_roof_tag_enabled = false

	_utility_roof_beacon.position = Vector3(0, 1.42, 0.12)
	_utility_beacon_base_scale = Vector3(1.0, 1.0, 1.0)
	_utility_safety_strip.position = Vector3(0, 0.86, -1.54)
	_utility_strip_base_scale = Vector3(1.0, 1.0, 1.0)

	_truck_top_marker.position = Vector3(0, 1.92, 0.3)
	_truck_top_marker_base_scale = Vector3(1.0, 1.0, 1.0)
	_hijack_marker.position = Vector3(0, 2.14, 1.0)
	_hijack_marker_base_scale = Vector3(1.0, 1.0, 1.0)

	if kind == &"car":
		if variant == &"taxi":
			_sedan_roof_tag_enabled = true
			_sedan_roof_tag.position = Vector3(0, 1.24, -0.03)
			_sedan_roof_tag_base_scale = Vector3(1.0, 1.0, 1.15)
		elif variant == &"cop":
			_sedan_roof_tag_enabled = true
			_sedan_roof_tag.position = Vector3(0, 1.16, -0.08)
			_sedan_roof_tag_base_scale = Vector3(0.9, 1.0, 1.85)
	elif kind == &"van":
		if variant == &"ambulance":
			_utility_roof_beacon.position = Vector3(0, 2.42, 1.02)
			_utility_beacon_base_scale = Vector3(1.18, 1.0, 1.35)
			_utility_safety_strip.position = Vector3(0, 1.62, -1.96)
			_utility_strip_base_scale = Vector3(1.28, 1.0, 1.0)
	elif kind == &"truck":
		if variant == &"school_bus":
			_truck_top_marker.position = Vector3(0, 2.3, 0.35)
			_truck_top_marker_base_scale = Vector3(1.08, 1.0, 1.14)
			_hijack_marker.position = Vector3(0, 2.46, 0.94)
			_hijack_marker_base_scale = Vector3(1.04, 1.0, 1.12)

	_sedan_roof_tag.scale = _sedan_roof_tag_base_scale
	_utility_roof_beacon.scale = _utility_beacon_base_scale
	_utility_safety_strip.scale = _utility_strip_base_scale
	_truck_top_marker.scale = _truck_top_marker_base_scale
	_hijack_marker.scale = _hijack_marker_base_scale


func _apply_palette(body_color: Color, accent_color: Color) -> void:
	var sedan_alpha := 0.14
	if vehicle_variant == &"taxi" or vehicle_variant == &"cop":
		sedan_alpha = 0.08
	_sedan_overlay.albedo_color = Color(body_color.r, body_color.g, body_color.b, sedan_alpha)
	_sedan_overlay.emission = body_color.darkened(0.5)

	var utility_alpha := 0.12 if vehicle_variant == &"suv" else 0.58
	_utility_overlay.albedo_color = Color(body_color.r, body_color.g, body_color.b, utility_alpha)
	_utility_overlay.emission = body_color.darkened(0.28 if vehicle_variant == &"ambulance" else 0.45)

	var truck_alpha := 0.78
	if vehicle_variant == &"school_bus":
		truck_alpha = 0.88
	_truck_overlay.albedo_color = Color(body_color.r, body_color.g, body_color.b, truck_alpha)
	_truck_overlay.emission = body_color.darkened(0.18)

	var sedan_glow := accent_color.lightened(0.08)
	_sedan_accent_material.albedo_color = sedan_glow
	_sedan_accent_material.emission = sedan_glow

	var utility_color := accent_color.lightened(0.04)
	_utility_accent_material.albedo_color = utility_color
	_utility_accent_material.emission = utility_color

	var truck_color := accent_color.lightened(0.14)
	_truck_accent_material.albedo_color = truck_color
	_truck_accent_material.emission = truck_color

	_marker_material.albedo_color = Color(truck_color.r, truck_color.g, truck_color.b, 0.82)
	_marker_material.emission = truck_color


func advance(delta: float, run_speed: float) -> void:
	if _rammed:
		_update_rammed(delta, run_speed)
		return

	if _ride_mode:
		return

	_pulse_time += delta
	_wheel_spin += delta * run_speed * (0.28 + speed_factor * 0.34)
	position.z += run_speed * speed_factor * delta
	_visual_root.rotation.y = 0.015 * sin(_pulse_time * 1.8 + float(lane_index))
	_visual_root.rotation.x = 0.01 * sin(_pulse_time * 2.6 + float(lane_index))

	for wheel in _active_wheels:
		wheel.rotation.x = _wheel_spin

	_sedan_roof_tag.visible = vehicle_kind == &"car" and _sedan_roof_tag_enabled
	_utility_roof_beacon.visible = vehicle_kind == &"van"

	var accent_energy := 0.35 + minf(1.0, run_speed / 40.0) * 0.38
	_sedan_accent_material.emission_energy_multiplier = accent_energy
	_utility_accent_material.emission_energy_multiplier = accent_energy
	_truck_accent_material.emission_energy_multiplier = accent_energy

	if vehicle_kind == &"car" and _sedan_roof_tag_enabled:
		var roof_pulse := 1.0 + 0.16 * sin(_pulse_time * 9.0)
		_sedan_roof_tag.scale = Vector3(
			_sedan_roof_tag_base_scale.x * roof_pulse,
			_sedan_roof_tag_base_scale.y,
			_sedan_roof_tag_base_scale.z * roof_pulse
		)
	elif vehicle_kind == &"van":
		var utility_pulse := 1.0 + 0.22 * sin(_pulse_time * 9.0)
		_utility_roof_beacon.scale = Vector3(
			_utility_beacon_base_scale.x * utility_pulse,
			_utility_beacon_base_scale.y,
			_utility_beacon_base_scale.z * utility_pulse
		)
		_utility_safety_strip.scale = Vector3(
			_utility_strip_base_scale.x * (1.0 + 0.12 * sin(_pulse_time * 6.0)),
			_utility_strip_base_scale.y,
			_utility_strip_base_scale.z
		)
	elif vehicle_kind == &"truck":
		var marker_pulse := 1.0 + 0.14 * sin(_pulse_time * 7.0)
		_truck_top_marker.scale = Vector3(
			_truck_top_marker_base_scale.x * marker_pulse,
			_truck_top_marker_base_scale.y,
			_truck_top_marker_base_scale.z * marker_pulse
		)
		_hijack_marker.scale = Vector3(
			_hijack_marker_base_scale.x * marker_pulse,
			_hijack_marker_base_scale.y,
			_hijack_marker_base_scale.z * marker_pulse
		)

	if hijack_available:
		_hijack_marker.visible = true
		_marker_material.emission_energy_multiplier = 0.8 + 0.16 * sin(_pulse_time * 8.0)
	else:
		_hijack_marker.visible = false


func _update_rammed(delta: float, run_speed: float) -> void:
	_pulse_time += delta
	_ram_timer = maxf(0.0, _ram_timer - delta)
	_ram_vertical_velocity -= RAM_GRAVITY * delta
	position += Vector3(_ram_velocity.x, 0.0, _ram_velocity.z) * delta
	position.y += _ram_vertical_velocity * delta
	_ram_velocity.x = move_toward(_ram_velocity.x, 0.0, 4.6 * delta)
	_ram_velocity.z = move_toward(_ram_velocity.z, run_speed * 0.12, 10.0 * delta)

	_visual_root.rotation.x += _ram_pitch_speed * delta
	_visual_root.rotation.y += _ram_yaw_speed * delta
	_visual_root.rotation.z += _ram_roll_speed * delta
	_hijack_marker.visible = false
	_sedan_roof_tag.visible = false
	_utility_roof_beacon.visible = false
	_truck_top_marker.visible = false

	_wheel_spin += delta * maxf(12.0, run_speed * 0.9)
	for wheel in _active_wheels:
		wheel.rotation.x = _wheel_spin


func ride_step(delta: float, ride_lane: int, lane_x: float, player_z: float, run_speed: float) -> void:
	_pulse_time += delta
	_ride_mode = true
	_rammed = false
	lane_index = ride_lane
	position.x = move_toward(position.x, lane_x, 20.0 * delta)
	position.z = lerpf(position.z, player_z, minf(1.0, delta * 14.0))
	position.y = lerpf(position.y, 0.0, minf(1.0, delta * 10.0))
	var lateral_offset := lane_x - position.x
	_visual_root.rotation.x = lerpf(_visual_root.rotation.x, deg_to_rad(-1.4), minf(1.0, delta * 6.0))
	_visual_root.rotation.y = lerpf(_visual_root.rotation.y, 0.0, minf(1.0, delta * 8.0))
	_visual_root.rotation.z = lerpf(_visual_root.rotation.z, lateral_offset * 0.07, minf(1.0, delta * 10.0))
	_hijack_marker.visible = false
	_truck_top_marker.visible = vehicle_kind == &"truck"
	_wheel_spin += delta * maxf(15.0, run_speed * 0.88)

	for wheel in _active_wheels:
		wheel.rotation.x = _wheel_spin


func begin_hijack() -> void:
	_ride_mode = true
	_rammed = false
	hijack_available = false
	near_miss_pending = false
	near_miss_awarded = true
	_hijack_marker.visible = false


func begin_ram_knockback(source_x: float, run_speed: float) -> void:
	if _ride_mode or _rammed:
		return

	_ride_mode = false
	_rammed = true
	hijack_available = false
	near_miss_pending = false
	near_miss_awarded = true
	_hijack_marker.visible = false
	position.y = 0.14

	var lateral_dir := float(sign(position.x - source_x))
	if is_zero_approx(lateral_dir):
		lateral_dir = -1.0 if lane_index == 0 else 1.0
		if lane_index == 1 and int(abs(position.z) * 10.0) % 2 == 0:
			lateral_dir = -1.0

	_ram_timer = RAM_DURATION
	_ram_velocity = Vector3(
		lateral_dir * (7.2 + run_speed * 0.08),
		0.0,
		5.8 + run_speed * 0.84
	)
	_ram_vertical_velocity = 4.2 + run_speed * 0.03
	_ram_pitch_speed = deg_to_rad(320.0 + run_speed * 1.8)
	_ram_yaw_speed = lateral_dir * deg_to_rad(150.0 + run_speed * 0.9)
	_ram_roll_speed = lateral_dir * deg_to_rad(420.0 + run_speed * 2.2)


func can_arm_near_miss(player_z: float) -> bool:
	return (
		not _rammed
		and not near_miss_pending
		and not near_miss_awarded
		and position.z > player_z - NEAR_MISS_ARM_BACK_BUFFER
		and position.z < player_z + NEAR_MISS_ARM_FRONT_BUFFER
	)


func arm_near_miss() -> void:
	near_miss_pending = true


func has_cleared_player(player_z: float) -> bool:
	return not _rammed and near_miss_pending and position.z > player_z + NEAR_MISS_CLEAR_BUFFER


func mark_near_miss_awarded() -> void:
	near_miss_pending = false
	near_miss_awarded = true


func is_collision_threat(player_z: float) -> bool:
	if _ride_mode or _rammed:
		return false

	var depth := 1.8
	if vehicle_kind == &"truck":
		depth = TRUCK_COLLISION_DEPTH
	elif vehicle_kind == &"van":
		depth = VAN_COLLISION_DEPTH
	else:
		depth = CAR_COLLISION_DEPTH

	return abs(position.z - player_z) < depth


func can_be_ram_hit(attacker_lane: int, attacker_z: float) -> bool:
	if _ride_mode or _rammed or lane_index != attacker_lane:
		return false

	var back_buffer := 2.0
	var front_buffer := 3.4
	if vehicle_kind == &"truck":
		back_buffer = 2.8
		front_buffer = 4.3
	elif vehicle_kind == &"van":
		back_buffer = 2.3
		front_buffer = 3.8

	return position.z > attacker_z - back_buffer and position.z < attacker_z + front_buffer


func can_be_hijacked(player_lane: int, player_z: float) -> bool:
	var hijack_anchor_z := position.z + TRUCK_HIJACK_ANCHOR_Z
	return vehicle_kind == &"truck" and not _rammed and hijack_available and lane_index == player_lane and hijack_anchor_z > player_z - TRUCK_HIJACK_BACK_BUFFER and hijack_anchor_z < player_z + TRUCK_HIJACK_FRONT_BUFFER


func can_be_stealth_combo(player_lane: int, player_z: float) -> bool:
	if _ride_mode or _rammed or _stealth_pass_awarded or lane_index != player_lane:
		return false

	var depth := 2.0
	if vehicle_kind == &"truck":
		depth = 3.0
	elif vehicle_kind == &"van":
		depth = 2.35

	return abs(position.z - player_z) < depth


func mark_stealth_combo_awarded() -> void:
	_stealth_pass_awarded = true
	near_miss_pending = false
	near_miss_awarded = true
	hijack_available = false


func should_despawn(limit_z: float) -> bool:
	if _rammed:
		return _ram_timer <= 0.0 or position.y < -1.25 or abs(position.x) > RAM_DESPAWN_X or position.z > limit_z + 14.0

	return not _ride_mode and position.z > limit_z


func get_lane_index() -> int:
	return lane_index
