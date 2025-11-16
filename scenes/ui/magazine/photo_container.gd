extends HBoxContainer
@onready var photo: TextureRect = $Photo
@onready var label: Label = $Label

var photo_texture: Texture
var text: String
var reverse: bool = false

func _ready() -> void:
	if text and photo_texture:
		if reverse:
			move_child(label, 0)
		label.text = text
		photo.texture = photo_texture
		show()
