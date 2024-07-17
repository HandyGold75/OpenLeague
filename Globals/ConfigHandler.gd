extends Node

var Config = ConfigFile.new()
const CONFIG_FILE_PATH = "user://Config.ini"

const DEFAULT_VIDEO_DISPLAY = 0
const DEFAULT_AUDIO_MASTER_VOLUME = 50
const DEFAULT_KEYBINDING_throttle= "W"
const DEFAULT_KEYBINDING_reverse= "S"
const DEFAULT_KEYBINDING_steer_left= "A"
const DEFAULT_KEYBINDING_steer_right= "D"
const DEFAULT_KEYBINDING_tilt_up= "Up"
const DEFAULT_KEYBINDING_tilt_down= "Down"
const DEFAULT_KEYBINDING_tilt_left= "Left"
const DEFAULT_KEYBINDING_tilt_right= "Right"
const DEFAULT_KEYBINDING_jump= "Space"
const DEFAULT_KEYBINDING_slide= "X"
const DEFAULT_KEYBINDING_boost= "Shift"
const DEFAULT_KEYBINDING_ball_cam= "E"
const DEFAULT_TWEAKS_START_BOOST = 30
const DEFAULT_TWEAKS_UNLIMITED_BOOST = false

func _ready():
	if !FileAccess.file_exists(CONFIG_FILE_PATH):
		set_video_defaults()
		set_audio_defaults()
		set_keybinding_defaults()
		set_tweaks_defaults()
		Config.save(CONFIG_FILE_PATH)
	else:
		Config.load(CONFIG_FILE_PATH)

	if !validate_video_config():
		set_video_defaults()
		Config.save(CONFIG_FILE_PATH)
	if !validate_keybinding_config():
		set_keybinding_defaults()
		Config.save(CONFIG_FILE_PATH)
	if !validate_audio_config():
		set_audio_defaults()
		Config.save(CONFIG_FILE_PATH)
	if !validate_tweaks_config():
		set_tweaks_defaults()
		Config.save(CONFIG_FILE_PATH)

	activate_video_config()
	activate_keybinding_config()

# Video config handler
func set_video_defaults():
	Config.set_value("video", "display", DEFAULT_VIDEO_DISPLAY)
	Config.save(CONFIG_FILE_PATH)

func validate_video_config():
	if typeof(Config.get_value("video", "display")) != TYPE_INT:
		print("Found invalid config! \"[video] display != TYPE_INT\"")
		return false
	return true

func save_video_config(key: String, value):
	if Config.get_value("video", key) == null:
		return
	Config.set_value("video", key, value)
	Config.save(CONFIG_FILE_PATH)

func load_video_config():
	var config = {}
	for key in Config.get_section_keys("video"):
		config[key] = Config.get_value("video", key)
	return config

func activate_video_config():
	if Config.get_value("video", "display") == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	elif Config.get_value("video", "display") == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_MAXIMIZED)
	elif Config.get_value("video", "display") == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# Audio config handler
func set_audio_defaults():
	Config.set_value("audio", "master_volume", DEFAULT_AUDIO_MASTER_VOLUME)
	Config.save(CONFIG_FILE_PATH)

func validate_audio_config():
	if typeof(Config.get_value("audio", "master_volume")) != TYPE_INT:
		print("Found invalid config! \"[audio] master_volume != TYPE_INT\"")
		return false
	return true

func save_audio_config(key: String, value):
	if Config.get_value("audio", key) == null:
		return
	Config.set_value("audio", key, value)
	Config.save(CONFIG_FILE_PATH)

func load_audio_config():
	var config = {}
	for key in Config.get_section_keys("audio"):
		config[key] = Config.get_value("audio", key)
	return config

# Keybinding config handler
func set_keybinding_defaults():
	Config.set_value("keybinding", "throttle",  DEFAULT_KEYBINDING_throttle)
	Config.set_value("keybinding", "reverse",  DEFAULT_KEYBINDING_reverse)
	Config.set_value("keybinding", "steer_left",  DEFAULT_KEYBINDING_steer_left)
	Config.set_value("keybinding", "steer_right",  DEFAULT_KEYBINDING_steer_right)
	Config.set_value("keybinding", "tilt_up",  DEFAULT_KEYBINDING_tilt_up)
	Config.set_value("keybinding", "tilt_down",  DEFAULT_KEYBINDING_tilt_down)
	Config.set_value("keybinding", "tilt_left",  DEFAULT_KEYBINDING_tilt_left)
	Config.set_value("keybinding", "tilt_right",  DEFAULT_KEYBINDING_tilt_right)
	Config.set_value("keybinding", "jump",  DEFAULT_KEYBINDING_jump)
	Config.set_value("keybinding", "slide",  DEFAULT_KEYBINDING_slide)
	Config.set_value("keybinding", "boost",  DEFAULT_KEYBINDING_boost)
	Config.set_value("keybinding", "ball_cam",  DEFAULT_KEYBINDING_ball_cam)
	Config.save(CONFIG_FILE_PATH)

func validate_keybinding_config():
	if typeof(Config.get_value("keybinding", "throttle")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] xxx != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "reverse")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] reverse != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "steer_left")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] steer_left != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "steer_right")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] steer_right != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "tilt_up")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] tilt_up != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "tilt_down")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] tilt_down != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "tilt_left")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] tilt_left != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "tilt_right")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] tilt_right != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "jump")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] jump != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "slide")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] slide != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "boost")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] boost != TYPE_STRING\"")
		return false
	elif typeof(Config.get_value("keybinding", "ball_cam")) != TYPE_STRING:
		print("Found invalid config! \"[keybinding] ball_cam != TYPE_STRING\"")
		return false
	return true

func save_keybinding_config(key: String, event: InputEvent):
	var value
	if event is InputEventKey:
		value = OS.get_keycode_string(event.keycode)
	elif event is InputEventMouseButton:
		value = "mouse_" + str(event.button_index)
	elif event is InputEventJoypadButton:
		value = "joypad_" + str(event.button_index)
	else:
		return

	if Config.get_value("keybinding", key) == null:
		return
	Config.set_value("keybinding", key, value)
	Config.save(CONFIG_FILE_PATH)

func load_keybinding_config():
	var config = {}
	for key in Config.get_section_keys("keybinding"):
		var event
		var value = Config.get_value("keybinding", key)
		if value.begins_with("joypad_"):
			event = InputEventJoypadButton.new()
			event.button_index = int(value.replace("joypad_", ""))
		elif value.begins_with("mouse_"):
			event = InputEventMouseButton.new()
			event.button_index = int(value.replace("mouse_", ""))
		else:
			event = InputEventKey.new()
			event.keycode = OS.find_keycode_from_string(value)

		config[key] = event

	return config

func activate_keybinding_config():
	var config = load_keybinding_config()
	for key in config:
		InputMap.action_erase_events(key)
		InputMap.action_add_event(key, config[key])

# Tweaks config handler
func set_tweaks_defaults():
	Config.set_value("tweaks", "start_boost", DEFAULT_TWEAKS_START_BOOST)
	Config.set_value("tweaks", "unlimited_boost", DEFAULT_TWEAKS_UNLIMITED_BOOST)
	Config.save(CONFIG_FILE_PATH)

func validate_tweaks_config():
	if typeof(Config.get_value("tweaks", "start_boost")) != TYPE_INT:
		print("Found invalid config! \"[tweaks] start_boost != TYPE_INT\"")
		return false
	if typeof(Config.get_value("tweaks", "unlimited_boost")) != TYPE_BOOL:
		print("Found invalid config! \"[tweaks] unlimited_boost != TYPE_BOOL\"")
		return false
	return true

func save_tweaks_config(key: String, value):
	if Config.get_value("tweaks", key) == null:
		return
	Config.set_value("tweaks", key, value)
	Config.save(CONFIG_FILE_PATH)

func load_tweaks_config():
	var config = {}
	for key in Config.get_section_keys("tweaks"):
		config[key] = Config.get_value("tweaks", key)
	return config
