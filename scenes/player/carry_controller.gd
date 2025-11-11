extends Area2D
class_name CarryController

@export var carry_marker_2d: Marker2D
@export var player: Player
@export var character_movement_controller: CharacterMovementController
@export var carry_arrow:Sprite2D


var carrying_collectable: Collectable = null ## item carregado
var near_collectable: Collectable = null ## coletavel em frente

func _ready() -> void:
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	if carry_arrow:
		carry_arrow.visible = false

func _process(_delta: float) -> void:
	if carrying_collectable and Input.is_action_just_pressed('key_action'):
		throw_collectable()
	elif Input.is_action_just_pressed('key_action'):
		pick_collectable()
		
	if carrying_collectable and is_instance_valid(carrying_collectable) and carrying_collectable.has_method("set_carry_position"):
		carrying_collectable.set_carry_position(carry_marker_2d.global_position)

func is_carrying() -> bool:
	return (carrying_collectable and is_instance_valid(carrying_collectable) and carrying_collectable.has_method("is_carried") and carrying_collectable.is_carried()) or Input.is_action_pressed("key_action")

func is_carrying_food() -> bool:
	return is_carrying() and carrying_collectable.parent and carrying_collectable.parent.is_in_group("Food")

func pick_collectable() -> void:
	if near_collectable and is_instance_valid(near_collectable) and near_collectable.has_method("is_carryble") and near_collectable.is_carryble():
		carrying_collectable = near_collectable
		near_collectable = null
		carrying_collectable.carry(player, carry_marker_2d.global_position)
		
		if carry_arrow:
			await get_tree().create_timer(0.15).timeout
			if carrying_collectable and is_instance_valid(carrying_collectable):
				carry_arrow.visible = true
		
func throw_collectable() -> void:
	if player.is_on_wall() or player.is_on_ceiling() or player.is_on_floor():
		if not _can_throw_based_on_collisions(character_movement_controller.last_movement_direction):
			return
	
	if carrying_collectable and is_instance_valid(carrying_collectable):
		if character_movement_controller:
			carrying_collectable.throw(character_movement_controller.last_movement_direction)
	carrying_collectable = null
	
	if carry_arrow:
		carry_arrow.visible = false
	
	# remove a colisão do player com o item temporariamente
	if player:
		player.set_collision_mask_value(5, false)
		await get_tree().create_timer(0.1).timeout
		player.set_collision_mask_value(5, true)
	
func eat_collectable() -> void:
	if carrying_collectable and is_carrying_food():
		if carry_arrow:
			carry_arrow.visible = false
		carrying_collectable.parent.be_bitten()
		carrying_collectable = null


func _can_throw_based_on_collisions(throw_dir: Vector2) -> bool:
	if throw_dir == Vector2.ZERO or not player:
		return false

	throw_dir = throw_dir.normalized()

	# 1) Se não há colisões registradas pelo slide -> livre para lançar
	if player.get_slide_collision_count() == 0:
		return true

	var has_water_in_throw_dir := false

	# 2) Verifica cada colisão registrada
	for i in range(player.get_slide_collision_count()):
		var collision := player.get_slide_collision(i)
		if not collision:
			continue
		var collider := collision.get_collider()
		if not collider:
			continue

		var collision_normal := collision.get_normal().normalized()
		var toward_obstacle := -collision_normal
		var alignment := throw_dir.dot(toward_obstacle)

		# Se a colisão está bem alinhada com a direção do arremesso
		if alignment > 0.6:
			# Se for água, marca e continua (permitido se for só água)
			if collider.is_in_group("Water"):
				has_water_in_throw_dir = true
				continue
			# Se não for água, bloqueia direto
			return false

	# 3) Confirmação extra com test_move (deslocamento pequeno)
	if not has_water_in_throw_dir:
		var test_distance := 1.0
		var motion := throw_dir * test_distance

		# Se ao mover um pouco houver colisão, só permite se detectamos água na direção
		if player.test_move(player.transform, motion):
			return false

	# Se não test_move (livre), permite
	return true


func _on_area_entered(area:Area2D) -> void:
	if area.is_in_group(Globals.GROUP_COLLECTABLE) and area.has_method("is_carryble") and area.is_carryble():
		near_collectable = area

func _on_area_exited(area:Area2D) -> void:
	if area.is_in_group(Globals.GROUP_COLLECTABLE):
		if area == near_collectable:
			near_collectable = null
