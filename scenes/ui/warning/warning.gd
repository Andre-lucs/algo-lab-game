extends PanelContainer

var tween: Tween

@export_multiline var message : String:
	set(value):
		message = value
		if not is_inside_tree():
			await tree_entered
		%WarningMessageLabel.text = message
		_update_sizing()
		
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	hide()
	_update_sizing()

func _update_sizing():	
	size = Vector2.ZERO # Set size to zero so the engine makes it fit the contents
	pivot_offset = size/2

func popup(new_message: String, new_position : Vector2 = Vector2(-1,-1)) -> void:
	message = new_message
	if new_position == Vector2(-1, -1):
		new_position = get_viewport().get_camera_2d().get_screen_center_position()
	position = new_position - size /2
	
	if tween and tween.is_running():
		tween.kill()
	tween = create_tween()
	scale = Vector2.ZERO
	show()
	tween.parallel().tween_property(self, "scale", Vector2.ONE, .3).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(self, "modulate", Color.DARK_ORANGE, .2)
	tween.tween_property(self, "modulate", Color.WHITE, .3)
	

func _input(event: InputEvent) -> void:
	if not visible : return
	if Input.is_action_just_pressed("base_accept"):
		hide()
