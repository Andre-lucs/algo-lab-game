class_name NameTag extends Node2D

static var nametag_scene : PackedScene = preload("res://scenes/objects/name_tag/name_tag.tscn")


@onready var label: Label = $Label
@onready var editing_prompt : Control = %EditingPrompt
@onready var mouse_interaction_area: MouseInteractionArea2D = $MouseInteractionArea2D
@onready var mouse_col_shape = $MouseInteractionArea2D/CollisionShape2D

func _ready():
	mouse_col_shape.shape = RectangleShape2D.new()
	# Initialize the label being empty
	# If the initial text is not "asd" keep the current text
	update_label("" if label.text == "asd" else label.text)
	

func _input(event: InputEvent) -> void:
	_handle_editing_input(event)

func update_label(new_text: String = "") -> void:
	var changed_text = label.text != new_text
	label.text = new_text
	if changed_text:
		queue_redraw()
		await label.resized
	(mouse_col_shape.shape as RectangleShape2D).size = label.size


static func instance() -> NameTag:
	var number = nametag_scene.instantiate() as NameTag
	return number

func _handle_editing_input(event: InputEvent) -> void:
	
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
	editing_prompt.text = label.text
	editing_prompt.show()
	editing_prompt.grab_focus()
	
func stop_editing() -> void:
	if editing_prompt.visible:
		editing_prompt.release_focus()

func _on_editing_prompt_text_submitted(new_text:String) -> void:
	update_label(new_text)
	editing_prompt.release_focus()

func _on_editing_prompt_focus_exited() -> void:
	editing_prompt.hide()

func delete() -> void:
	queue_free()