extends Control


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _on_freeplay_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Freeplay/Freeplay.tscn")


func _on_options_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Options/Options.tscn")


func _on_quit_pressed() -> void:
	get_tree().quit()
