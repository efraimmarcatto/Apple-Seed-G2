class_name EditorInputMap
extends EditorPlugin

func create_input_map() -> void:
	# MOVE LEFT
	_add_action_with_keycode("key_left", KEY_A)
	_add_action_with_keycode("key_left", KEY_LEFT)
	_add_action_with_joypad_axis("key_left", JOY_AXIS_LEFT_X, -1.0)
	
	# MOVE RIGHT
	_add_action_with_keycode("key_right", KEY_D)
	_add_action_with_keycode("key_right", KEY_RIGHT)
	_add_action_with_joypad_axis("key_right", JOY_AXIS_LEFT_X, 1.0)
	
	# MOVE UP
	_add_action_with_keycode("key_up", KEY_W)
	_add_action_with_keycode("key_up", KEY_UP)
	_add_action_with_joypad_axis("key_up", JOY_AXIS_LEFT_Y, -1.0)
	
	# MOVE DOWN
	_add_action_with_keycode("key_down", KEY_S)
	_add_action_with_keycode("key_down", KEY_DOWN)
	_add_action_with_joypad_axis("key_down", JOY_AXIS_LEFT_Y, 1.0)
	
	# AÇÃO PRINCIPAL
	_add_action_with_keycode("key_action", KEY_SPACE)
	_add_action_with_keycode("key_action", KEY_ENTER)
	_add_action_with_joypad_button("key_action", JOY_BUTTON_A)

	# CANCELAR / VOLTAR
	_add_action_with_keycode("key_cancel", KEY_ESCAPE)
	_add_action_with_keycode("key_cancel", KEY_BACKSPACE)
	_add_action_with_joypad_button("key_cancel", JOY_BUTTON_B)

	# INTERAÇÃO SECUNDÁRIA / CONFIRMAR
	_add_action_with_keycode("key_confirm", KEY_E)
	_add_action_with_keycode("key_confirm", KEY_KP_ENTER)
	_add_action_with_joypad_button("key_confirm", JOY_BUTTON_X)

	# MENU / PAUSE
	_add_action_with_keycode("key_pause", KEY_P)
	_add_action_with_joypad_button("key_pause", JOY_BUTTON_START)

	# INVENTÁRIO / OPÇÕES
	_add_action_with_keycode("key_inventory", KEY_TAB)
	_add_action_with_joypad_button("key_inventory", JOY_BUTTON_BACK)

	# L1 / R1 (botões de ombro)
	_add_action_with_keycode("key_l1", KEY_Q)
	_add_action_with_joypad_button("key_l1", JOY_BUTTON_LEFT_SHOULDER)

	_add_action_with_keycode("key_r1", KEY_E)
	_add_action_with_joypad_button("key_r1", JOY_BUTTON_RIGHT_SHOULDER)

	# L2 / R2 (triggers analógicos)
	_add_action_with_joypad_axis("key_l2", JOY_AXIS_TRIGGER_LEFT, 1.0)
	_add_action_with_joypad_axis("key_r2", JOY_AXIS_TRIGGER_RIGHT, 1.0)
	
	InputMap.load_from_project_settings()
	print("✅ Input Map created!")
	
func remove_input_map() -> void:
	var actions = [
		"key_left",
		"key_right",
		"key_up",
		"key_down",
		"key_action",
		"key_cancel",
		"key_confirm",
		"key_pause",
		"key_inventory",
		"key_l1",
		"key_r1",
		"key_l2",
		"key_r2"
	]
	
	for action in actions:
		ProjectSettings.set_setting('input/' + action, null)
	ProjectSettings.save()
	InputMap.load_from_project_settings()
	print("❌ Input Map removido!")

func _add_action_with_keycode(action:String, key:Key) -> void:
	var event = InputEventKey.new()
	event.physical_keycode = key
	_add_action(action, event)
	
func _add_action_with_joypad_axis(action:String, axis:JoyAxis, axis_value:float) -> void:
	var event = InputEventJoypadMotion.new()
	event.axis = axis
	event.axis_value = axis_value
	_add_action(action, event)
	
func _add_action_with_joypad_button(action:String, button:JoyButton) -> void:
	var event = InputEventJoypadButton.new()
	event.button_index = button
	_add_action(action, event)
	
func _add_action(action:String, event:InputEvent) -> void:
	var input = ProjectSettings.get_setting('input/' + action)
	if not input:
		input = {
			"deadzone": 0.5,
			"events": []
		}
		
	input.events.append(event)
	
	# Set the input/<name_of_your_input_action> in the project settings
	ProjectSettings.set_setting('input/' + action, input)
	ProjectSettings.save()
