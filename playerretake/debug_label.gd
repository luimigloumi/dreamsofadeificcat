extends Label

@export var p_target: NodePath
var target: Node
@export var variable = "value"
@export var prefix = "variable: "
@export var suffix = " units"

func _ready() -> void:
	target = get_node(p_target)

func _process(delta: float) -> void:
	if visible:
		text = prefix + str(target.get(variable)) + suffix
