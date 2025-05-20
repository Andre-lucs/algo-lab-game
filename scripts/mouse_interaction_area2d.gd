@tool
class_name MouseInteractionArea2D extends Area2D

var mouse_over : bool = false

func _init() -> void:
	set_collision_layer_value(1, false)
	set_collision_mask_value(1, false)
	set_collision_layer_value(32, true)

func _ready():
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
	mouse_over = true
func _on_mouse_exited() -> void:
	mouse_over = false

func is_mouse_over() -> bool:
	return mouse_over
	