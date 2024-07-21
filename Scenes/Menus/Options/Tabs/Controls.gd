extends Control

var connected_controllers = Input.get_connected_joypads()
@onready var controller_option_button = $CenterContainer/VBoxContainer/Controller


func _ready():
	for joy in connected_controllers:
		controller_option_button.add_item(Input.get_joy_name(joy), joy + 1)

	if len(connected_controllers) <= 0:
		controller_option_button.select(0)
		ConfigHandler.selected_controller = null
	elif ConfigHandler.selected_controller == null:
		controller_option_button.select(1)
		ConfigHandler.selected_controller = connected_controllers[0]


func _on_controller_item_selected(index: int):
	if index == 0:
		ConfigHandler.selected_controller = null
	ConfigHandler.selected_controller = connected_controllers[index - 1]
