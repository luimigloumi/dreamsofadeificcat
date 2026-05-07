extends MovementAbility3D
class_name WalkAbility3D

## Basic movement ability

## Time for the character to reach full speed
@export var walk_acceleration := 8.0
@export var run_acceleration := 1.0
@export var walk_speed := 10.0
@export var run_speed := 20.0
@export var max_speed := 50.0

## Time for the character to stop walking
@export var deceleration := 10.0

## Sets control in the air
@export_range(0.0, 1.0, 0.05) var air_control := 0.3


## Takes direction of movement from input and turns it into horizontal velocity
func apply(velocity: Vector3, speed : float, is_on_floor : bool, direction : Vector3, delta: float, lastSpeed : float) -> Vector3:
	if not is_actived():
		return velocity
	
	var speedMult = speed

	# Using only the horizontal velocity, interpolate towards the input.
	var temp_vel := velocity
	temp_vel.y = 0
	
	var temp_accel: float

	if direction.dot(temp_vel) > 0:
		temp_accel = walk_acceleration * speedMult
		speed = walk_speed * speedMult
		if (lastSpeed > walk_speed):
			temp_accel = run_acceleration * speedMult
			speed = run_speed * speedMult
			if (lastSpeed > run_speed):
				temp_accel = deceleration
	else:
		temp_accel = deceleration
	var target: Vector3 = direction * speed
	
	if not is_on_floor:
		temp_accel *= air_control
	
	temp_vel = temp_vel.move_toward(target, temp_accel * delta)
	
	velocity.x = temp_vel.x
	velocity.z = temp_vel.z
	return velocity
