extends Area3D

class_name Hurtbox

signal hurt(source: Node3D, damage: float)

@export var debug = false

func on_hit(source: Node3D, damage: float):
	emit_signal("hurt", source, damage)
	if debug: print("ow owie")
	