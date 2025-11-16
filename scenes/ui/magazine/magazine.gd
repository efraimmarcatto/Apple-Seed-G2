extends Control

@onready var container_list: VBoxContainer = %ContainerList
var photo_container = preload("res://scenes/ui/magazine/photo_container.tscn")

var photos = GameManager.photos
var is_last_reverse := false

func _ready() -> void:
	for child in container_list.get_children():
		child.queue_free()

	for photo_info in photos:
		var container = photo_container.instantiate()
		var filename = photo_info.get("filename")
		var file_path = "user://photos/%s.png" % (filename)

		if not FileAccess.file_exists(file_path):
			continue

		var image = Image.load_from_file(file_path)
		if image.is_empty():
			continue

		var texture = ImageTexture.create_from_image(image)
		container.photo_texture = texture
		container.text = "texto"
		container.reverse = !is_last_reverse
		is_last_reverse = !is_last_reverse
		container_list.add_child(container)


func _on_close_page_pressed() -> void:
	SceneGameManager.change_scene("res://scenes/ui/magazine/final.tscn")
