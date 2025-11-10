extends TextureRect
@export var icon_frame_width: int = 32

# Vamos assumir que seu GameManager é um Autoload (Singleton)
# Se não for, você precisará conectar o sinal de outra forma
func _ready():
	if not (texture is AtlasTexture):
		print("Erro: A textura deste nó não é um AtlasTexture!")
		print("Configure o AtlasTexture no Inspetor primeiro.")
		return


	if GameManager.has_signal("photo_count_updated"):
		GameManager.photo_count_updated.connect(_on_photo_count_updated)
	else:
		print("Sinal 'photo_count_updated' não encontrado no GameManager.")

	# 3. Define o estado inicial (0 fotos)
	#    (Opcional, mas bom para garantir)
	_on_photo_count_updated(0)


# Esta função é chamada pelo sinal do GameManager
func _on_photo_count_updated(new_count: int):
	# Garante que o recurso de textura é um AtlasTexture
	var atlas: AtlasTexture = texture
	if not atlas:
		return
		
	# Garante que o número esteja dentro dos limites (0 a 4)
	new_count = clamp(new_count, 0, 4)
	
	# Pega a região de corte atual
	var current_region: Rect2 = atlas.region
	
	# Calcula a nova posição X do corte
	# (0 fotos -> x=0)
	# (1 foto  -> x=32)
	# (2 fotos -> x=64) ...
	current_region.position.x = new_count * icon_frame_width
	
	# Define a nova região de corte no AtlasTexture
	atlas.region = current_region
