extends CharacterBody3D
	
const SPEED = 20
const SPEED_REVERSED = 10
const SPEED_MAX = 40
const SPEED_LOSS = 0.2

const JUMP_VELOCITY = 5

const STEER_SENSITIVITY = 2

const camera_rotation_sensitivity = 0.01

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	# Makes your mouse disappear from the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * camera_rotation_sensitivity
		$CameraYaw.rotate_y(-camera_rotation.x)
		$CameraYaw/CameraPitch.rotate_x(camera_rotation.y)
		
		$CameraYaw.transform = $CameraYaw.transform.orthonormalized()
		
		#$CameraYaw.rotate(Vector3.DOWN, camera_rotation.x)
		#$CameraYaw/CameraPitch.rotate(Vector3.RIGHT, camera_rotation.y)

func _physics_process(delta):
	var steering = Input.get_axis("move_right", "move_left")
	rotate_y(steering/(101-STEER_SENSITIVITY))
	
	var acceleration = Input.get_action_strength("move_forward", false)
	var deceleration = Input.get_action_strength("move_backward", false)
	
	velocity = velocity + (transform.basis.z * (((acceleration * SPEED) - (deceleration * SPEED_REVERSED)) * delta))
	velocity = velocity.lerp(Vector3(0, 0, 0), (SPEED_LOSS + deceleration) * delta)
	
	velocity.x = maxf(minf(velocity.x, SPEED_MAX), -SPEED_MAX)
	velocity.y = maxf(minf(velocity.y, SPEED_MAX), -SPEED_MAX)
	velocity.z = maxf(minf(velocity.z, SPEED_MAX), -SPEED_MAX)
	
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	#print("-----")
	#print(velocity)
	
	# Cleanup
	transform = transform.orthonormalized()
	move_and_slide()

