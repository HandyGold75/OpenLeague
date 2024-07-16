extends Control

func _ready():
	var offline_config = ConfigHandler.load_offline_config()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Options/Options.tscn")
