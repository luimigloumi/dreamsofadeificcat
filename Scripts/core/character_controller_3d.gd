extends CharacterBody3D
class_name CharacterController3D

## Main class of the addon, contains abilities array for character movements.

## Emitted when the character controller performs a step, called at the end of 
## the [b]move()[/b] 
## function when a move accumulator for a step has ended.
signal stepped

## Emitted when touching the ground after being airborne, called in the 
## [b]move()[/b] function.
signal landed

## Emitted when a jump is processed, is called when [JumpAbility3D] is active.
signal jumped

signal dashed

## Emitted when a sprint started, is called when [SprintAbility3D] is active.
signal sprinted

@export_group("Movement")

## Controller Gravity Multiplier
## The higher the number, the faster the controller will fall to the ground and 
## your jump will be shorter.
@export var gravity_multiplier : float = 3.0

## Controller base speed
## Note: this speed is used as a basis for abilities to multiply their 
## respective values, changing it will have consequences on [b]all abilities[/b]
## that use velocity.
var speed : float = 1.0

@export_group("Sprint")

## Speed to be multiplied when active the ability
@export var sprint_speed_multiplier : float = 1.6


@export_group("Footsteps")

## Maximum counter value to be computed one step
@export var step_lengthen : float = 0.7

## Value to be added to compute a step, each frame that the character is walking this value 
## is added to a counter
@export var step_interval : float = 6.0


@export_group("Jump")

## Jump/Impulse height
@export var jump_height : float = 10.0

@export_group("Dash")

@export var dash_strength : float = 10.0


@export_group("Abilities")
## List of movement skills to be used in processing this class.
@export var abilities_path: Array[NodePath]

## List of movement skills to be used in processing this class.
var _abilities: Array[MovementAbility3D]
 
## Result direction of inputs sent to [b]move()[/b].
var _direction := Vector3()

## Current counter used to calculate next step.
var _step_cycle : float = 0

## Maximum value for _step_cycle to compute a step.
var _next_step : float = 0

## Character controller horizontal speed.
var _horizontal_velocity : Vector3

## Base transform node to direct player movement
## Used to differentiate fly mode/swim moves from regular character movement.
var _direction_base_node : Node3D

## Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
@onready var gravity: float = (ProjectSettings.get_setting("physics/3d/default_gravity") * gravity_multiplier)

## Collision of character controller.
@onready var collision: CollisionShape3D = get_node(NodePath("Collision"))

## Above head collision checker, used for crouching and jumping.
@onready var head_check: ShapeCast3D = get_node(NodePath("Head Check"))

## Basic movement ability.
@onready var walk_ability: WalkAbility3D = get_node(NodePath("Walk Ability 3D"))

## Ability that adds extra speed when actived.
@onready var sprint_ability: SprintAbility3D = get_node(NodePath("Sprint Ability 3D"))

## Simple ability that adds a vertical impulse when actived (Jump).
@onready var jump_ability: JumpAbility3D = get_node(NodePath("Jump Ability 3D"))

@onready var dash_ability: DashAbility3D = get_node(NodePath("Dash Ability 3D"))

## Stores normal speed
@onready var _normal_speed : float = speed

@onready var player_mesh : Node3D = $Mesh
@onready var spring_arm_pivot : Node3D = $SpringArmPivot
@onready var spring_arm_3D : SpringArm3D = $SpringArmPivot/SpringArm3D

## True if in the last frame it was on the ground
var _last_is_on_floor := false

## Default controller height, affects collider
var _default_height : float

var doubleJumped := false

## Loads all character controller skills and sets necessary variables
func setup():
	_direction_base_node = self
	_abilities = _load_nodes(abilities_path)
	_default_height = collision.shape.height
	_connect_signals()
	_start_variables()


## Moves the character controller.
## parameters are inputs that are sent to be handled by all abilities.
func move(_delta: float, currentSpeed: float, input_axis := Vector2.ZERO, input_jump := false, input_sprint := false, input_dash := false) -> void:
	var safe_direction = _direction_input(input_axis, _direction_base_node)
	var direction : Vector3 = Vector3.ZERO
	direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	direction = direction.normalized()
	_check_landed()
	if not jump_ability.is_actived():
		velocity.y -= gravity * _delta
	
	jump_ability.set_active(input_jump and is_on_floor() and not head_check.is_colliding())
	if input_jump and not doubleJumped and not head_check.is_colliding() and not is_on_floor():
		jump_ability.set_active(true)
		doubleJumped = true
	dash_ability.set_active(input_dash)
	walk_ability.set_active(true)
	sprint_ability.set_active(input_sprint and is_on_floor() and  input_axis.y >= 0.5)
	
	var multiplier = 1.0
	for ability in _abilities:
		multiplier *= ability.get_speed_modifier()
	speed = _normal_speed * multiplier
	
	for ability in _abilities:
		velocity = ability.apply(velocity, speed, is_on_floor(), direction, _delta, currentSpeed)
	
	move_and_slide()
	_horizontal_velocity = Vector3(velocity.x, 0.0, velocity.z)
	
	_check_step(_delta)


## Returns true if the character controller is sprinting
func is_sprinting() -> bool:
	return sprint_ability.is_actived()


## Returns the speed of character controller
func get_speed() -> float:
	return speed

func _reset_step():
	_next_step = _step_cycle + step_interval


func _load_nodes(nodePaths: Array) -> Array[MovementAbility3D]:
	var nodes : Array[MovementAbility3D]
	for nodePath in nodePaths:
		var node := get_node(nodePath)
		if node != null:
			var ability = node as MovementAbility3D
			nodes.append(ability)
	return nodes


func _connect_signals():
	sprint_ability.actived.connect(_on_sprinted.bind())
	jump_ability.actived.connect(_on_jumped.bind())
	dash_ability.actived.connect(_on_dashed.bind())


func _start_variables():
	sprint_ability.speed_multiplier = sprint_speed_multiplier
	jump_ability.height = jump_height
	dash_ability.boost = dash_strength


func _check_landed():
	if is_on_floor() and not _last_is_on_floor:
		_on_landed()
		_reset_step()
	_last_is_on_floor = is_on_floor()
	

func _check_step(_delta):
	if _is_step(_horizontal_velocity.length(), is_on_floor(), _delta):
		_step(is_on_floor())

func _direction_input(input : Vector2, aim_node : Node3D) -> Vector3:
	_direction = Vector3()
	var aim = aim_node.get_global_transform().basis
	if input.y >= 0.5:
		_direction -= aim.z
	if input.y <= -0.5:
		_direction += aim.z
	if input.x <= -0.5:
		_direction -= aim.x
	if input.x >= 0.5:
		_direction += aim.x
	else:
		_direction.y = 0	
	return _direction.normalized()



func _step(is_on_floor:bool) -> bool:
	_reset_step()
	if(is_on_floor):
		emit_signal("stepped")
		return true
	return false


func _is_step(velocity:float, is_on_floor:bool, _delta:float) -> bool:
	if(abs(velocity) < 0.1):
		return false
	_step_cycle = _step_cycle + ((velocity + step_lengthen) * _delta)
	if(_step_cycle <= _next_step):
		return false
	return true


# Bubbly signals 😒
func _on_sprinted():
	emit_signal("sprinted")


func _on_jumped():
	emit_signal("jumped")

func _on_dashed():
	emit_signal("dashed")

func _on_landed():
	emit_signal("landed")
	doubleJumped = false
