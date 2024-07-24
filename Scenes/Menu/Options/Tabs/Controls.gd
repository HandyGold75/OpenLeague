extends Control

var connected_controllers = Input.get_connected_joypads()

@onready var steer_sens_spin_box = $"CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/Steer Sens"
@onready var tilt_sens_spin_box = $"CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer2/Tilt Sens"
@onready var cam_rotation_sens_spin_box = $"CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer/Cam Rotation Sens"
@onready var cam_center_speed_spin_box = $"CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer2/Cam Center Speed"
@onready var cam_center_delay_spin_box = $"CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/HBoxContainer3/Cam Center Delay"
@onready var controller_option_button = $CenterContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Controller
@onready var joystick_deadzone_spin_box = $"CenterContainer/VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/Joystick Deadzone"


func _ready():
	for joy in connected_controllers:
		controller_option_button.add_item(Input.get_joy_name(joy), joy + 1)

	if len(connected_controllers) <= 0:
		controller_option_button.select(0)
		ConfigHandler.selected_controller = null
	elif ConfigHandler.selected_controller == null:
		controller_option_button.select(1)
		ConfigHandler.selected_controller = connected_controllers[0]

	var control_config = ConfigHandler.load_control_config()
	steer_sens_spin_box.value = control_config["steer_sens"]
	tilt_sens_spin_box.value = control_config["tilt_sens"]
	joystick_deadzone_spin_box.value = control_config["joystick_deadzone"]
	cam_rotation_sens_spin_box.value = control_config["camera_rotation_sens"]
	cam_center_speed_spin_box.value = control_config["camera_center_speed"]
	cam_center_delay_spin_box.value = control_config["camera_center_delay"]


func _on_controller_item_selected(index: int):
	if index == 0:
		ConfigHandler.selected_controller = null
	ConfigHandler.selected_controller = connected_controllers[index - 1]


func _on_steer_sens_value_changed(value: float):
	ConfigHandler.save_control_config("steer_sens", int(value))


func _on_tilt_sens_value_changed(value: float):
	ConfigHandler.save_control_config("tilt_sens", int(value))


func _on_joystick_deadzone_value_changed(value: float):
	ConfigHandler.save_control_config("joystick_deadzone", float(value))


func _on_cam_rotation_sens_value_changed(value: float):
	ConfigHandler.save_control_config("camera_rotation_sens", int(value))


func _on_cam_center_speed_value_changed(value: float):
	ConfigHandler.save_control_config("camera_center_speed", int(value))


func _on_cam_center_delay_value_changed(value: float):
	ConfigHandler.save_control_config("camera_center_delay", float(value))
