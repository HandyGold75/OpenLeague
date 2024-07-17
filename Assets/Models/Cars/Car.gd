extends CharacterBody3D

const DEBUG = true

var ALLOW_TWEAKS = true
var tweaks_config = ConfigHandler.load_tweaks_config()

const SPEED_FORWARD = 30
const SPEED_REVERSED = 20
const SPEED_BOOST = 40
const SPEED_MAX = 40
const SPEED_LOSS = 0.5

const JUMP_VELOCITY = 10

const STEER_SENSITIVITY = 60
const TILT_SENSITIVITY = 60

const camera_rotation_sensitivity = 0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

var HasDubbleJump = true
var BoostCount = 30

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if ALLOW_TWEAKS:
		BoostCount = tweaks_config["start_boost"]

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * (camera_rotation_sensitivity / 100)
		$CameraYaw.rotate_y(-camera_rotation.x)
		$CameraYaw/CameraPitch.rotate_x(camera_rotation.y)
		$CameraYaw.transform = $CameraYaw.transform.orthonormalized()
		$CameraYaw/CameraPitch.transform = $CameraYaw/CameraPitch.transform.orthonormalized()


func _physics_process(delta: float):
	var wheels_touching_ground = is_on_floor() || is_on_wall() || is_on_ceiling()
	if not is_on_floor() || (wheels_touching_ground && abs(velocity.x) + abs(velocity).z < 1):
		velocity.y -= gravity * delta

	var sliding = Input.is_action_pressed("slide")
	var boosting = Input.is_action_pressed("boost")
	var acceleration = Input.get_action_strength("throttle", false)
	var deceleration = Input.get_action_strength("reverse", false)
	var steering_force = Input.get_axis("steer_right", "steer_left")
	var just_jumped = Input.is_action_just_pressed("jump")
	var jump_force = Input.get_action_strength("jump")
	var tilt_yaw_force = Input.get_axis("tilt_down", "tilt_up")
	var tilt_pitch_force = Input.get_axis("tilt_left", "tilt_right")

	# Rotate car
	if abs(velocity.x) + abs(velocity).z > 0.5 :
		rotate_y(steering_force/(101-TILT_SENSITIVITY))

	if boosting && BoostCount > 0:
		if !(ALLOW_TWEAKS && tweaks_config["unlimited_boost"]):
			BoostCount -= 10 * delta
			BoostCount = max(0, BoostCount)
		velocity = velocity + (transform.basis.z * SPEED_BOOST * delta)

	if wheels_touching_ground:
		HasDubbleJump = true

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
		if !sliding:
			var velocity_y = velocity.y
			velocity = velocity.rotated(transform.basis.z.normalized(), 20 * delta)
			velocity.y = velocity_y

		# Apply forward and braking velocity
		velocity = velocity + (transform.basis.z * (((acceleration * SPEED_FORWARD) - (deceleration * SPEED_REVERSED)) * delta))
		velocity = velocity.lerp(Vector3(0, 0, 0), (SPEED_LOSS) * delta)

		# Jump
		if just_jumped:
			velocity = velocity + (transform.basis.y * JUMP_VELOCITY * jump_force)

	else:
		# Rotate car's yaw and pitch
		rotate_object_local(Vector3(1, 0, 0), tilt_yaw_force/(101-TILT_SENSITIVITY))
		rotate_object_local(Vector3(0, 0, 1), tilt_pitch_force/(101-TILT_SENSITIVITY))

		# Dubble jump
		if just_jumped && HasDubbleJump:
			HasDubbleJump = false
			velocity = velocity + (transform.basis.y * JUMP_VELOCITY * jump_force)

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
				col_obj.apply_impulse(push_direction * 10, Vector3.ZERO )

	# Debug
	if DEBUG:
		print("-----")
		print(velocity)
		print(wheels_touching_ground)
		print(transform.basis)
		print(HasDubbleJump)
		print(BoostCount)

	# Cleanup
	transform = transform.orthonormalized()
	move_and_slide()
