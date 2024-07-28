extends Node

const CONFIG_FILE_PATH = "user://config.ini"

const DEFAULT_VIDEO_DISPLAY = 0
const DEFAULT_AUDIO_MASTER_VOLUME = 0.5
const DEFAULT_CONTROL_STEER_SENS = 75
const DEFAULT_CONTROL_TILT_SENS = 75
const DEFAULT_CONTROL_JOYSTICK_DEADZONE = 0.1
const DEFAULT_CONTROL_CAMERA_ROTATION_SENS = 50
const DEFAULT_CONTROL_CAMERA_CENTER_SPEED = 10
const DEFAULT_CONTROL_CAMERA_CENTER_DELAY = 0.2
const DEFAULT_KEYBINDING_THROTTLE = "W;joypadaxis_5"
const DEFAULT_KEYBINDING_REVERSE = "S;joypadaxis_4"
const DEFAULT_KEYBINDING_STEER_LEFT = "A;A"
const DEFAULT_KEYBINDING_STEER_RIGHT = "D;D"
const DEFAULT_KEYBINDING_TILT_UP = "Up;Up"
const DEFAULT_KEYBINDING_TILT_DOWN = "Down;Down"
const DEFAULT_KEYBINDING_TILT_LEFT = "Left;joypad_9"
const DEFAULT_KEYBINDING_TILT_RIGHT = "Right;joypad_10"
const DEFAULT_KEYBINDING_JUMP = "Space;joypad_0"
const DEFAULT_KEYBINDING_SLIDE = "X;joypad_2"
const DEFAULT_KEYBINDING_BOOST = "Shift;joypad_1"
const DEFAULT_KEYBINDING_BALL_CAM = "E;joypad_3"

var config_file := ConfigFile.new()


class HotConfig:
	var selected_controller = null

	var level_selected_stadium := "Default"
	var level_selected_ball := "Default"
	var level_selected_car := "Default"

	var tweaks_start_boost := 30
	var tweaks_unlimited_boost := false


var hotconfig := HotConfig.new()


func _ready() -> void:
	if !FileAccess.file_exists(CONFIG_FILE_PATH):
		set_video_defaults()
		set_audio_defaults()
		set_control_defaults()
		set_keybinding_defaults()
		config_file.save(CONFIG_FILE_PATH)
	else:
		config_file.load(CONFIG_FILE_PATH)

	var valid := true
	if !validate_video_config():
		set_video_defaults()
		valid = false
	if !validate_keybinding_config():
		set_keybinding_defaults()
		valid = false
	if !validate_control_config():
		set_control_defaults()
		valid = false
	if !validate_audio_config():
		set_audio_defaults()
		valid = false
	if !valid:
		config_file.save(CONFIG_FILE_PATH)

	activate_video_config()
	activate_audio_config()
	activate_keybinding_config()

	Input.joy_connection_changed.connect(joy_changed)


# Signal handlers
func joy_changed(device_id: int, connected: bool) -> void:
	if !connected && device_id == hotconfig.selected_controller:
		hotconfig.selected_controller = null
		return
	if connected && hotconfig.selected_controller == null:
		hotconfig.selected_controller = device_id


# Video config handler
func set_video_defaults() -> void:
	config_file.set_value("video", "display", DEFAULT_VIDEO_DISPLAY)
	config_file.save(CONFIG_FILE_PATH)


func validate_video_config() -> bool:
	var state := true
	if typeof(config_file.get_value("video", "display")) != TYPE_INT:
		print('Found invalid config! "[video] display != TYPE_INT"')
		state = false
	return state


func save_video_config(key: String, value) -> void:
	if config_file.get_value("video", key) == null:
		return
	config_file.set_value("video", key, value)
	config_file.save(CONFIG_FILE_PATH)


func load_video_config() -> Dictionary:
	var config := {}
	for key in config_file.get_section_keys("video"):
		config[key] = config_file.get_value("video", key)
	return config


func activate_video_config() -> void:
	var config := load_video_config()
	if config["display"] == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		get_viewport().size = DisplayServer.screen_get_size()
	elif config["display"] == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
		get_viewport().size = DisplayServer.screen_get_size()
	elif config["display"] == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		get_viewport().size = Vector2(1280, 720)


# Audio config handler
func set_audio_defaults() -> void:
	config_file.set_value("audio", "master_volume", DEFAULT_AUDIO_MASTER_VOLUME)
	config_file.save(CONFIG_FILE_PATH)


func validate_audio_config() -> bool:
	var state := true
	if typeof(config_file.get_value("audio", "master_volume")) != TYPE_FLOAT:
		print('Found invalid config! "[audio] master_volume != TYPE_FLOAT"')
		state = false
	return state


func save_audio_config(key: String, value) -> void:
	if config_file.get_value("audio", key) == null:
		return
	config_file.set_value("audio", key, value)
	config_file.save(CONFIG_FILE_PATH)


func load_audio_config() -> Dictionary:
	var config := {}
	for key in config_file.get_section_keys("audio"):
		config[key] = config_file.get_value("audio", key)
	return config


func activate_audio_config() -> void:
	var config := load_audio_config()
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(config["master_volume"]))


# Control config handler
func set_control_defaults() -> void:
	config_file.set_value("control", "steer_sens", DEFAULT_CONTROL_STEER_SENS)
	config_file.set_value("control", "tilt_sens", DEFAULT_CONTROL_TILT_SENS)
	config_file.set_value("control", "joystick_deadzone", DEFAULT_CONTROL_JOYSTICK_DEADZONE)
	config_file.set_value("control", "camera_rotation_sens", DEFAULT_CONTROL_CAMERA_ROTATION_SENS)
	config_file.set_value("control", "camera_center_speed", DEFAULT_CONTROL_CAMERA_CENTER_SPEED)
	config_file.set_value("control", "camera_center_delay", DEFAULT_CONTROL_CAMERA_CENTER_DELAY)
	config_file.save(CONFIG_FILE_PATH)


func validate_control_config() -> bool:
	var state := true
	if typeof(config_file.get_value("control", "steer_sens")) != TYPE_INT:
		print('Found invalid config! "[control] steer_sens != TYPE_INT"')
		state = false
	if typeof(config_file.get_value("control", "tilt_sens")) != TYPE_INT:
		print('Found invalid config! "[control] tilt_sens != TYPE_INT"')
		state = false
	if typeof(config_file.get_value("control", "joystick_deadzone")) != TYPE_FLOAT:
		print('Found invalid config! "[control] joystick_deadzone !=  TYPE_FLOAT"')
		state = false
	if typeof(config_file.get_value("control", "camera_rotation_sens")) != TYPE_INT:
		print('Found invalid config! "[control] camera_rotation_sens != TYPE_INT"')
		state = false
	if typeof(config_file.get_value("control", "camera_center_speed")) != TYPE_INT:
		print('Found invalid config! "[control] camera_center_speed != TYPE_INT"')
		state = false
	if typeof(config_file.get_value("control", "camera_center_delay")) != TYPE_FLOAT:
		print('Found invalid config! "[control] camera_center_delay != TYPE_FLOAT"')
		state = false
	return state


func save_control_config(key: String, value) -> void:
	if config_file.get_value("control", key) == null:
		return
	config_file.set_value("control", key, value)
	config_file.save(CONFIG_FILE_PATH)


func load_control_config() -> Dictionary:
	var config := {}
	for key in config_file.get_section_keys("control"):
		config[key] = config_file.get_value("control", key)
	return config


# Keybinding config handler
func set_keybinding_defaults() -> void:
	config_file.set_value("keybinding", "throttle", DEFAULT_KEYBINDING_THROTTLE)
	config_file.set_value("keybinding", "reverse", DEFAULT_KEYBINDING_REVERSE)
	config_file.set_value("keybinding", "steer_left", DEFAULT_KEYBINDING_STEER_LEFT)
	config_file.set_value("keybinding", "steer_right", DEFAULT_KEYBINDING_STEER_RIGHT)
	config_file.set_value("keybinding", "tilt_up", DEFAULT_KEYBINDING_TILT_UP)
	config_file.set_value("keybinding", "tilt_down", DEFAULT_KEYBINDING_TILT_DOWN)
	config_file.set_value("keybinding", "tilt_left", DEFAULT_KEYBINDING_TILT_LEFT)
	config_file.set_value("keybinding", "tilt_right", DEFAULT_KEYBINDING_TILT_RIGHT)
	config_file.set_value("keybinding", "jump", DEFAULT_KEYBINDING_JUMP)
	config_file.set_value("keybinding", "slide", DEFAULT_KEYBINDING_SLIDE)
	config_file.set_value("keybinding", "boost", DEFAULT_KEYBINDING_BOOST)
	config_file.set_value("keybinding", "ball_cam", DEFAULT_KEYBINDING_BALL_CAM)
	config_file.save(CONFIG_FILE_PATH)


func validate_keybinding_config() -> bool:
	var state := true
	if typeof(config_file.get_value("keybinding", "throttle")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] xxx != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "reverse")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] reverse != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "steer_left")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] steer_left != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "steer_right")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] steer_right != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "tilt_up")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] tilt_up != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "tilt_down")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] tilt_down != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "tilt_left")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] tilt_left != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "tilt_right")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] tilt_right != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "jump")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] jump != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "slide")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] slide != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "boost")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] boost != TYPE_STRING"')
		state = false
	if typeof(config_file.get_value("keybinding", "ball_cam")) != TYPE_STRING:
		print('Found invalid config! "[keybinding] ball_cam != TYPE_STRING"')
		state = false
	return state


func save_keybinding_config(key: String, index: int, event: InputEvent) -> void:
	var value := ""
	if event is InputEventKey:
		value = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		value = "mouse_" + str(event.button_index)
	elif event is InputEventJoypadButton:
		value = "joypad_" + str(event.button_index)
	elif event is InputEventJoypadMotion:
		value = "joypadaxis_" + str(event.axis)
	else:
		return

	var old_value = config_file.get_value("keybinding", key)
	if old_value == null || index < 0 || index > 1:
		return

	var new_values = old_value.split(";")
	new_values[index] = value

	config_file.set_value("keybinding", key, ";".join(new_values))
	config_file.save(CONFIG_FILE_PATH)


func load_keybinding_config() -> Dictionary:
	var config := {}
	for key in config_file.get_section_keys("keybinding"):
		var events := []
		var values = config_file.get_value("keybinding", key).split(";")
		for value in values:
			var event
			if value.begins_with("joypadaxis_"):
				event = InputEventJoypadMotion.new()
				event.axis = int(value.replace("joypadaxis_", ""))
			elif value.begins_with("joypad_"):
				event = InputEventJoypadButton.new()
				event.button_index = int(value.replace("joypad_", ""))
			elif value.begins_with("mouse_"):
				event = InputEventMouseButton.new()
				event.button_index = int(value.replace("mouse_", ""))
			else:
				event = InputEventKey.new()
				event.keycode = OS.find_keycode_from_string(value)
			events.append(event)

		config[key] = events

	return config


func activate_keybinding_config() -> void:
	var config := load_keybinding_config()
	for key in config:
		InputMap.action_erase_events(key)
		for event in config[key]:
			InputMap.action_add_event(key, event)
