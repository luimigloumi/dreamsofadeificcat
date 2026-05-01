extends CharacterController3D
class_name ThreePSController3D

## Character Controller 3D specialized in FPS.
##
## Contains camera information:[br]
## - FOV[br]
## - HeadBob[br]
## - Rotation limits[br]
## - Inputs for camera rotation[br]

@export_group("FOV")

## Speed at which the FOV changes
@export var fov_change_speed := 4

## FOV to be multiplied when active the sprint
@export var sprint_fov_multiplier := 1.1

@export_group("Mouse")



## Maximum vertical angle the head can aim
@export var vertical_angle_limit := 90.0








## Configure mouse sensitivity, rotation limit angle and head bob
## After call the base class setup [CharacterController3D].
func setup():
	super.setup()

## Rotate head based on mouse axis parameter.
## This function call [b]head.rotate_camera()[/b].
#func rotate_head(mouse_axis : Vector2) -> void:
	#head.rotate_camera(mouse_axis)


## Call to move the character.
## First it is defined what the direction of movement will be, whether it is vertically or not 
## based on whether swim or fly mode is active.
## Afterwards, the [b]move()[/b] of the base class [CharacterMovement3D] is called
## It is then called functions responsible for head bob if necessary.
func move(_delta: float, input_axis := Vector2.ZERO, input_jump := false, input_sprint := false, input_dash := false):
	super.move(_delta, input_axis, input_jump, input_sprint, input_dash)




func _on_jumped():
	super._on_jumped()

func _on_dashed():
	super._on_dashed()
