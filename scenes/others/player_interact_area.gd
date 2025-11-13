extends Area2D

@export var enabled: bool = true
@export var show_on_player_enter:Node2D ## mostra quando o plauyer entrar

@export var button_action_name: String = "key_action"
@export var change_to_level: String
@export var audio: AudioStreamPlayer

signal player_entered
signal player_exited

signal button_just_pressed

var player_inside: bool = false

func _ready() -> void:
	# Conecta o sinal de colisão (se existir no target)
	body_entered.connect(_on_player_entered)
	body_exited.connect(_on_player_exited)
	
	if show_on_player_enter:
		show_on_player_enter.visible = false

func _process(_delta: float) -> void:
	if player_inside and button_action_name and Input.is_action_just_pressed(button_action_name):
		button_just_pressed.emit()
		if change_to_level:
			SceneGameManager.change_scene(change_to_level)
		
func _on_player_entered(body: Node) -> void:
	if enabled and body.is_in_group("Player"):
		player_entered.emit()
		if show_on_player_enter:
			if audio:
				audio.play()
			player_inside = true
			show_on_player_enter.visible = true
		
func _on_player_exited(body: Node) -> void:
	if enabled and body.is_in_group("Player"):
		player_inside = false
		player_exited.emit()
		if show_on_player_enter:
			show_on_player_enter.visible = false

func enable() -> void:
	enabled = true

func disable() -> void:
	enabled = false
