@tool
extends EditorPlugin

var editor_input_map = EditorInputMap.new()
var physics_layer_map = PhysicsLayerMap.new()
var editorInspectorPlugin =  preload("res://addons/fast_prototype/editor/signal_method_selector_inspector.gd").new()


func _enter_tree() -> void:
	# Muito importante: registrar deferred para garantir que o inspector esteja pronto
	call_deferred("_enable_inspector_plugins")

func _exit_tree() -> void:
	call_deferred("_disable_inspector_plugins")

func _enable_inspector_plugins() -> void:
	add_inspector_plugin(editorInspectorPlugin)
	print("✅ Inspector plugin registrado:", editorInspectorPlugin)

func _disable_inspector_plugins() -> void:
	remove_inspector_plugin(editorInspectorPlugin)
	print("❌ Inspector plugin removido")

func _enable_plugin() -> void:
	editor_input_map.create_input_map()
	physics_layer_map.create_physics_layer_map()

func _disable_plugin() -> void:
	editor_input_map.remove_input_map()
	physics_layer_map.remove_physics_layer_map()
