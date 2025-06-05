class_name GrabbingAreaDetector extends MouseInteractionArea2D

signal number_released_over(number: Number, last_global_pos : Vector2)
signal object_released_over(object: Node2D, last_global_pos : Vector2)

func catch_object(object : Node2D, last_global_pos : Vector2):
	if object is Number:
		number_released_over.emit(object as Number, last_global_pos)
		prints("number released")
	else:
		object_released_over.emit(object, last_global_pos)
