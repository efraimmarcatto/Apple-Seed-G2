extends CanvasLayer

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	pass
	
	
## Troca a cena atual. 
## Aceita tanto um caminho (String) quanto uma cena pronta (PackedScene).
## @param new_scene String | PackedScene
func change_scene(new_scene: Variant) -> void:
	animation_player.play("fade_in")
	CameraManager.disabled()
	await animation_player.animation_finished

	if typeof(new_scene) == TYPE_STRING:
		get_tree().change_scene_to_file(new_scene)
	elif new_scene is PackedScene:
		var instance = new_scene.instantiate()
		get_tree().root.add_child(instance)
		if get_tree().current_scene:
			get_tree().current_scene.queue_free()
		get_tree().current_scene = instance
	else:
		push_warning("Tipo inválido em change_scene(): %s" % typeof(new_scene))
		return

	await get_tree().process_frame
	await get_tree().create_timer(0.2).timeout
	animation_player.play("fade_out")
	await animation_player.animation_finished
	CameraManager.enable()
