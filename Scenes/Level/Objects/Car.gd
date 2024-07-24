extends CharacterBody3D

const DEBUG = false
const ALLOW_TWEAKS = true

const SPEED_FORWARD = 30
const SPEED_REVERSED = 20
const SPEED_BOOST = 40
const SPEED_MAX = 40
const SPEED_LOSS = 0.5

const BOOST_DRAIN = 25

const JUMP_VELOCITY = 10

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var ball_cam_state = true
var cam_just_moved = false
var cam_just_moved_signal = null
var cam_just_moved_reseter = func(): cam_just_moved = false ; cam_just_moved_signal = null

var has_dubble_jump = true

# Config
var control_config = ConfigHandler.load_control_config()
var tweaks_config = ConfigHandler.load_tweaks_config()

# Configurable (Control)
var steer_sens = control_config["steer_sens"]
var tilt_sens = control_config["tilt_sens"]
var joystick_deadzone = control_config["joystick_deadzone"]
var camera_rotation_sens = control_config["camera_rotation_sens"]
var camera_center_speed = control_config["camera_center_speed"]
var camera_center_delay = control_config["camera_center_delay"]

# Configurable (Tweaks)
var unlimited_boost = false
var boost_count = 30:
	set(value):
		$Hud/BoxContainer/BoostBar.value = value
		boost_count = clampf(value, 0, 100)


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	$Hud/BoxContainer/BoostBar.value = boost_count

	if ALLOW_TWEAKS:
		unlimited_boost = tweaks_config["unlimited_boost"]
		boost_count = tweaks_config["start_boost"]


func apply_configs():
	control_config = ConfigHandler.load_control_config()
	tweaks_config = ConfigHandler.load_tweaks_config()

	steer_sens = control_config["steer_sens"]
	tilt_sens = control_config["tilt_sens"]
	joystick_deadzone = control_config["joystick_deadzone"]
	camera_rotation_sens = control_config["camera_rotation_sens"]
	camera_center_speed = control_config["camera_center_speed"]
	camera_center_delay = control_config["camera_center_delay"]

	if ALLOW_TWEAKS:
		unlimited_boost = tweaks_config["unlimited_boost"]


func _on_pause_toggled(is_paused: bool) -> void:
	if is_paused:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	else:
		apply_configs()
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * (float(camera_rotation_sens) / 10000)
		$CYaw.rotate_y(-camera_rotation.x)
		$CYaw/CPitch.rotate_x(camera_rotation.y)
		$CYaw.transform = $CYaw.transform.orthonormalized()
		$CYaw/CPitch.transform = $CYaw/CPitch.transform.orthonormalized()

		cam_just_moved = true
		if camera_center_delay > 0:
			if cam_just_moved_signal != null && cam_just_moved_signal.is_connected(cam_just_moved_reseter):
				cam_just_moved_signal.disconnect(cam_just_moved_reseter)
			cam_just_moved_signal = get_tree().create_timer(camera_center_delay).timeout
			cam_just_moved_signal.connect(cam_just_moved_reseter)


func _process(delta: float):
	if Input.is_action_just_pressed("ball_cam"):
		ball_cam_state = !ball_cam_state

	if ConfigHandler.selected_controller != null:
		# Rotate camera on right joystick motion
		var axis_x = float(Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_RIGHT_X))
		if axis_x < joystick_deadzone && axis_x > -joystick_deadzone:
			axis_x = 0
		var axis_y = float(Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_RIGHT_Y))
		if axis_y < joystick_deadzone && axis_y > -joystick_deadzone:
			axis_y = 0

		if axis_x != 0 || axis_y != 0:
			cam_just_moved = true
			$CYaw.rotation.y = lerp_angle($CYaw.rotation.y, -axis_x * 1.5 + rotation.y, camera_rotation_sens * delta)
			$CYaw/CPitch.rotation.x = lerp_angle($CYaw/CPitch.rotation.x, axis_y, camera_rotation_sens * delta)
			$CYaw.transform = $CYaw.transform.orthonormalized()
			$CYaw/CPitch.transform = $CYaw/CPitch.transform.orthonormalized()
		elif cam_just_moved_signal == null:
			cam_just_moved = false

		# Vibrate controller if boosting
		if Input.is_action_pressed("boost") && boost_count > 0:
			Input.start_joy_vibration(ConfigHandler.selected_controller, 1, 0, 0)
		else:
			Input.stop_joy_vibration(ConfigHandler.selected_controller)

	if !cam_just_moved:
		if ball_cam_state:
			# Focus the ball
			var ball = get_parent().get_node("Ball")
			var yaw_old = $CYaw.rotation.y
			var pitch_old = $CYaw/CPitch.rotation.x

			$CYaw.look_at(ball.global_transform.origin, Vector3.UP, true)
			$CYaw/CPitch.look_at(ball.global_transform.origin, Vector3.UP, true)
			$CYaw.rotation.x = 0
			$CYaw.rotation.y = lerp_angle(yaw_old, $CYaw.rotation.y, camera_center_speed * delta)
			$CYaw.rotation.z = 0
			$CYaw/CPitch.rotation.y = 0
			$CYaw/CPitch.rotation.x = lerp_angle(pitch_old, $CYaw/CPitch.rotation.x, camera_center_speed * delta)
			$CYaw/CPitch.rotation.z = 0

		else:
			# Focus forward
			$CYaw.rotation.y = lerp_angle($CYaw.rotation.y, rotation.y, camera_center_speed * delta)
			$CYaw/CPitch.rotation.x = lerp_angle($CYaw/CPitch.rotation.x, 0.0, camera_center_speed * delta)

		$CYaw.transform = $CYaw.transform.orthonormalized()
		$CYaw/CPitch.transform = $CYaw/CPitch.transform.orthonormalized()


func _physics_process(delta: float):
	var wheels_touching_ground = is_on_floor() || is_on_wall() || is_on_ceiling()
	if not is_on_floor() || (wheels_touching_ground && abs(velocity.x) + abs(velocity).z < 1):
		velocity.y -= gravity * delta

	var acceleration = float(Input.get_action_strength("throttle", false))
	var deceleration = float(Input.get_action_strength("reverse", false))
	var steering_force = float(Input.get_axis("steer_right", "steer_left"))
	var tilt_yaw_force = float(Input.get_axis("tilt_down", "tilt_up"))
	var tilt_pitch_force = float(Input.get_axis("tilt_left", "tilt_right"))

	# Rotate car
	if ConfigHandler.selected_controller != null:
		var axis_x = -float(Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_LEFT_X))
		if axis_x < joystick_deadzone && axis_x > -joystick_deadzone:
			axis_x = 0
		var axis_y = -float(Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_LEFT_Y))
		if axis_y < joystick_deadzone && axis_y > -joystick_deadzone:
			axis_y = 0

		steering_force = clampf(steering_force + axis_x, -1, 1)
		tilt_yaw_force = clampf(tilt_yaw_force + axis_y, -1, 1)

	if abs(velocity.x) + abs(velocity).z > 0.5:
		rotate_object_local(Vector3(0, 1, 0), steering_force / (101 - steer_sens))

	# Boosting
	if Input.is_action_pressed("boost") && boost_count > 0:
		if !(ALLOW_TWEAKS && unlimited_boost):
			boost_count -= BOOST_DRAIN * delta
		velocity = velocity + (transform.basis.z * SPEED_BOOST * delta)

	if wheels_touching_ground:
		has_dubble_jump = true

		# Rotate car straight if grounded
		if is_on_floor_only():
			rotation = rotation.lerp(Vector3(0, rotation.y, 0), 10 * delta)

		# Rotate moving direction to car forwards direction
		if !Input.is_action_pressed("slide"):
			var velocity_y = velocity.y
			velocity = velocity.rotated(transform.basis.z.normalized(), 20 * delta)
			velocity.y = velocity_y

		# Apply forward and braking velocity
		velocity = velocity + (transform.basis.z * (((acceleration * SPEED_FORWARD) - (deceleration * SPEED_REVERSED)) * delta))
		velocity = velocity.lerp(Vector3(0, 0, 0), (SPEED_LOSS) * delta)

		# Jump
		if Input.is_action_pressed("jump"):
			velocity = velocity + (transform.basis.y * JUMP_VELOCITY)

	else:
		# Rotate car's yaw and pitch
		rotate_object_local(Vector3(1, 0, 0), tilt_yaw_force / (101 - tilt_sens))
		rotate_object_local(Vector3(0, 0, 1), tilt_pitch_force / (101 - tilt_sens))

		# Dubble jump
		if Input.is_action_pressed("jump") && has_dubble_jump:
			has_dubble_jump = false
			velocity = velocity + (transform.basis.y * JUMP_VELOCITY)

	# Ensure velocity never goes over max
	velocity.x = clampf(velocity.x, -SPEED_MAX, SPEED_MAX)
	velocity.y = clampf(velocity.y, -SPEED_MAX, SPEED_MAX)
	velocity.z = clampf(velocity.z, -SPEED_MAX, SPEED_MAX)

	# Collisions
	if is_on_floor():
		for i in get_slide_collision_count():
			var col_obj = get_slide_collision(i).get_collider()
			if col_obj.get_collision_layer() == 2:
				var push_direction = (col_obj.global_transform.origin - global_transform.origin).normalized()
				col_obj.apply_impulse(push_direction * 10, Vector3.ZERO)

	# Debug
	if DEBUG:
		print(["-----", velocity, wheels_touching_ground, transform.basis, has_dubble_jump, boost_count])

	# Cleanup
	transform = transform.orthonormalized()
	move_and_slide()
