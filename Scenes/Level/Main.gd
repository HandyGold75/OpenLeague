extends Node3D


func _ready() -> void:
	var stadium = load("res://Assets/Models/Stadiums/" + ConfigHandler.hotconfig.level_selected_stadium + ".tscn").instantiate()
	get_node("Stadiums").add_child(stadium)

	var ball = load("res://Assets/Models/Balls/" + ConfigHandler.hotconfig.level_selected_ball + ".tscn").instantiate()
	ball.position = Vector3(0, 10, 15)
	get_node("Balls").add_child(ball)

	var car = load("res://Assets/Models/Cars/" + ConfigHandler.hotconfig.level_selected_ball + ".tscn").instantiate()
	car.position = Vector3(0, 1, 0)
	car.set_script(preload("res://Scenes/Level/Car.gd"))
	get_node("Cars").add_child(car)


func apply_configs() -> void:
	var car := get_node("Cars").get_child(0)
	var control_config := ConfigHandler.load_control_config()

	car.control_config = control_config
	car.steer_sens = control_config["steer_sens"]
	car.tilt_sens = control_config["tilt_sens"]
	car.joystick_deadzone = control_config["joystick_deadzone"]
	car.camera_rotation_sens = control_config["camera_rotation_sens"]
	car.camera_center_speed = control_config["camera_center_speed"]
	car.camera_center_delay = control_config["camera_center_delay"]


func _on_pause_toggled(is_paused: bool) -> void:
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		apply_configs()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
