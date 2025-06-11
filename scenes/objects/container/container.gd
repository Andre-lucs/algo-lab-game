extends Node2D
class_name NumberContainer

const NumberSlot = preload("res://scenes/objects/container/number_slot.gd")

static var container_scene : PackedScene = preload("res://scenes/objects/container/container.tscn")

@export var default_numbers: Array[float] = []
@export var single_number_container: bool = false # If true, only one number can be stored

@onready var front_slot : NumberSlot = %FrontNumberSlot
@onready var back_slot : NumberSlot = %BackNumberSlot

@onready var grab : Grabbable = $Grabbable
@onready var connection_area : ConnectionArea = $ConnectionArea
@onready var activatable : Activatable = $Activatable
@onready var number_movement : NumberMovement = $NumberMovement
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu

var stored_numbers : Array[Number] = []
var _needs_arrange : bool = false

static func get_instance() -> NumberContainer:
	var container = container_scene.instantiate()
	return container

func _ready():
	if stored_numbers.is_empty() and !default_numbers.is_empty():
		_store_default_numbers()

func _process(_delta: float) -> void:
	if grab.is_being_dragged():
		number_movement.update()
	if _needs_arrange:
		_arrange_numbers()

#region Number Management

## Armazena um número e o adiciona visualmente ao container.
## @param number O número a ser armazenado.
## @param update_arrange Se verdadeiro, reordena os números armazenados.
func store_number(number: Number, update_arrange: bool = false):
	if single_number_container and not stored_numbers.is_empty():
		_clear_all_numbers()
	# stored_numbers.append(number)
	stored_numbers.push_front(number)
	if update_arrange:
		_needs_arrange = true

## Armazena vários números de uma vez.
## @param new_numbers Lista de instâncias Number a serem armazenadas.
func store_multiple_numbers(new_numbers: Array[Number]):
	for number in new_numbers:
		store_number(number, true)

func _store_default_numbers():
	# If single_number_container is true, we only store one number
	if single_number_container and not default_numbers.is_empty():
		var number = Number.get_number(default_numbers.front())
		store_number(number,true)
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
	store_number(number, true)
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

## Gets the last number stored in the container and removes it from the list.
func get_last_number(copy := false) -> Number:
	if stored_numbers.size() > 0:
		var num : Number
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

func _on_number_movement_number_received(number:Number) -> void:
	store_number(number, true)

func _on_number_movement_requesting_move(send_back_number: Callable) -> void:
	if stored_numbers.is_empty():
		return
	send_back_number.call(get_last_number()) # Send the last number

func _on_number_movement_requesting_copy(send_back_number:Callable) -> void:
	if stored_numbers.is_empty():
		return
	send_back_number.call(get_last_number(true)) # Send a copy of the last number

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
		store_number(number, true)
		update_default_numbers_to_current()

func _on_reset_requested() -> void:
	_needs_arrange = false
	for num in stored_numbers:
		if num.is_inside_tree():
			num.queue_free()
	stored_numbers.clear()
	_store_default_numbers()


func _on_menu_clicked_item(_item:ObjectPopupMenuItem, idx:int) -> void:
	match idx:
		0:
			_toggle_single_number_container()

#endregion
