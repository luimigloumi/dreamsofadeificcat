extends Area3D

class_name Hurtbox

signal hurt(source: Node3D)

@export var debug = false

func on_hit(source: Node3D):
	emit_signal("hurt", source)
	if debug: print("ow owie")
	