extends Node

var fullscreen: bool = false :
	set(value):
		var window_mode = DisplayServer.WINDOW_MODE_FULLSCREEN if value else DisplayServer.WINDOW_MODE_MAXIMIZED
		DisplayServer.window_set_mode(window_mode)
		fullscreen = value


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_fullscreen"):
		fullscreen = !fullscreen
