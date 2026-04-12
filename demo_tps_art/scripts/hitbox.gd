extends Area3D

@export var zone: StringName = &"torso"
@export var damage: int = 35
@export var instant_kill := false


func get_damage_receiver() -> Node:
	var node := get_parent()
	while node:
		if node.has_method(&"take_hit"):
			return node
		node = node.get_parent()
	return null
