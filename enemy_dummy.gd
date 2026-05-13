extends CharacterBody3D

@export var bounciness = 3.0
@export var slipperiness = 0.5
@export var max_health = 3.0
var health = 3.0

@export var debug = false

@export var death_effect: PackedScene

func on_hurt(other: Node3D, damage: float):
	velocity += other.global_position.direction_to(self.global_position) * bounciness + Vector3.UP * bounciness
	health -= damage
	if health <= 0.0: on_death(other)

func on_death(_other: Node3D):
	queue_free()
	if death_effect != null:
		var effect = death_effect.instantiate()
		get_parent().add_child(effect)
		effect.global_position = global_position
	if debug: print("auuuugh")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	velocity += get_gravity() * delta
	velocity.x = move_toward(velocity.x, 0, (1.0 / slipperiness) * delta)
	velocity.z = move_toward(velocity.z, 0, (1.0 / slipperiness) * delta)
	move_and_slide()
