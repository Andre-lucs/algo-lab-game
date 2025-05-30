@tool
class_name Number extends Node2D

static var number_scene : PackedScene = preload("res://scenes/objects/number/number.tscn")

@export var value: int = 0 : set = set_value

func _ready():
	update_label()

func get_value() -> int:
	return value

func set_value(new_value: int):
	value = new_value
	update_label()

func update_label():
	if get_node_or_null("Label") == null:
		return
	$Label.text = str(value)  # Atualiza a exibição do número

func move_to(new_position: Vector2, new_parent : Node2D = null, new_rotation: float = 0.0, duration := 0.2) -> void:
	if new_parent != null:
		if is_inside_tree():
			reparent(new_parent)
		else:
			new_parent.add_child(self)
	
	var anim = create_tween()
	anim.parallel().tween_property(self, "position", new_position, duration)
	anim.parallel().tween_property(self, "rotation", new_rotation, duration)
	anim.play()

static func get_number(int_number : int) -> Number:
	# Cria uma instância do número
	var number = number_scene.instantiate() as Number
	number.set_value(int_number)
	return number
