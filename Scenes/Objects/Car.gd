extends CharacterBody3D

const DEBUG = false

const SPEED_FORWARD = 30
const SPEED_REVERSED = 20
const SPEED_BOOST = 40
const SPEED_MAX = 40
const SPEED_LOSS = 0.5

const JUMP_VELOCITY = 10

const STEER_SENSITIVITY = 80
const TILT_SENSITIVITY = 80

const CAMERA_ROTATION_SENS = 0.5
const CAMERA_CENTER_SENS = 10

const JOY_AXIS_DEADZONE = 0.1

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var ball_cam_state = true

var allow_tweaks = true
var tweaks_config = ConfigHandler.load_tweaks_config()

var has_dubble_jump = true
var boost_count = 30


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	if allow_tweaks:
		boost_count = tweaks_config["start_boost"]


func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * (CAMERA_ROTATION_SENS / 100)
		$CRoll/CYaw.rotate_y(-camera_rotation.x)
		$CRoll/CYaw/CPitch.rotate_x(camera_rotation.y)
		$CRoll/CYaw.transform = $CRoll/CYaw.transform.orthonormalized()
		$CRoll/CYaw/CPitch.transform = $CRoll/CYaw/CPitch.transform.orthonormalized()


func _process(delta: float):
	if Input.is_action_just_pressed("ball_cam"):
		ball_cam_state = !ball_cam_state

	if ball_cam_state:
		# Focus the ball
		var ball = get_parent().get_node("Ball")
		var yaw_old = $CRoll/CYaw.rotation.y
		var pitch_old = $CRoll/CYaw/CPitch.rotation.x

		$CRoll/CYaw.look_at(ball.global_transform.origin, Vector3.UP, true)
		$CRoll/CYaw/CPitch.look_at(ball.global_transform.origin, Vector3.UP, true)

		$CRoll/CYaw.rotation.x = 0
		#$CRoll/CYaw.rotation.y = lerp(yaw_old, $CRoll/CYaw.rotation.y ,CAMERA_CENTER_SENS * delta )
		$CRoll/CYaw.rotation.z = 0

		$CRoll/CYaw/CPitch.rotation.y = 0
		#$CRoll/CYaw/CPitch.rotation.x = lerp(pitch_old, $CRoll/CYaw/CPitch.rotation.x ,CAMERA_CENTER_SENS * delta )
		$CRoll/CYaw/CPitch.rotation.z = 0

		$CRoll/CYaw.transform = $CRoll/CYaw.transform.orthonormalized()
		$CRoll/CYaw/CPitch.transform = $CRoll/CYaw/CPitch.transform.orthonormalized()

	else:
		# Focus forward
		$CRoll/CYaw.rotation = lerp($CRoll/CYaw.rotation, Vector3(0, 0, 0), CAMERA_CENTER_SENS * delta)
		$CRoll/CYaw/CPitch.rotation = lerp($CRoll/CYaw/CPitch.rotation, Vector3(0, 0, 0), CAMERA_CENTER_SENS * delta)

		$CRoll/CYaw.transform = $CRoll/CYaw.transform.orthonormalized()
		$CRoll/CYaw/CPitch.transform = $CRoll/CYaw/CPitch.transform.orthonormalized()

	# Camera stabilizations
	$CRoll.rotation.z = -rotation.z

	if ConfigHandler.selected_controller != null:
		# Rotate camera on right joystick motion
		var axis_x = Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_RIGHT_X)
		if axis_x < JOY_AXIS_DEADZONE && axis_x > -JOY_AXIS_DEADZONE:
			axis_x = 0
		var axis_y = Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_RIGHT_Y)
		if axis_y < JOY_AXIS_DEADZONE && axis_y > -JOY_AXIS_DEADZONE:
			axis_y = 0

		var camera_rotation = Vector2(axis_x, axis_y) * 2000 * (CAMERA_ROTATION_SENS / 100) * delta
		$CRoll/CYaw.rotate_y(-camera_rotation.x)
		$CRoll/CYaw/CPitch.rotate_x(camera_rotation.y)
		$CRoll/CYaw.transform = $CRoll/CYaw.transform.orthonormalized()
		$CRoll/CYaw/CPitch.transform = $CRoll/CYaw/CPitch.transform.orthonormalized()

		# Vibrate controller if boosting
		if Input.is_action_pressed("boost") && boost_count > 0:
			Input.start_joy_vibration(ConfigHandler.selected_controller, 1, 0, 0)
		else:
			Input.stop_joy_vibration(ConfigHandler.selected_controller)


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
		var axis_x = -Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_LEFT_X)
		if axis_x < JOY_AXIS_DEADZONE && axis_x > -JOY_AXIS_DEADZONE:
			axis_x = 0
		var axis_y = -Input.get_joy_axis(ConfigHandler.selected_controller, JOY_AXIS_LEFT_Y)
		if axis_y < JOY_AXIS_DEADZONE && axis_y > -JOY_AXIS_DEADZONE:
			axis_y = 0

		steering_force = float(min(1, max(-1, steering_force + axis_x)))
		tilt_yaw_force = float(min(1, max(-1, tilt_yaw_force + axis_y)))

	if abs(velocity.x) + abs(velocity).z > 0.5:
		rotate_y(steering_force / (101 - TILT_SENSITIVITY))

	# Boosting
	if Input.is_action_pressed("boost") && boost_count > 0:
		if !(allow_tweaks && tweaks_config["unlimited_boost"]):
			boost_count -= 10 * delta
			boost_count = max(0, boost_count)
		velocity = velocity + (transform.basis.z * SPEED_BOOST * delta)

	if wheels_touching_ground:
		has_dubble_jump = true

		# Rotate car straight if grounded and titled
		if is_on_floor_only():
			var base = Basis()
			transform.basis.x.y = lerp(transform.basis.x.y, base.x.y, 10 * delta)
			transform.basis.y = lerp(transform.basis.y, base.y, 10 * delta)
			transform.basis.z.y = lerp(transform.basis.z.y, base.z.y, 10 * delta)
		#if is_on_wall_only():
		#var base = Basis().rotated(get_wall_normal(), deg_to_rad(90))
		#transform.basis.x.y = lerp(transform.basis.x.y, base.x.y, 10 * delta)
		#transform.basis.y = lerp(transform.basis.y, base.y, 10 * delta)
		#transform.basis.z.y = lerp(transform.basis.z.y, base.z.y, 10 * delta)
		if is_on_ceiling_only():
			var base = Basis().rotated(Vector3(1, 0, 0), deg_to_rad(180))
			transform.basis.x.y = lerp(transform.basis.x.y, base.x.y, 10 * delta)
			transform.basis.y = lerp(transform.basis.y, base.y, 10 * delta)
			transform.basis.z.y = lerp(transform.basis.z.y, base.z.y, 10 * delta)

		# Rotate moving direction to car forwards direction
		if !Input.is_action_pressed("slide"):
			var velocity_y = velocity.y
			velocity = velocity.rotated(transform.basis.z.normalized(), 20 * delta)
			velocity.y = velocity_y

		# Apply forward and braking velocity
		velocity = (velocity + (transform.basis.z * (((acceleration * SPEED_FORWARD) - (deceleration * SPEED_REVERSED)) * delta)))
		velocity = velocity.lerp(Vector3(0, 0, 0), (SPEED_LOSS) * delta)

		# Jump
		if Input.is_action_pressed("jump"):
			velocity = velocity + (transform.basis.y * JUMP_VELOCITY)

	else:
		# Rotate car's yaw and pitch
		rotate_object_local(Vector3(1, 0, 0), tilt_yaw_force / (101 - TILT_SENSITIVITY))
		rotate_object_local(Vector3(0, 0, 1), tilt_pitch_force / (101 - TILT_SENSITIVITY))

		# Dubble jump
		if Input.is_action_pressed("jump") && has_dubble_jump:
			has_dubble_jump = false
			velocity = velocity + (transform.basis.y * JUMP_VELOCITY)

	# Ensure velocity never goes over max
	velocity.x = maxf(minf(velocity.x, SPEED_MAX), -SPEED_MAX)
	velocity.y = maxf(minf(velocity.y, SPEED_MAX), -SPEED_MAX)
	velocity.z = maxf(minf(velocity.z, SPEED_MAX), -SPEED_MAX)

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
