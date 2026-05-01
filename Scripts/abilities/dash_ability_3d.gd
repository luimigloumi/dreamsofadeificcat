extends MovementAbility3D
class_name DashAbility3D

## Simple ability that adds a vertical impulse when actived (Jump)

## Jump/Impulse height
@export var boost := 10


## Change vertical velocity of [CharacterController3D]
func apply(velocity : Vector3, speed : float, is_on_floor : bool, direction : Vector3, _delta : float) -> Vector3:
	if is_actived():
		var temp_dir := direction
		temp_dir.y = 0
		temp_dir = temp_dir.normalized() * boost
		
		velocity += temp_dir
		velocity.y = 10
	return velocity
