extends ThreePSController3D
class_name BPlayer

## Example script that extends [CharacterController3D] through 
## [FPSController3D].
## 
## This is just an example, and should be used as a basis for creating your 
## own version using the controller's [b]move()[/b] function.
## 
## This player contains the inputs that will be used in the function 
## [b]move()[/b] in [b]_physics_process()[/b].
## The input process only happens when mouse is in capture mode.
## This script also adds submerged and emerged signals to change the 
## [Environment] when we are in the water.

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"
@export var input_fly_mode_action_name := "move_fly_mode"
@export var input_dash_action_name := "move_dash"
@export var MAX_ZOOM_IN = 1
@export var MAX_ZOOM_OUT = 7

var horizontalVelocity : Vector3
var lastPos : Vector3
var currentPos : Vector3
var currentSpeed

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	setup()
	lastPos = Vector3(position.x, 0, position.z)
	currentPos = lastPos


func _physics_process(delta):
	if Input.is_action_just_pressed("zoom_in"):
		spring_arm_3D.spring_length = clampf(spring_arm_3D.spring_length*.8, MAX_ZOOM_IN, MAX_ZOOM_OUT)
	if Input.is_action_just_pressed("zoom_out"):
		spring_arm_3D.spring_length = clampf(spring_arm_3D.spring_length*1.2, MAX_ZOOM_IN, MAX_ZOOM_OUT)
	var is_valid_input := Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	lastPos = currentPos
	currentPos = Vector3(position.x, 0, position.z)
	currentSpeed = (currentPos-lastPos).length()/delta
	if is_valid_input:
		var input_axis = Input.get_vector(input_left_action_name, input_right_action_name, input_back_action_name, input_forward_action_name)
		var input_jump = Input.is_action_just_pressed(input_jump_action_name)
		var input_sprint = Input.is_action_pressed(input_sprint_action_name)
		var input_dash = Input.is_action_just_pressed(input_dash_action_name)
		move(delta, currentSpeed, input_axis, input_jump, input_sprint, input_dash)
	else:
		# NOTE: It is important to always call move() even if we have no inputs 
		## to process, as we still need to calculate gravity and collisions.
		move(delta)


func _input(event: InputEvent) -> void:
	# Mouse look (only if the mouse is captured).
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		pass
		#rotate_head(event.screen_relative)
