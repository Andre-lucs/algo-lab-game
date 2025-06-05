@tool
class_name Number extends Node2D

static var number_scene : PackedScene = preload("res://scenes/objects/number/number.tscn")

@export var editable: bool = true
@export var value: float = 0 : set = set_value

@onready var label: Label = $Label
@onready var editing_prompt : Control = %EditingPrompt
@onready var mouse_interaction_area: MouseInteractionArea2D = $MouseInteractionArea2D
@onready var mouse_col_shape = $MouseInteractionArea2D/CollisionShape2D

func _ready():
	update_label()
	mouse_col_shape.shape = RectangleShape2D.new()

func _draw() -> void:
	draw_rect(label.get_rect(), Color(1, 1, 1, 0.8))
	draw_rect(label.get_rect().grow(1.2), Color.BLACK, false, 5)
	if is_node_ready() : mouse_col_shape.shape.size = label.get_rect().grow(1.2).size

func _unhandled_input(event: InputEvent) -> void:
	_handle_editing_input(event)

func get_value() -> float:
	return value

func get_string() -> String:
	return str(value).replace(".0", "").replace(",0", "")

func set_value(new_value: float):
	value = roundf(new_value * 100) / 100.0  # Arredonda para duas casas decimais
	if is_inside_tree():
		update_label()

func update_label():
	label.text = get_string()  # Atualiza a exibição do número
	queue_redraw()

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
	number.editable = false # Numeros gerados pelo sistema nao sao editaveis
	return number

#region Number Editing

func _handle_editing_input(event: InputEvent) -> void:
	if not editable:
		return  # Se não for editável, não processa eventos de entrada
	
	if editing_prompt.visible and Input.is_action_just_released("edit_number_stop"):
		stop_editing()
		
	if not mouse_interaction_area.mouse_over:
		return  # Se o mouse não estiver sobre a área de interação, não processa eventos de entrada
	
	if Input.is_action_just_pressed("edit_number"):
		if event is InputEventMouseButton: # Verifica se o evento é um clique do mouse
			if event.double_click: # Se for um clique duplo, inicia a edição
				start_edit_value()
		else: # Se não for um clique do mouse, inicia a edição
			start_edit_value()
		

func start_edit_value() -> void:
	editing_prompt.text = get_string()
	editing_prompt.show()
	editing_prompt.grab_focus()
	
func stop_editing() -> void:
	if editing_prompt.visible:
		editing_prompt.release_focus()

func _on_editing_prompt_text_submitted(new_text:String) -> void:
	if not new_text.is_valid_float(): return

	var new_value = float(new_text)
	if new_value != value:
		set_value(new_value)
		update_label()
	editing_prompt.release_focus()

func _on_editing_prompt_focus_exited() -> void:
	editing_prompt.hide()

#endregion
