extends Control

var is_remapping = false
var remapping_button = null
var remapping_action = null
var remapping_index = null

@onready var buttons = {
	"throttle_1": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Throttle 1",
	"throttle_2": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer/Throttle 2",
	"reverse_1": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Reverse 1",
	"reverse_2": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Reverse 2",
	"steer_left_1": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Steer Left 1",
	"steer_left_2": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer3/Steer Left 2",
	"steer_right_1": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Steer Right 1",
	"steer_right_2": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer4/Steer Right 2",
	"tilt_up_1": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Tilt Up 1",
	"tilt_up_2": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Tilt Up 2",
	"tilt_down_1": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Tilt Down 1",
	"tilt_down_2": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Tilt Down 2",
	"tilt_left_1": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer3/Tilt Left 1",
	"tilt_left_2": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer3/Tilt Left 2",
	"tilt_right_1": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer4/Tilt Right 1",
	"tilt_right_2": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer4/Tilt Right 2",
	"jump_1": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer5/Jump 1",
	"jump_2": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer5/Jump 2",
	"slide_1": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer5/Slide 1",
	"slide_2": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer5/Slide 2",
	"boost_1": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer6/Boost 1",
	"boost_2": $"CenterContainer/HBoxContainer/VBoxContainer/HBoxContainer6/Boost 2",
	"ball_cam_1": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer6/Ball Cam 1",
	"ball_cam_2": $"CenterContainer/HBoxContainer/VBoxContainer2/HBoxContainer6/Ball Cam 2",
}


func _ready():
	var keybinding_config = ConfigHandler.load_keybinding_config()
	buttons["throttle_1"].text = input_to_string(keybinding_config["throttle"][0])
	buttons["throttle_2"].text = input_to_string(keybinding_config["throttle"][1])
	buttons["reverse_1"].text = input_to_string(keybinding_config["reverse"][0])
	buttons["reverse_2"].text = input_to_string(keybinding_config["reverse"][1])
	buttons["steer_left_1"].text = input_to_string(keybinding_config["steer_left"][0])
	buttons["steer_left_2"].text = input_to_string(keybinding_config["steer_left"][1])
	buttons["steer_right_1"].text = input_to_string(keybinding_config["steer_right"][0])
	buttons["steer_right_2"].text = input_to_string(keybinding_config["steer_right"][1])
	buttons["tilt_up_1"].text = input_to_string(keybinding_config["tilt_up"][0])
	buttons["tilt_up_2"].text = input_to_string(keybinding_config["tilt_up"][1])
	buttons["tilt_down_1"].text = input_to_string(keybinding_config["tilt_down"][0])
	buttons["tilt_down_2"].text = input_to_string(keybinding_config["tilt_down"][1])
	buttons["tilt_left_1"].text = input_to_string(keybinding_config["tilt_left"][0])
	buttons["tilt_left_2"].text = input_to_string(keybinding_config["tilt_left"][1])
	buttons["tilt_right_1"].text = input_to_string(keybinding_config["tilt_right"][0])
	buttons["tilt_right_2"].text = input_to_string(keybinding_config["tilt_right"][1])
	buttons["jump_1"].text = input_to_string(keybinding_config["jump"][0])
	buttons["jump_2"].text = input_to_string(keybinding_config["jump"][1])
	buttons["slide_1"].text = input_to_string(keybinding_config["slide"][0])
	buttons["slide_2"].text = input_to_string(keybinding_config["slide"][1])
	buttons["boost_1"].text = input_to_string(keybinding_config["boost"][0])
	buttons["boost_2"].text = input_to_string(keybinding_config["boost"][1])
	buttons["ball_cam_1"].text = input_to_string(keybinding_config["ball_cam"][0])
	buttons["ball_cam_2"].text = input_to_string(keybinding_config["ball_cam"][1])


func start_rebind(action: String, index: int):
	if is_remapping:
		return
	is_remapping = true

	buttons[action + "_" + str(index + 1)].text = ". . . . ."
	remapping_button = buttons[action + "_" + str(index + 1)]
	remapping_action = action
	remapping_index = index


func input_to_string(event: InputEvent):
	var value
	if event is InputEventKey:
		value = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		value = "M" + str(event.button_index)
	elif event is InputEventJoypadButton:
		value = "B" + str(event.button_index)
	elif event is InputEventJoypadMotion:
		value = "J" + str(event.axis)
	return value


func _input(event: InputEvent):
	if !is_remapping:
		return
	if !(event is InputEventKey || event is InputEventMouseButton || event is InputEventJoypadButton || event is InputEventJoypadMotion):
		return
	if event is InputEventJoypadMotion:
		if event.axis != 4 && event.axis != 5:
			return

	ConfigHandler.save_keybinding_config(remapping_action, remapping_index, event)
	ConfigHandler.activate_keybinding_config()
	remapping_button.text = input_to_string(event)

	remapping_button = null
	remapping_action = null
	is_remapping = false

	accept_event()


func _on_throttle_1_pressed():
	start_rebind("throttle", 0)


func _on_throttle_2_pressed():
	start_rebind("throttle", 1)


func _on_reverse_1_pressed():
	start_rebind("reverse", 0)


func _on_reverse_2_pressed():
	start_rebind("reverse", 1)


func _on_steer_left_1_pressed():
	start_rebind("steer_left", 0)


func _on_steer_left_2_pressed():
	start_rebind("steer_left", 1)


func _on_steer_right_1_pressed():
	start_rebind("steer_right", 0)


func _on_steer_right_2_pressed():
	start_rebind("steer_right", 1)


func _on_tilt_up_1_pressed():
	start_rebind("tilt_up", 0)


func _on_tilt_up_2_pressed():
	start_rebind("tilt_up", 1)


func _on_tilt_down_1_pressed():
	start_rebind("tilt_down", 0)


func _on_tilt_down_2_pressed():
	start_rebind("tilt_down", 1)


func _on_tilt_left_1_pressed():
	start_rebind("tilt_left", 0)


func _on_tilt_left_2_pressed():
	start_rebind("tilt_left", 1)


func _on_tilt_right_1_pressed():
	start_rebind("tilt_right", 0)


func _on_tilt_right_2_pressed():
	start_rebind("tilt_right", 1)


func _on_jump_1_pressed():
	start_rebind("jump", 0)


func _on_jump_2_pressed():
	start_rebind("jump", 1)


func _on_slide_1_pressed():
	start_rebind("slide", 0)


func _on_slide_2_pressed():
	start_rebind("slide", 1)


func _on_boost_1_pressed():
	start_rebind("boost", 0)


func _on_boost_2_pressed():
	start_rebind("boost", 1)


func _on_ball_cam_1_pressed():
	start_rebind("ball_cam", 0)


func _on_ball_cam_2_pressed():
	start_rebind("ball_cam", 1)
