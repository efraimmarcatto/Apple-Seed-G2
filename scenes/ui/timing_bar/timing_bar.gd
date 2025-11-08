extends HSlider

signal skill_check_completed(accuracy_percent)

@export var sweet_spot_value: float = 25.0
@export var loop_duration: float = 2.0 


@onready var sweet_spot_marker: TextureRect = $TextureRect

var tween: Tween
var is_active: bool = false
var max_possible_distance: float = 1.0 


func _ready():
	
	min_value = 0
	max_value = 50
	value = 0
	editable = false 

	
	position_sweet_spot_marker()

	
	
	var dist_to_min = sweet_spot_value - min_value
	var dist_to_max = max_value - sweet_spot_value
	max_possible_distance = max(dist_to_min, dist_to_max)
	
	
	if max_possible_distance == 0:
		max_possible_distance = 1.0



func position_sweet_spot_marker():
	if not sweet_spot_marker:
		print("Erro: Nó TextureRect (marcador) não encontrado como filho.")
		return

	var percent: float = sweet_spot_value / max_value
	var slider_width: float = size.x
	sweet_spot_marker.position.x = (percent * slider_width) - (sweet_spot_marker.size.x / 2.0)


func start_skill_check():
	if is_active:
		return 

	is_active = true
	value = 0 
	
	if tween:
		tween.kill() 
	
	tween = create_tween()
	tween.set_loops()
	tween.set_trans(Tween.TRANS_LINEAR) 

	var half_duration = loop_duration / 2.0
	tween.tween_property(self, "value", max_value, half_duration)
	tween.tween_property(self, "value", min_value, half_duration)


func stop_skill_check():
	if not is_active:
		return 

	is_active = false
	tween.stop() 
	
	var final_value: float = value
	var distance_from_sweet_spot = abs(final_value - sweet_spot_value)
	var accuracy_ratio = 1.0 - (distance_from_sweet_spot / max_possible_distance)
	
	accuracy_ratio = clamp(accuracy_ratio, 0.0, 1.0)
	
	var accuracy_percent = accuracy_ratio * 100.0
	
	print("Jogador parou em: %.1f" % final_value)
	print("Qualidade da Foto: %.1f%%" % accuracy_percent)

	skill_check_completed.emit(accuracy_percent)


func _input(_event):
	if Input.is_action_just_pressed("ui_accept"):
		if is_active:
			stop_skill_check()
