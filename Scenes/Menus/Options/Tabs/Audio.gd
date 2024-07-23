extends Control

@onready var master_volume_slider = $CenterContainer/VBoxContainer/HBoxContainer/Volume


func _ready():
	var audio_config = ConfigHandler.load_audio_config()
	master_volume_slider.value = audio_config ["master_volume"]


func _on_volume_drag_ended(value_changed: bool):
	if value_changed:
		ConfigHandler.save_audio_config("master_volume", float(master_volume_slider.value))
		ConfigHandler.activate_audio_config()
