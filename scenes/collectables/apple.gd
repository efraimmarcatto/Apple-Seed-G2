extends CharacterBody2D
class_name Apple

@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal was_eaten

func  be_bitten() -> void:
	animation_player.play('be_bitten')
	await get_tree().create_timer(1.5, false).timeout
	was_eaten.emit()
	call_deferred("queue_free")
