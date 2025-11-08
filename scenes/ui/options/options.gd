extends Control
@onready var music_slider: HSlider = $Layout/MarginContainer/Menu/MusicVolume/MusicSlider
@onready var effect_slider: HSlider = $Layout/MarginContainer/Menu/EffectVolume/EffectSlider
@onready var option_button: OptionButton = $Layout/MarginContainer/Menu/Resolution/OptionButton




func _ready() -> void:
	option_button.select(GameManager.settings.get("resolution", 0))
	music_slider.value = GameManager.settings.get("music", 1)
	effect_slider.value = GameManager.settings.get("effect", 1)
	get_tree().root.content_scale_size = GameManager.resolutions[GameManager.settings.get("resolution", 0)]

func change_volume(value: float, bus: String):
	if bus:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus), linear_to_db(value))
	

func _process(_delta: float) -> void:
	pass


func _on_save_pressed() -> void:
	GameManager.settings["resolution"] = option_button.selected
	GameManager.settings["music"] = music_slider.value
	GameManager.settings["effect"] = effect_slider.value
	GameManager.save_settings()
	get_tree().change_scene_to_file("res://scenes/ui/main.tscn")
