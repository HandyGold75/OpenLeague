extends Control

@onready var display_option_button = $CenterContainer/VBoxContainer/Display


func _ready():
	var video_config = ConfigHandler.load_video_config()
	display_option_button.selected = video_config["display"]


func _on_display_item_selected(index: int):
	ConfigHandler.save_video_config("display", index)
	ConfigHandler.activate_video_config()
