extends StaticBody2D

@export var area_2d: Area2D

@export var show_on_player_enter:Node2D ## mostra quando o plauyer entrar

@export var button_action_name: String = "key_action"
@export var audio: AudioStreamPlayer

@export var animation_player: AnimationPlayer

var player_inside: bool = false
var open = false

func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	if area_2d:
		area_2d.body_entered.connect(_on_player_entered)
		area_2d.body_exited.connect(_on_player_exited)
		
	if show_on_player_enter:
		show_on_player_enter.visible = false
	
func _process(_delta: float) -> void:
	if player_inside and button_action_name and Input.is_action_just_pressed(button_action_name):
		open = !open
		if open:
			animation_player.play("open")
		else:
			animation_player.play("close")
	elif not player_inside and open:
		if animation_player.is_playing():
			await animation_player.animation_finished
		open = false
		animation_player.play("close")
		
func _on_player_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		if show_on_player_enter:
			if audio:
				audio.play()
			player_inside = true
			show_on_player_enter.visible = true
		
func _on_player_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_inside = false
		if show_on_player_enter:
			show_on_player_enter.visible = false
