extends CharacterBody2D
class_name Apple

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func  be_bitten(callback:Callable) -> void:
	animation_player.play('be_bitten')
	await get_tree().create_timer(1.5).timeout
	callback.call()
	call_deferred("queue_free")
