@tool
class_name Number extends Node2D

static var number_scene : PackedScene = preload("res://scenes/objects/number/number.tscn")

@export var value: int = 0 : set = set_value

func _ready():
	update_label()

func get_value():
	return value

func set_value(new_value: int):
	value = new_value
	update_label()

func update_label():
	if get_node_or_null("Label") == null:
		return
	$Label.text = str(value)  # Atualiza a exibição do número

static func get_number(int_number : int) -> Number:
	# Cria uma instância do número
	var number = number_scene.instantiate() as Number
	number.set_value(int_number)
	return number
