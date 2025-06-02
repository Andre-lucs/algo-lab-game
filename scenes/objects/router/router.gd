class_name Router extends Node2D

signal sent_number(path: MovementLink, number: Number)

@onready var rotative: Node2D = %Rotative
@onready var numbers_container: Node2D = %Numbers
@onready var number_movement: NumberMovement = %NumberMovement
@onready var activatable: Activatable = $Traits/Activation

var number_queue: Array[Number] = []
## next_path index on number_movement.output_paths
var next_path: int = 0

func _ready() -> void:
	%Outline.scale = Vector2.ZERO
	%Outline.material.set_shader_parameter("color", Global.Colors["red"])

func enqueue_number(number:Number) -> void:
	number.move_to(Vector2.ZERO, numbers_container)
	number_queue.append(number)

	if number_queue.front() != number:
		number.hide()

func dequeue_number():
	if number_queue.is_empty():
		return
	var path := _get_path()
	if path == null:
		printerr("No path available to dequeue number.")
		return
	var number := number_queue.pop_front() as Number
	path.move_number(number)
	sent_number.emit(path, number)

	if not number_queue.is_empty() : _number_scale_animation(number_queue.front())
	_update_arrow(1)

func _update_arrow(increment: int = 0) -> void:
	if increment != 0:
		next_path += increment
	var path := _get_path()
	if path == null:
		return
	create_tween().tween_property(rotative, "rotation", global_position.angle_to_point(path.to_global(path.points[1])), 0.2)

func _get_path() -> MovementLink:
	var paths := number_movement.output_paths
	if paths.is_empty():
		return null
	if next_path >= paths.size():
		next_path = 0
	return paths[next_path]

func _number_scale_animation(number: Number) -> void:
	number.scale = Vector2.ZERO
	number.show()
	var anim = create_tween()
	anim.tween_property(number, "scale", Vector2.ONE, 0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	anim.play()


func _on_reset_requested() -> void:
	for number in number_queue:
		if number.is_inside_tree():
			number.queue_free()
	number_queue.clear()
	next_path = 0
	_update_arrow(0)
	

func _on_activation_success_activated() -> void:
	var t := create_tween()
	t.tween_property(%Outline, "scale", Vector2(1.2,1.2), 0.1).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	t.tween_interval(0.1)
	t.tween_property(%Outline, "scale", Vector2.ZERO, 0.2)
	t.play()
