extends Node2D
class_name NumberContainer

const NumberSlot = preload("res://scenes/objects/container/number_slot.gd")

enum ConnectionSide {
	FRONT,
	BACK
}

static var container_scene : PackedScene = preload("res://scenes/objects/container/container.tscn")

signal sent_number(number: Number, side: ConnectionSide)
signal became_empty

@export var default_numbers: Array[float] = []
@export var single_number_container: bool = false # If true, only one number can be stored

@onready var front_slot : NumberSlot = %FrontNumberSlot
@onready var back_slot : NumberSlot = %BackNumberSlot

@onready var grab : Grabbable = $Grabbable
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu
@onready var highlightable : Highlightable = $Highlightable

var stored_numbers : Array[Number] = []
var _needs_arrange : bool = false

static func get_instance() -> NumberContainer:
	var container = container_scene.instantiate()
	return container

func _ready():
	if stored_numbers.is_empty() and !default_numbers.is_empty():
		_store_default_numbers()
	if highlightable:
		became_empty.connect(highlightable.play_outline_animation)

func _process(_delta: float) -> void:
	if _needs_arrange:
		_arrange_numbers()

#region Number Management

func store_number_in_side(number : Number, side: ConnectionSide):
	if single_number_container and not stored_numbers.is_empty():
		_clear_all_numbers()
	
	match side:
		ConnectionSide.FRONT:
			stored_numbers.push_front(number)
		ConnectionSide.BACK:
			stored_numbers.push_back(number)
	_needs_arrange = true

func store_number(number: Number):
	store_number_in_side(number, ConnectionSide.FRONT)

func store_multiple_numbers(new_numbers: Array[Number]):
	for number in new_numbers:
		store_number(number)

func _store_default_numbers():
	# If single_number_container is true, we only store one number
	if single_number_container and not default_numbers.is_empty():
		var number = Number.get_number(default_numbers.front())
		store_number(number)
		return
	
	var default_numbers_insntances :Array[Number] = [] 
	for n in default_numbers:
		default_numbers_insntances.append(Number.get_number(n))
	store_multiple_numbers(default_numbers_insntances)	

func add_default_number(number:Number):
	if number in stored_numbers:
		prints("Number already stored, not adding again.")
		return
	number.editable = false
	store_number(number)
	update_default_numbers_to_current()

func remove_default_number(number:Number):
	if number in stored_numbers:
		stored_numbers.erase(number)
		number.reparent.call_deferred(get_tree().current_scene)
		number.editable = true
		_needs_arrange = true
		update_default_numbers_to_current()
	else:
		prints("Number not found in stored numbers, cannot remove.")

func update_default_numbers_to_current():
	var new_numbers : Array[float] = []
	for n in stored_numbers:
		if n is Number:
			new_numbers.push_front(n.get_value()) # using push_front to maintain order
		else:
			prints("Stored item is not a Number instance, skipping.")
	default_numbers = new_numbers

func get_number_from_side(side: ConnectionSide, copy := false) -> Number:
	if stored_numbers.size() > 0:
		var num : Number
		match side:
			ConnectionSide.FRONT:
				if not copy:
					num = stored_numbers.pop_front()
					front_slot.number = null
				else:
					num = stored_numbers.front().duplicate()
			ConnectionSide.BACK:
				if not copy:
					num = stored_numbers.pop_back()
					back_slot.number = null
				else:
					num = stored_numbers.back().duplicate()
		_needs_arrange = true
		return num
	return null

func _clear_all_numbers():
	for number in stored_numbers:
		number.queue_free()
	stored_numbers.clear()
	front_slot.number = null
	back_slot.number = null
#endregion

# Number Arrangement ----

## Posiciona visualmente os números dentro do container.
func _arrange_numbers():
	_needs_arrange = false

	match stored_numbers.size():
		0:
			_set_slot_numbers(true)
		1:
			_set_slot_numbers(true)
			var number = stored_numbers.front()
			number.move_to(Vector2.ZERO, self)
		2:
			_set_slot_numbers()
		3:
			_set_slot_numbers()
			var middle_number = stored_numbers[1]
			middle_number.move_to(Vector2.ZERO, self)
		_:
			_set_slot_numbers()
			var middle_numbers = stored_numbers.slice(1, -1)
			for n in middle_numbers:
				n.move_to(Vector2.ZERO, self)
				n.hide()
			var float_numbers :Array[float] = []
			for n in middle_numbers:
				float_numbers.append(n.get_value())
			%NumberListing.numbers = float_numbers
			%NumberListing.update_display()
			%SeeMoreLabel.show()
	# Using an if to avoid repeating the hide/show logic
	if stored_numbers.size() <= 3:
		%SeeMoreLabel.hide()
		for n in stored_numbers:
			n.show()
		

func _set_slot_numbers(nullify_slots := false):
	if nullify_slots:
		front_slot.number = null
		back_slot.number = null
		return
	front_slot.number = stored_numbers.front()
	back_slot.number = stored_numbers.back()

#region Callbacks

func request_movement(send_back_number: Callable, side : ConnectionSide) -> void:
	if stored_numbers.is_empty():
		return
	send_back_number.call(get_number_from_side(side, false))
	if stored_numbers.is_empty():
		became_empty.emit()

func request_copy(send_back_number:Callable, side : ConnectionSide) -> void:
	if stored_numbers.is_empty():
		return
	send_back_number.call(get_number_from_side(side, true))

func delete() -> void:
	print("Delete option pressed")
	# Implement delete logic here
	# For example, you could remove the container from its parent or free it
	queue_free()

## Alterna entre armazenar apenas um número ou múltiplos.
func _toggle_single_number_container():
	single_number_container = !single_number_container
	if single_number_container:
		var number := (stored_numbers.front() as Number).duplicate()
		_clear_all_numbers()
		store_number(number)
		update_default_numbers_to_current()

func _on_reset_requested() -> void:
	for num in stored_numbers:
		if num.is_inside_tree():
			num.queue_free()
	stored_numbers.clear()
	_needs_arrange = true
	_store_default_numbers()


func _on_menu_clicked_item(_item:DefaultMenuItem, idx:int) -> void:
	match idx:
		0:
			_toggle_single_number_container()

#endregion
