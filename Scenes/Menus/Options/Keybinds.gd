extends Control

var is_remapping = false
var remapping_button = null
var remapping_action = null

@onready
var throttle_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Throttle
@onready
var reverse_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Reverse
@onready
var steer_left_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Steer Left"
@onready
var steer_right_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Steer Right"
@onready
var tilt_up_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Tilt Up"
@onready
var tilt_down_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Tilt Down"
@onready
var tilt_left_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer3/Tilt Left"
@onready
var tilt_right_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer4/Tilt Right"
@onready
var jump_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer5/Jump
@onready
var slide_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer5/Slide 
@onready
var boost_button = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer6/Boost
@onready
var ball_cam_button = $"MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer6/Ball Cam"


func _ready():
	var keybinding_config = ConfigHandler.load_keybinding_config()
	throttle_button.text = input_to_string(keybinding_config["throttle"])
	reverse_button.text = input_to_string(keybinding_config["reverse"])
	steer_left_button.text = input_to_string(keybinding_config["steer_left"])
	steer_right_button.text = input_to_string(keybinding_config["steer_right"])
	tilt_up_button.text = input_to_string(keybinding_config["tilt_up"])
	tilt_down_button.text = input_to_string(keybinding_config["tilt_down"])
	tilt_left_button.text = input_to_string(keybinding_config["tilt_left"])
	tilt_right_button.text = input_to_string(keybinding_config["tilt_right"])
	jump_button.text = input_to_string(keybinding_config["jump"])
	slide_button.text = input_to_string(keybinding_config["slide"])
	boost_button.text = input_to_string(keybinding_config["boost"])
	ball_cam_button.text = input_to_string(keybinding_config["ball_cam"])


func _input(event: InputEvent):
	if (
		!is_remapping
		|| !(
			event is InputEventKey
			|| event is InputEventMouseButton
			|| event is InputEventJoypadButton
		)
	):
		return

	ConfigHandler.save_keybinding_config(remapping_action, event)
	ConfigHandler.activate_keybinding_config()
	remapping_button.text = input_to_string(event)

	remapping_button = null
	remapping_action = null
	is_remapping = false

	accept_event()


func _on_throttle_pressed():
	if is_remapping:
		return
	is_remapping = true

	throttle_button.text = ". . . . ."
	remapping_button = throttle_button
	remapping_action = "throttle"


func _on_reverse_pressed():
	if is_remapping:
		return
	is_remapping = true

	reverse_button.text = ". . . . ."
	remapping_button = reverse_button
	remapping_action = "reverse"


func _on_steer_left_pressed():
	if is_remapping:
		return
	is_remapping = true

	steer_left_button.text = ". . . . ."
	remapping_button = steer_left_button
	remapping_action = "steer_left"


func _on_steer_right_pressed():
	if is_remapping:
		return
	is_remapping = true

	steer_right_button.text = ". . . . ."
	remapping_button = steer_right_button
	remapping_action = "steer_right"


func _on_tilt_up_pressed():
	if is_remapping:
		return
	is_remapping = true

	tilt_up_button.text = ". . . . ."
	remapping_button = tilt_up_button
	remapping_action = "tilt_up"


func _on_tilt_down_pressed():
	if is_remapping:
		return
	is_remapping = true

	tilt_down_button.text = ". . . . ."
	remapping_button = tilt_down_button
	remapping_action = "tilt_down"


func _on_tilt_left_pressed():
	if is_remapping:
		return
	is_remapping = true

	tilt_left_button.text = ". . . . ."
	remapping_button = tilt_left_button
	remapping_action = "tilt_left"


func _on_tilt_right_pressed():
	if is_remapping:
		return
	is_remapping = true

	tilt_right_button.text = ". . . . ."
	remapping_button = tilt_right_button
	remapping_action = "tilt_right"


func _on_jump_pressed():
	if is_remapping:
		return
	is_remapping = true

	jump_button.text = ". . . . ."
	remapping_button = jump_button
	remapping_action = "jump"


func _on_slide_pressed():
	if is_remapping:
		return
	is_remapping = true

	slide_button.text = ". . . . ."
	remapping_button = slide_button
	remapping_action = "slide"


func _on_boost_pressed():
	if is_remapping:
		return
	is_remapping = true

	boost_button.text = ". . . . ."
	remapping_button = boost_button
	remapping_action = "boost"


func _on_ball_cam_pressed():
	if is_remapping:
		return
	is_remapping = true

	ball_cam_button.text = ". . . . ."
	remapping_button = ball_cam_button
	remapping_action = "ball_cam"


func _on_back_pressed():
	get_tree().change_scene_to_file("res://Scenes/Menus/Options/Options.tscn")


func input_to_string(event: InputEvent):
	var value
	if event is InputEventKey:
		value = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		value = "M" + str(event.button_index)
	elif event is InputEventJoypadButton:
		value = "J" + str(event.button_index)
	return value
