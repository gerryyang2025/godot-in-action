extends Node3D

const PICKUP_HEIGHT := 0.72
const COLLECT_WINDOW := 1.45

var lane_index := 0
var pickup_kind: StringName = &"stealth"

var _pulse_time := 0.0
var _collected := false
var _collect_timer := 0.0
var _core_material := StandardMaterial3D.new()
var _ring_material := StandardMaterial3D.new()
var _halo_material := StandardMaterial3D.new()

@onready var _visual_root: Node3D = $VisualRoot
@onready var _core: MeshInstance3D = $VisualRoot/Core
@onready var _ring_outer: MeshInstance3D = $VisualRoot/RingOuter
@onready var _ring_inner: MeshInstance3D = $VisualRoot/RingInner
@onready var _halo: MeshInstance3D = $VisualRoot/Halo


func _ready() -> void:
	_configure_materials()
	_core.material_override = _core_material
	_ring_outer.material_override = _ring_material
	_ring_inner.material_override = _ring_material
	_halo.material_override = _halo_material
	_apply_palette(Color(0.427451, 0.956863, 1.0, 1.0))


func _configure_materials() -> void:
	for material in [_core_material, _ring_material, _halo_material]:
		material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
		material.emission_enabled = true

	_core_material.roughness = 0.08
	_core_material.metallic = 0.18
	_ring_material.roughness = 0.18
	_ring_material.metallic = 0.05
	_halo_material.roughness = 0.02


func _apply_palette(color: Color) -> void:
	_core_material.albedo_color = Color(color.r, color.g, color.b, 0.88)
	_core_material.emission = color.lightened(0.08)
	_core_material.emission_energy_multiplier = 0.8

	_ring_material.albedo_color = Color(color.r, color.g, color.b, 0.5)
	_ring_material.emission = color
	_ring_material.emission_energy_multiplier = 0.65

	_halo_material.albedo_color = Color(color.r, color.g, color.b, 0.22)
	_halo_material.emission = color.lightened(0.15)
	_halo_material.emission_energy_multiplier = 1.0


func configure(kind: StringName, lane: int, lane_x: float, start_z: float) -> void:
	pickup_kind = kind
	lane_index = lane
	position = Vector3(lane_x, PICKUP_HEIGHT, start_z)
	_pulse_time = 0.0
	_collected = false
	_collect_timer = 0.0
	_visual_root.visible = true
	_visual_root.scale = Vector3.ONE
	_apply_palette(Color(0.427451, 0.956863, 1.0, 1.0))


func advance(delta: float, run_speed: float) -> void:
	_pulse_time += delta

	if _collected:
		_collect_timer = maxf(0.0, _collect_timer - delta)
		_visual_root.rotation.y += delta * 7.2
		_visual_root.position.y = 0.1 + sin(_pulse_time * 18.0) * 0.08
		_visual_root.scale = _visual_root.scale.lerp(Vector3.ONE * 1.8, minf(1.0, delta * 12.0))
		var fade_ratio := _collect_timer / 0.38
		_core_material.albedo_color.a = 0.88 * fade_ratio
		_ring_material.albedo_color.a = 0.5 * fade_ratio
		_halo_material.albedo_color.a = 0.22 * fade_ratio
		_core_material.emission_energy_multiplier = 0.5 + fade_ratio
		_ring_material.emission_energy_multiplier = 0.4 + fade_ratio * 0.7
		_halo_material.emission_energy_multiplier = 0.6 + fade_ratio * 1.1
		return

	position.z += run_speed * delta
	_visual_root.position.y = sin(_pulse_time * 4.8) * 0.22
	_visual_root.rotation.y += delta * 2.3
	_ring_outer.rotation.z += delta * 1.8
	_ring_inner.rotation.x += delta * 2.6
	var pulse := 1.0 + 0.15 * sin(_pulse_time * 8.0)
	_core.scale = Vector3.ONE * pulse
	_halo.scale = Vector3(1.0 + pulse * 0.2, 1.0, 1.0 + pulse * 0.2)
	_core_material.emission_energy_multiplier = 0.8 + 0.18 * sin(_pulse_time * 6.0)
	_ring_material.emission_energy_multiplier = 0.6 + 0.14 * sin(_pulse_time * 7.2)
	_halo_material.emission_energy_multiplier = 0.95 + 0.22 * sin(_pulse_time * 5.6)


func can_be_collected(player_lane: int, player_z: float) -> bool:
	return not _collected and lane_index == player_lane and abs(position.z - player_z) < COLLECT_WINDOW


func collect() -> void:
	_collected = true
	_collect_timer = 0.38


func should_despawn(limit_z: float) -> bool:
	if _collected:
		return _collect_timer <= 0.0
	return position.z > limit_z


func get_lane_index() -> int:
	return lane_index
