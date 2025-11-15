extends Control
@onready var image: TextureRect = $Image
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var frame_width = 320
var frames = 3
var atlas: AtlasTexture
var current_region: Rect2 
var frame_time = 6


func _ready() -> void:
	atlas = image.texture
	current_region = atlas.region
	for frame in range(1, frames+1):
		change_frame(frame)
		animation_player.play("fade_in")
		await animation_player.animation_finished
		await get_tree().create_timer(frame_time).timeout
		animation_player.play("fade_out")
		await animation_player.animation_finished
	start_game()

func change_frame(frame):
	current_region.position.x = frame_width * frame
	atlas.region = current_region

func start_game():
	SceneGameManager.change_scene("res://levels/cabam_level.tscn")
