extends Node3D

@export_group("FOV")
@export var normal_fov : float = 75.0

const CAMERA_BLEND : float = 0.05

@onready var spring_arm : SpringArm3D = $SpringArm3D
@onready var camera : Camera3D = $SpringArm3D/Camera3D
@export var input_look_left_name := "look_left"
@export var input_look_right_name := "look_right"
@export var input_look_up_name := "look_up"
@export var input_look_down_name := "look_down"

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func update_camera_controller():
	var direction := Input.get_vector(input_look_left_name, input_look_right_name, input_look_up_name, input_look_down_name)
	rotate_y(-direction.x * 0.0015)
	spring_arm.rotate_x(-direction.y * 0.0015)
	spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2.5, 0)

func _process(delta) -> void:
	update_camera_controller()
	pass
	
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * 0.005)
		spring_arm.rotate_x(-event.relative.y * 0.005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/2.5, 0)
