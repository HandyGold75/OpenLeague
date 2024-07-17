extends Control

@onready var start_boost_spinbox = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Start Boost"
@onready var unlimited_boost_toggle = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Unlimited Boost"

func _ready():
	var tweaks_config = ConfigHandler.load_tweaks_config()
	start_boost_spinbox.value = tweaks_config["start_boost"]
	unlimited_boost_toggle.button_pressed = tweaks_config["unlimited_boost"]

func _on_start_boost_value_changed(value: float):
	ConfigHandler.save_tweaks_config("start_boost", int(value))

func _on_unlimited_boost_toggled(toggled_on: bool):
	ConfigHandler.save_tweaks_config("unlimited_boost", toggled_on)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Options/Options.tscn")
