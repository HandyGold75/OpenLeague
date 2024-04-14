extends VehicleBody3D

const max_rpm = 500
const max_torque = 50

const JUMP_VELOCITY = 10

const camera_rotation_sensitivity = 0.01

func _ready():
	# Makes your mouse disappear from the screen
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		var camera_rotation = event.relative * camera_rotation_sensitivity
		# "yaw" is the term for side-to-side turning of the camera (around a vertical axis)
		$CameraYaw.rotate(Vector3.DOWN, camera_rotation.x)
		# "pitch" is the term for up-and-down movement of the camera (around a horizontal axis)
		$CameraYaw/CameraPitch.rotate(Vector3.RIGHT, camera_rotation.y)

func _physics_process(delta):
	steering =  lerp(steering, Input.get_axis("move_right","move_left") * 0.4, 5 * delta)
	
	if Input.is_action_just_pressed("ui_accept"):
		$Body.velocity.y = JUMP_VELOCITY
		
	var acceletation = Input.get_axis("move_backward", "move_forward")
	
	var rpm = $Wheel_FL.get_rpm()
	$Wheel_FL.engine_force = acceletation * max_torque * (1 - rpm / max_rpm)
	rpm = $Wheel_FR.get_rpm()
	$Wheel_FR.engine_force = acceletation * max_torque * (1 - rpm / max_rpm)
	rpm = $Wheel_BL.get_rpm()
	$Wheel_BL.engine_force = acceletation * max_torque * (1 - rpm / max_rpm)
	rpm = $Wheel_BR.get_rpm()
	$Wheel_BR.engine_force = acceletation * max_torque * (1 - rpm / max_rpm)
