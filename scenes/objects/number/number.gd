@tool
class_name Number extends Node2D

static var number_scene : PackedScene = preload("res://scenes/objects/number/number.tscn")

@export var value: float = 0 : set = set_value

@onready var label: Label = $Label

func _ready():
	update_label()

func get_value() -> float:
	return value

func get_string() -> String:
	return str(value).replace(".0", "").replace(",0", "")

func set_value(new_value: float):
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

static func get_number(float_number : float) -> Number:
	# Cria uma instância do número
	var number = number_scene.instantiate() as Number
	number.set_value(float_number)
	return number
