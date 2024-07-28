extends Control

signal toggled(is_paused: bool)


func _ready() -> void:
	hide()


func set_pause_state(state: bool) -> void:
	$".".visible = state
	get_tree().paused = state
	toggled.emit(state)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		set_pause_state(!get_tree().paused)


func _on_back_pressed() -> void:
	set_pause_state(false)


func _on_exit_pressed() -> void:
	set_pause_state(false)
	get_tree().change_scene_to_file("res://Scenes/Menus/Main.tscn")
