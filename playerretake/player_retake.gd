extends CharacterBody3D

@export_category("actions")

@export var input_back_action_name := "move_backward"
@export var input_forward_action_name := "move_forward"
@export var input_left_action_name := "move_left"
@export var input_right_action_name := "move_right"
@export var input_sprint_action_name := "move_sprint"
@export var input_jump_action_name := "move_jump"
@export var input_crouch_action_name := "move_crouch"
@export var input_debug_display_action_name := "debug_display"
@export var input_dive_action_name := "move_dash"

@export_category("main")

@export var p_camera_rotator : NodePath
var camera_rotator : Node3D

@onready var debug_display = $"DebugUI"

@export var start_speed = 3.0
@export var walk_speed = 10.0
@export var run_speed = 20.0
@export var max_speed = 40.0
@export var exceed_speed = 60.0

@export var walk_acceleration = 20.0
@export var run_acceleration = 7.0
@export var deceleration = 12.0
@export var skid_deceleration = 30.0

@export var turn_deceleration = 0.3

@export var air_control_mult = 0.4

@export var jump_mult = 3.0
@export var fall_mult = 6.0

@export var walk_turn_speed = 9.0
@export var run_turn_speed = 9.0

@export var dive_boost = 1.0
@export var dive_bump = 5.0

var direction = Vector3.FORWARD
var speed = 0.0

@export var jump_force = 20.0
var jump_flag = 0.0
var coyote_flag = 0.0
@export var jump_buffer = 0.3
@export var coyote_buffer = 0.3
var jumping = false

var has_dived = false
@export var dive_buffer = 0.3
var dive_flag = 0.0

func get_movement_vector() -> Vector3:
	var movement := Input.get_vector(input_left_action_name, input_right_action_name, input_forward_action_name, input_back_action_name)
	return camera_rotator.global_basis.x * movement.x + camera_rotator.global_basis.z * movement.y

func get_desired_speed() -> float:
	if speed < walk_speed:
		return walk_speed
	else:
		return run_speed

func get_turn_speed() -> float:
	if speed < walk_speed:
		return walk_turn_speed
	else:
		return run_turn_speed

func get_gravity_mult() -> float:
	if jumping:
		return jump_mult
	return fall_mult

func get_accel_mult() -> float:
	if is_on_floor():
		return 1.0
	return air_control_mult

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	camera_rotator  = get_node(p_camera_rotator)

func _process(delta: float) -> void:

	dive_flag = max(0.0, dive_flag - delta)
	jump_flag = max(0.0, jump_flag - delta)
	coyote_flag = max(0.0, coyote_flag - delta)

	if Input.is_action_just_pressed(input_debug_display_action_name):
		debug_display.visible = !debug_display.visible
	#these two ensure that jumping and diving doesn't not work if you're slightly too early!
	if Input.is_action_just_pressed(input_dive_action_name):
		dive_flag = dive_buffer
	if Input.is_action_just_pressed(input_jump_action_name):
		jump_flag = jump_buffer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:

	if is_on_floor():
		has_dived = false
		#ensures that jumping doesn't not work if you're slightly too late
		coyote_flag = coyote_buffer

	velocity = apply_gravity(velocity, delta)
	velocity = apply_jump(velocity, delta)
	velocity = apply_dive(velocity, delta)
	velocity = apply_walk(velocity, delta)

	var result = direction * speed
	result.y = velocity.y

	velocity = result

	move_and_slide()
	
	speed = clamp(speed, 0, velocity.length())

func apply_gravity(veloc: Vector3, delta: float) -> Vector3:
	veloc.y -= 9.8 * delta * get_gravity_mult()
	return veloc

func apply_walk(veloc: Vector3, delta: float) -> Vector3:
	var movement = get_movement_vector()
	var move_direction = movement.normalized()
	var desired_speed_level = get_desired_speed()
	var desired_speed = movement.length() * desired_speed_level
	var accel = 0.0
	if desired_speed < speed:
		accel = deceleration
	elif speed < walk_speed:
		accel = walk_acceleration
	elif speed < run_speed: 
		accel = run_acceleration
	accel *= get_accel_mult()
	# *1.05 fixes a bug where the player doesn't reach running state, but does also cause a slight increase in running speed. It's only 1m/s so I don't really care.
	speed = move_toward(speed, desired_speed * 1.05, accel * delta)
	if move_direction.dot(direction) < 0.6:
		speed = move_toward(speed, 0, accel * turn_deceleration * delta)
	speed = clamp(speed, 0, max_speed)
	# add hypeerspeed check thiung

	if speed < start_speed && move_direction != Vector3.ZERO:
		speed = start_speed
		direction = move_direction
	elif move_direction.dot(direction) < -0.8:
		speed = move_toward(speed, 0, skid_deceleration * delta)
	else:
		var angle_sign = sign(direction.signed_angle_to(move_direction, Vector3.UP))
		direction = direction.rotated(Vector3.UP, min(abs(direction.signed_angle_to(move_direction, Vector3.UP)), get_turn_speed() * delta) * angle_sign)

	return veloc 

func apply_dive(veloc: Vector3, delta: float) -> Vector3:
	if dive_flag > 0.0 && !has_dived:
		has_dived = true
		dive_flag = 0.0
		veloc.y = dive_bump
		speed += dive_boost
		var movement = get_movement_vector()
		var move_direction = movement.normalized()
		direction = move_direction
	return veloc

func apply_jump(veloc: Vector3, delta: float) -> Vector3:
	if jump_flag > 0 && coyote_flag > 0:
		jump_flag = 0
		coyote_flag = 0
		jumping = true
		veloc.y = jump_force
	if veloc.y < 0 or !Input.is_action_pressed(input_jump_action_name):
		jumping = false
	return veloc
