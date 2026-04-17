extends SceneTree

const EXPORTS := [
	{
		"source": "res://assets/third_party/quaternius/cars/SportsCar.obj",
		"dest": "res://assets/runtime/meshes/vehicles/sports_car.res",
	},
	{
		"source": "res://assets/third_party/quaternius/cars/NormalCar1.obj",
		"dest": "res://assets/runtime/meshes/vehicles/normal_car_1.res",
	},
	{
		"source": "res://assets/third_party/quaternius/cars/NormalCar2.obj",
		"dest": "res://assets/runtime/meshes/vehicles/normal_car_2.res",
	},
	{
		"source": "res://assets/third_party/quaternius/cars/Taxi.obj",
		"dest": "res://assets/runtime/meshes/vehicles/taxi.res",
	},
	{
		"source": "res://assets/third_party/quaternius/cars/Cop.obj",
		"dest": "res://assets/runtime/meshes/vehicles/cop.res",
	},
	{
		"source": "res://assets/third_party/quaternius/cars/SUV.obj",
		"dest": "res://assets/runtime/meshes/vehicles/suv.res",
	},
	{
		"source": "res://assets/third_party/quaternius/public_transport/Ambulance.obj",
		"dest": "res://assets/runtime/meshes/vehicles/ambulance.res",
	},
	{
		"source": "res://assets/third_party/quaternius/public_transport/Bus.obj",
		"dest": "res://assets/runtime/meshes/vehicles/bus.res",
	},
	{
		"source": "res://assets/third_party/quaternius/public_transport/SchoolBus.obj",
		"dest": "res://assets/runtime/meshes/vehicles/school_bus.res",
	},
	{
		"source": "res://assets/third_party/quaternius/modular_streets/Streetlight_Double.obj",
		"dest": "res://assets/runtime/meshes/props/streetlight_double.res",
	},
	{
		"source": "res://assets/third_party/quaternius/modular_streets/TrafficLight.obj",
		"dest": "res://assets/runtime/meshes/props/traffic_light.res",
	},
	{
		"source": "res://assets/third_party/quaternius/modular_streets/Sign_Stop.obj",
		"dest": "res://assets/runtime/meshes/props/sign_stop.res",
	},
	{
		"source": "res://assets/third_party/quaternius/modular_streets/Sign_Triangle.obj",
		"dest": "res://assets/runtime/meshes/props/sign_triangle.res",
	},
	{
		"source": "res://assets/audio/music/nfs_mw_9_0.mp3",
		"dest": "res://assets/runtime/audio/music/nfs_mw_9_0.res",
	},
	{
		"source": "res://assets/audio/gameplay/engine_loop.wav",
		"dest": "res://assets/runtime/audio/gameplay/engine_loop.res",
	},
	{
		"source": "res://assets/audio/ui/start_run.wav",
		"dest": "res://assets/runtime/audio/ui/start_run.res",
	},
	{
		"source": "res://assets/audio/gameplay/jump.wav",
		"dest": "res://assets/runtime/audio/gameplay/jump.res",
	},
	{
		"source": "res://assets/audio/gameplay/near_miss.wav",
		"dest": "res://assets/runtime/audio/gameplay/near_miss.res",
	},
	{
		"source": "res://assets/audio/gameplay/hijack.wav",
		"dest": "res://assets/runtime/audio/gameplay/hijack.res",
	},
	{
		"source": "res://assets/audio/ui/upgrade.wav",
		"dest": "res://assets/runtime/audio/ui/upgrade.res",
	},
	{
		"source": "res://assets/audio/ui/promote.wav",
		"dest": "res://assets/runtime/audio/ui/promote.res",
	},
	{
		"source": "res://assets/audio/ui/crash.wav",
		"dest": "res://assets/runtime/audio/ui/crash.res",
	},
	{
		"source": "res://assets/audio/ui/fuel_empty.wav",
		"dest": "res://assets/runtime/audio/ui/fuel_empty.res",
	},
	{
		"source": "res://assets/audio/gameplay/stealth_pickup.wav",
		"dest": "res://assets/runtime/audio/gameplay/stealth_pickup.res",
	},
	{
		"source": "res://assets/audio/voice/go_go_go.wav",
		"dest": "res://assets/runtime/audio/voice/go_go_go.res",
	},
	{
		"source": "res://assets/audio/voice/good.wav",
		"dest": "res://assets/runtime/audio/voice/good.res",
	},
	{
		"source": "res://assets/audio/voice/cool.wav",
		"dest": "res://assets/runtime/audio/voice/cool.res",
	},
	{
		"source": "res://assets/audio/voice/great.wav",
		"dest": "res://assets/runtime/audio/voice/great.res",
	},
	{
		"source": "res://assets/audio/voice/perfect.wav",
		"dest": "res://assets/runtime/audio/voice/perfect.res",
	},
	{
		"source": "res://assets/audio/voice/well_done.wav",
		"dest": "res://assets/runtime/audio/voice/well_done.res",
	},
	{
		"source": "res://assets/audio/voice/wonderful.wav",
		"dest": "res://assets/runtime/audio/voice/wonderful.res",
	},
	{
		"source": "res://assets/audio/voice/excellent.wav",
		"dest": "res://assets/runtime/audio/voice/excellent.res",
	},
	{
		"source": "res://assets/audio/voice/amazing.wav",
		"dest": "res://assets/runtime/audio/voice/amazing.res",
	},
	{
		"source": "res://assets/audio/voice/unbelievable.wav",
		"dest": "res://assets/runtime/audio/voice/unbelievable.res",
	},
	{
		"source": "res://assets/audio/voice/i_love_you.wav",
		"dest": "res://assets/runtime/audio/voice/i_love_you.res",
	},
]


func _init() -> void:
	var export_count := 0
	var failures: PackedStringArray = []

	for entry in EXPORTS:
		var source_path := String(entry["source"])
		var dest_path := String(entry["dest"])
		var dir_error := _ensure_parent_dir(dest_path)
		if dir_error != OK:
			failures.append("%s -> %s (mkdir error %d)" % [source_path, dest_path, dir_error])
			continue

		var resource := load(source_path)
		if resource == null:
			failures.append("%s -> %s (load failed)" % [source_path, dest_path])
			continue

		var save_error := ResourceSaver.save(resource, dest_path)
		if save_error != OK:
			failures.append("%s -> %s (save error %d)" % [source_path, dest_path, save_error])
			continue

		export_count += 1

	if failures.is_empty():
		print("Exported %d runtime assets." % export_count)
		quit()
		return

	push_error("Failed exporting %d runtime assets:\n%s" % [failures.size(), "\n".join(failures)])
	quit(1)


func _ensure_parent_dir(resource_path: String) -> int:
	return DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(resource_path.get_base_dir()))
