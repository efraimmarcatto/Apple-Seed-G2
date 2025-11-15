extends VisibleOnScreenNotifier2D

@export var apple:PackedScene
@export var level_area:Node2D

func _on_screen_exited() -> void:
	if level_area:
		var size = get_children_in_group(level_area,"Food").size()
		if apple and size == 0:
			var instance_apple = apple.instantiate()
			get_parent().add_child(instance_apple)
			instance_apple.global_position = global_position


func get_children_in_group(parent_node: Node, group_name: String) -> Array:
	var children_in_group = []
	for child in parent_node.get_children():
		if child.is_in_group(group_name):
			children_in_group.append(child)
	return children_in_group
