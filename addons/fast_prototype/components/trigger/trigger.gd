@tool
extends Node2D
class_name Trigger

enum TYPES { MULTIPLE, SEQUENCE }

@export var trigger_once:bool = true ## funciona apenas uma vez
@export var type:TYPES = TYPES.MULTIPLE ## tipo de ativação
@export var time_interval:float = 0.2 ## tempo entre as ativações

@export_category("Trigger")
@export var signal_trigger: NodeSignal = null ## node e evento que ativa o trigger

@export_category("Targets")
@export var targets: Array[NodeMethod] = [] ## metodos alvos do trigger

@export_category("Sound")
@export var trigger_sound:AudioStreamPlayer2D ## barulho ao ativar

signal trigged

func _ready() -> void:
	if not Engine.is_editor_hint():
		if signal_trigger:
			signal_trigger.connect_signal(self, _on_trigger_active)
				
func _on_trigger_active() -> void:
	trigged.emit()
	
	if type == TYPES.MULTIPLE:
		if time_interval:
			await get_tree().create_timer(time_interval).timeout
		if trigger_sound:
			trigger_sound.play()
	
	for target in targets:
		if type == TYPES.SEQUENCE:
			if time_interval:
				await get_tree().create_timer(time_interval).timeout
			if trigger_sound:
				trigger_sound.play()
		call_target_method(target)
			
	if trigger_once:
		if trigger_sound:
			await trigger_sound.finished
		call_deferred("queue_free")

func call_target_method(target:NodeMethod) -> void:
	if target and target.target_method_node:
		target.call_method(self)
		
func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		queue_redraw()

func _draw() -> void:
	if Engine.is_editor_hint():
		# quadrado verde em volta do node
		var size = Vector2(5, 5)
		var rect = Rect2((size/2) * -1, size)
		draw_rect(rect, Color.DARK_ORCHID, true)
		
		if signal_trigger and signal_trigger.target_signal_node:
			var t := get_node_or_null(signal_trigger.target_signal_node)
			if t and is_instance_valid(t):
				draw_line(Vector2.ZERO, to_local(t.global_position), Color.DARK_ORCHID, 0.5)
		
		# desenhar linhas para os nodes da lista
		var last_point = Vector2.ZERO
		for target in targets:
			if target and target.target_method_node:
				var t := get_node_or_null(target.target_method_node)
				if t and is_instance_valid(t):
					var to = to_local(t.global_position)
					draw_line(last_point, to, Color.CORAL, 0.5)
					draw_circle(to,1,Color.CHOCOLATE, true, )
					if type == TYPES.SEQUENCE:
						last_point = to
