extends Node2D

@export var number : Number:
	set(value):
		if not is_inside_tree():
			number = value
			return
		number = value
		show_number()


func show_number(num: Number = number):
	if num == null:
		return
	show()
	num.move_to(Vector2.ZERO, self)
	num.show()

func _enter_tree() -> void:
	show_number()