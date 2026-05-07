#extends CharacterBody3D
#
#const LERP_VALUE : float = 0.15
#
#var snap_vector : Vector3 = Vector3.DOWN
#var speed : float
#
#
#@export_group("Movement variables")
#@export var walk_speed : float = 5.0
#@export var run_speed : float = 10.0
#@export var jump_strength : float = 25.0
#@export var gravity : float = 50.0
#@export var MAX_ZOOM_IN = 1
#@export var MAX_ZOOM_OUT = 7
#
#const ANIMATION_BLEND : float = 7.0
#
#@onready var player_mesh : Node3D = $Mesh
#@onready var spring_arm_pivot : Node3D = $SpringArmPivot
#@onready var spring_arm_3D : SpringArm3D = $SpringArmPivot/SpringArm3D
#@onready var animator : AnimationTree = $AnimationTree
#
#func _physics_process(delta):
	#var move_direction : Vector3 = Vector3.ZERO
	#move_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	#move_direction.z = Input.get_action_strength("move_backward") - Input.get_action_strength("move_forward")
	#move_direction = move_direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	#
	#velocity.y -= gravity * delta
#
	#if Input.is_action_pressed("run"):
		#speed = run_speed
	#else:
		#speed = walk_speed
	#
	#velocity.x = move_direction.x * speed
	#velocity.z = move_direction.z * speed
	#
	#if move_direction:
		#player_mesh.rotation.y = lerp_angle(player_mesh.rotation.y, atan2(velocity.x, velocity.z), LERP_VALUE)
	#
	#var just_landed := is_on_floor() and snap_vector == Vector3.ZERO
	#var is_jumping := is_on_floor() and Input.is_action_just_pressed("jump")
	#if is_jumping:
		#velocity.y = jump_strength
		#snap_vector = Vector3.ZERO
	#elif just_landed:
		#snap_vector = Vector3.DOWN
	#
	#if Input.is_action_just_pressed("zoom_in"):
		#spring_arm_3D.spring_length = clampf(spring_arm_3D.spring_length*.8, MAX_ZOOM_IN, MAX_ZOOM_OUT)
	#if Input.is_action_just_pressed("zoom_out"):
		#spring_arm_3D.spring_length = clampf(spring_arm_3D.spring_length*1.2, MAX_ZOOM_IN, MAX_ZOOM_OUT)
	#apply_floor_snap()
	#move_and_slide()
	#animate(delta)
#
#func animate(delta):
	#pass
	##if is_on_floor():
		##animator.set("parameters/ground_air_transition/transition_request", "grounded")
		##
		##if velocity.length() > 0:
			##if speed == run_speed:
				##animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 1.0, delta * ANIMATION_BLEND))
			##else:
				##animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), 0.0, delta * ANIMATION_BLEND))
		##else:
			##animator.set("parameters/iwr_blend/blend_amount", lerp(animator.get("parameters/iwr_blend/blend_amount"), -1.0, delta * ANIMATION_BLEND))
	##else:
		##animator.set("parameters/ground_air_transition/transition_request", "air")
