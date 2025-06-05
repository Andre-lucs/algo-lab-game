class_name GrabbingAreaDetector extends MouseInteractionArea2D

signal number_released_over(number: Number, last_global_pos : Vector2)
signal object_released_over(object: Node2D, last_global_pos : Vector2)
signal number_removed(number: Number, last_global_pos : Vector2)
signal object_removed(object: Node2D, last_global_pos : Vector2)

var remove_cooldown : Array[Node2D] = []

func catch_object(object : Node2D, last_global_pos : Vector2):
	if object is Number:
		number_released_over.emit(object as Number, last_global_pos)
	else:
		object_released_over.emit(object, last_global_pos)
	
	remove_cooldown.append(object)
	get_tree().create_timer(0.2).timeout.connect(remove_cooldown.erase.bind(object))


func removed_object_from_area(object : Node2D, last_global_pos : Vector2):
	if object in remove_cooldown:
		return # Already in cooldown, ignore this removal
	if object is Number:
		number_removed.emit(object as Number, last_global_pos)
	else:
		object_removed.emit(object, last_global_pos)
