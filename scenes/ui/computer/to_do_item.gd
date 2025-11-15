extends HBoxContainer
@onready var checkbox: TextureRect = $Checkbox
@onready var message: RichTextLabel = $Message
var _message: String
var is_secret: bool = false
var is_checked: bool = false

func _ready() -> void:
	set_message()
	set_checkbox()

func set_message():
	if is_secret:
		_message = "[TOP SECRET] %s " % _message
	message.text = _message
	
func set_checkbox():
	var atlas: AtlasTexture = checkbox.texture
	var current_region: Rect2 = atlas.region
	if is_checked:
		current_region.position.x = 11
		message.text = "[s] %s [/s]" % [message.text]
	else:
		if is_secret:
			hide()
		current_region.position.x = 0
	atlas.region = current_region
