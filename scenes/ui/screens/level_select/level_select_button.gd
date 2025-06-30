extends Button

@export var level_props : LevelPropsResource:
	set(value):
		if value == null:
			return
		level_props = value
		%LevelTitle.text = value.level_name

@export var level_number : int:
	set(value):
		if value < 1:
			return
		level_number = value
		text = str(value)

var displaying_title = false

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and not displaying_title and (has_focus() or is_hovered()):
		$AnimationPlayer.play("show_title")
		displaying_title = true
	elif event is InputEventMouseMotion and displaying_title and not (has_focus() or is_hovered()):
		$AnimationPlayer.play_backwards("show_title")
		displaying_title = false
