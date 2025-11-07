extends Area2D
class_name CarryController

@export var carry_marker_2d: Marker2D

var carrying_collectable: Collectable = null ## item carregado
var near_collectable: Collectable = null ## coletavel em frente

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed('key_action'):
		pick_collectable()
	if Input.is_action_just_released('key_action'):
		throw_collectable()
	
	if carrying_collectable and is_instance_valid(carrying_collectable) and carry_marker_2d:
		carrying_collectable.global_position = carry_marker_2d.global_position

func is_carrying() -> bool:
	return (carrying_collectable and is_instance_valid(carrying_collectable)) or Input.is_action_pressed("key_action")

func pick_collectable() -> void:
	if near_collectable and is_instance_valid(near_collectable):
		carrying_collectable = near_collectable
		near_collectable = null
		carrying_collectable.carry()

func throw_collectable() -> void:
	if carrying_collectable and is_instance_valid(carrying_collectable):
		carrying_collectable.throw()
		carrying_collectable = null

func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group(Globals.GROUP_COLLECTABLE):
		near_collectable = area

func _on_area_exited(area:Area2D) -> void:
	if area.is_in_group(Globals.GROUP_COLLECTABLE):
		if area == near_collectable:
			near_collectable = null
