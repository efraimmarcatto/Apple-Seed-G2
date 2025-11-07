extends Area2D
class_name Collectable

var is_carried: bool = false

func _ready() -> void:
	add_to_group(Globals.GROUP_COLLECTABLE)


func carry() -> void:
	is_carried = true
	z_index = 1
	
func throw() -> void:
	is_carried = false
	z_index = 0
