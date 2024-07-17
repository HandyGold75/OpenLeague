extends Control

@onready var display_option_button = $MarginContainer/VBoxContainer/Display
@onready var master_volume_slider = $MarginContainer/VBoxContainer/HBoxContainer/Volume

func _ready():
	var video_config = ConfigHandler.load_video_config()
	display_option_button.selected = video_config["display"]
	
	var audio_config = ConfigHandler.load_audio_config()
	master_volume_slider.value = audio_config["master_volume"]

func _on_display_item_selected(index: int):
	ConfigHandler.save_video_config("display", index)
	ConfigHandler.activate_video_config()

func _on_volume_drag_ended(value_changed: bool):
	if value_changed:
		ConfigHandler.save_audio_config("master_volume", int(master_volume_slider.value))

func _on_keybinds_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Options/Keybinds.tscn")

func _on_tweaks_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Options/Tweaks.tscn")

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Main.tscn")
