extends CharacterBody3D

@export_category("actions")

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"
@export var input_fly_mode_action_name := "move_fly_mode"
@export var input_dive_action_name := "move_dash"

@export_category("main")

@export var p_camera_rotator : NodePath
@onready var camera_rotator : Node3D

@export var walk_speed = 10.0
@export var run_speed = 20.0
@export var max_speed = 40.0
@export var exceed_speed = 60.0

@export var walk_acceleration = 20.0
@export var run_acceleration = 7.0
@export var deceleration = 12.0

@export var turn_speed = 90.0

var direction = Vector3.ZERO
var speed = 0.0

func get_movement_vector() -> Vector3:
	var movement := Input.get_vector(input_left_action_name, input_right_action_name, input_forward_action_name, input_back_action_name)
	return Vector3(movement.x, 0, movement.y) * camera_rotator.global_basis

func get_desired_speed() -> float:
	if speed < walk_speed:
		return walk_speed
	else:
		return run_speed

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_rotator  = $p_camera_rotator


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity = apply_gravity(velocity, delta)
	velocity = apply_walk(velocity, delta)
	move_and_slide()

func apply_gravity(veloc: Vector3, delta: float) -> Vector3:
	veloc.y -= 9.8 * delta
	return veloc

func apply_walk(veloc: Vector3, delta: float) -> Vector3:
	var movement = get_movement_vector()
	var move_direction = movement.normalized()
	direction = direction.rotated(Vector3.UP, min(direction.angle_to(move_direction), turn_speed * delta))
	var desired_speed_level = get_desired_speed()
	var desired_speed = movement.length() * desired_speed_level
	var accel = 0.0
	if desired_speed < speed:
		accel = deceleration
	elif speed < walk_speed:
		accel = walk_acceleration
	elif speed < run_speed: 
		accel = run_acceleration
	speed = move_toward(speed, desired_speed, accel * delta)
	return direction * speed
