extends CharacterBody3D
	
const SPEED = 30
const SPEED_REVERSED = 20
const SPEED_MAX = 40
const SPEED_LOSS = 0.5

const JUMP_VELOCITY = 5

const STEER_SENSITIVITY = 40

const camera_rotation_sensitivity = 1

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Makes your mouse disappear from the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * (camera_rotation_sensitivity / 100)
		$CameraYaw.rotate_y(-camera_rotation.x)
		$CameraYaw/CameraPitch.rotate_x(camera_rotation.y)
		
		$CameraYaw.transform = $CameraYaw.transform.orthonormalized()
		
		#$CameraYaw.rotate(Vector3.DOWN, camera_rotation.x)
		#$CameraYaw/CameraPitch.rotate(Vector3.RIGHT, camera_rotation.y)

func _physics_process(delta):	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Rotate car
	var player = get_node("/root/Player")
	var brake_force = Input.get_action_strength("brake")
	var acceleration = Input.get_action_strength("throttle", false)
	var deceleration = Input.get_action_strength("reverse", false)
	var steering_force = Input.get_axis("steer_right", "steer_left")
	var jump_force = Input.get_action_strength("jump")
	
	rotate_y(steering_force/(101-STEER_SENSITIVITY))
		
	if is_on_floor():
		player.HasDubbleJump = true
		
		# Jump
		if jump_force > 0:
			velocity.y = JUMP_VELOCITY * jump_force
			return

		# Rotate moving direction to car forwards direction
		if brake_force <= 0:
			var velocity_y = velocity.y
			velocity = velocity.rotated(transform.basis.z.normalized(), 20 * delta)
			velocity.y = velocity_y
		
		# Apply forward and braking velocity
		
		velocity = velocity + (transform.basis.z * (((acceleration * SPEED) - (deceleration * SPEED_REVERSED)) * delta))
		velocity = velocity.lerp(Vector3(0, 0, 0), (SPEED_LOSS) * delta)
		
		if acceleration + deceleration <= 0:
			if velocity.x + velocity.z < 5 && velocity.x + velocity.z > -5:
				velocity = velocity.lerp(Vector3(0, 0, 0), 3 * delta)
	else:
		if jump_force > 0 && player.HasDubbleJump:
			player.HasDubbleJump = false
			velocity.y += JUMP_VELOCITY * jump_force
		
	# Ensure velocity never goes over max
	velocity.x = maxf(minf(velocity.x, SPEED_MAX), -SPEED_MAX)
	velocity.y = maxf(minf(velocity.y, SPEED_MAX), -SPEED_MAX)
	velocity.z = maxf(minf(velocity.z, SPEED_MAX), -SPEED_MAX)
	
	
	#print("-----")
	#print(steering_force)
	
	# Cleanup
	transform = transform.orthonormalized()
	move_and_slide()

