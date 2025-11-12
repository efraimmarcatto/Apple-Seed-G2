extends TextureRect
@export var icon_frame_width: int = 32
@onready var label: Label = $Label


func _ready():
	if not (texture is AtlasTexture):
		print("Erro: A textura deste nó não é um AtlasTexture!")
		print("Configure o AtlasTexture no Inspetor primeiro.")
		return


	if GameManager.has_signal("photo_count_updated"):
		GameManager.photo_count_updated.connect(_on_photo_count_updated)
	else:
		print("Sinal 'photo_count_updated' não encontrado no GameManager.")


	_on_photo_count_updated(0)



func _on_photo_count_updated(new_count: int):

	var atlas: AtlasTexture = texture
	if not atlas:
		return
		

	new_count = clamp(new_count, 0, GameManager.photos_limit)
	
	var current_region: Rect2 = atlas.region
	if new_count > 0:
		current_region.position.x = 160
		label.text = str(new_count)
	else:
		current_region.position.x = 0
		label.text = ""
	
	atlas.region = current_region
