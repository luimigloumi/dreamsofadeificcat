extends Area3D

class_name Hitbox

@export var damage = 1.0
@export var debug = false

func _ready() -> void:
	area_entered.connect(on_entered)

func on_entered(other: Area3D) -> void:
	if other is Hurtbox:
		(other as Hurtbox).on_hurt(self, damage)
		if debug: print("haha yesss kill")
	