extends Node2D
class_name NumberContainer

static var container_scene : PackedScene = preload("res://scenes/objects/container/container.tscn")
static var input_container_scene : PackedScene = preload("res://scenes/objects/container/input_container.tscn")

@export var default_numbers: Array[int] = []
@export var number_spacing: int = 40 # Spacing between numbers
@export var single_number_container: bool = false # If true, only one number can be stored

@onready var numbers : Node2D = $Numbers
@onready var walls : NinePatchRect = $Walls
@onready var animation : AnimationPlayer = $AnimationPlayer
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

static func get_input_container() -> NumberContainer:
	var container = input_container_scene.instantiate()
	return container

static func get_validator_container() -> ValidatorContainer:
	var container = ValidatorContainer.get_instance()
	return container

func _ready():
	if stored_numbers.is_empty() and !default_numbers.is_empty():
		_store_default_numbers()
	
	# # Set up the options
	# var ptexture := PlaceholderTexture2D.new()
	# ptexture.size = Vector2(32, 32)
	# menu.items = [
	# 	ObjectPopupMenuItem.new(
	# 		ptexture,
	# 		"Toggle Single Number Container",
	# 		_toggle_single_number_container
	# 	),
	# 	
	# ]

func _process(_delta: float) -> void:
	if grab.is_being_dragged():
		number_movement.update()
	if _needs_arrange:
		_needs_arrange = false
		_arrange_numbers()

# Number Management ----

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

## Gets the last number stored in the container and removes it from the list.
func get_last_number() -> Number:
	if stored_numbers.size() > 0:
		var num : Number = stored_numbers.pop_back()
		if num.get_parent() == numbers:
			num.get_parent().remove_child(num)
		_needs_arrange = true
		return num
	return null

func _clear_all_numbers():
	for number in $Numbers.get_children():
		if number is Number:
			number.queue_free()
	stored_numbers.clear()

# Number Arrangement ----

## Posiciona visualmente os números dentro do container.
func _arrange_numbers():
	# Calculate the total width of the numbers
	var total_width = (stored_numbers.size() * number_spacing)
	var half_width = total_width / 2.0

	# Arrange the numbers
	for i in range(stored_numbers.size()):
			var num : Number = stored_numbers[i]
			if not num.is_inside_tree():
					numbers.add_child(num)
			elif num.get_parent() != numbers:
					num.reparent(numbers)
			# Position each number relative to the center
			num.position = Vector2((i * number_spacing) - half_width+24, 0)

	# Adjust the walls and other elements to stay centered
	animate_resizing(total_width + 24)

var resize_tween : Tween
## Anima o redimensionamento visual do container com base na largura.
## @param new_width Nova largura visual.
## @param duration Duração da animação (em segundos).
func animate_resizing(new_width: float, duration: float = 0.2):
	if resize_tween and resize_tween.is_running():
		resize_tween.kill()
	resize_tween = create_tween()
	resize_tween.parallel().tween_property(walls, "size:x", new_width, duration)
	resize_tween.parallel().tween_property(walls, "position:x", -new_width / 2, duration)
	# resize_tween.parallel().tween_property(connection_area, "scale:x", new_width / 64, duration)
	resize_tween.play()

# Connection Area Callbacks ----

func _on_connection_area_requesting_highlight() -> void:
	animation.play("scale_animation")

# Movement Callbacks ----

func _on_number_movement_number_received(number:Number) -> void:
	store_number(number, true)

func _on_number_movement_requesting_move() -> void:
	if stored_numbers.is_empty():
		return
	number_movement.send(get_last_number())

# Popup Menu ----

func _on_object_popup_menu_clicked_option(idx: int) -> void:
	match idx:
		0:
			toggle_auto()
		1:
			delete()
		_:
			print("Unknown option clicked: ", idx)

func delete() -> void:
	print("Delete option pressed")
	# Implement delete logic here
	# For example, you could remove the container from its parent or free it
	queue_free()

# Toggles and Settings ----

func toggle_auto():
	activatable.auto = !activatable.auto

## Alterna entre armazenar apenas um número ou múltiplos.
func _toggle_single_number_container():
	single_number_container = !single_number_container
	if single_number_container:
		var number := (stored_numbers.front() as Number).duplicate()
		_clear_all_numbers()
		store_number(number, true)
