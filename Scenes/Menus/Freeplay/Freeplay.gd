extends Control

@onready var stadium_option_button := $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Stadium
@onready var ball_option_button := $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Ball
@onready var car_option_button := $CenterContainer/VBoxContainer/HBoxContainer/VBoxContainer2/Car
@onready var start_boost_spin_box := $"CenterContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer2/Start Boost"
@onready var unlimited_boost_check_button := $"CenterContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer2/Unlimited Boost"


func _ready() -> void:
	for i in range(0, stadium_option_button.item_count):
		if stadium_option_button.get_item_text(i) == ConfigHandler.hotconfig.level_selected_stadium:
			stadium_option_button.select(i)
			break

	for i in range(0, ball_option_button.item_count):
		if ball_option_button.get_item_text(i) == ConfigHandler.hotconfig.level_selected_ball:
			ball_option_button.select(i)
			break

	for i in range(0, car_option_button.item_count):
		if car_option_button.get_item_text(i) == ConfigHandler.hotconfig.level_selected_car:
			car_option_button.select(i)
			break

	start_boost_spin_box.value = ConfigHandler.hotconfig.tweaks_start_boost
	unlimited_boost_check_button.button_pressed = ConfigHandler.hotconfig.tweaks_unlimited_boost


func _on_stadium_item_selected(index: int) -> void:
	ConfigHandler.hotconfig.level_selected_stadium = stadium_option_button.get_item_text(index)


func _on_ball_item_selected(index: int) -> void:
	ConfigHandler.hotconfig.level_selected_ball = ball_option_button.get_item_text(index)


func _on_car_item_selected(index: int) -> void:
	ConfigHandler.hotconfig.level_selected_car = car_option_button.get_item_text(index)


func _on_start_boost_value_changed(value: float) -> void:
	ConfigHandler.hotconfig.tweaks_start_boost = int(value)


func _on_unlimited_boost_toggled(toggled_on: bool) -> void:
	ConfigHandler.hotconfig.tweaks_unlimited_boost = toggled_on


func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Level/Main.tscn")


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/Menus/Main.tscn")
