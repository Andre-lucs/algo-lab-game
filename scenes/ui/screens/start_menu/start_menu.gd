extends Control

@onready var level_select_screen : PackedScene = load("uid://ci8l4lwwvvbjw")

func _ready() -> void:
	if OS.has_feature("editor"):
		%TestButton.visible = true
	else:
		%TestButton.visible = false
	%PlayButton.grab_focus.call_deferred()

func _on_play_button_pressed() -> void:
	SceneManager.change_scene(level_select_screen)

func _on_play_test_pressed() -> void:
	LevelManager.load_test_level()

func _on_exit_button_pressed() -> void:
	get_tree().quit()

func _input(event: InputEvent) -> void:
	if not OS.has_feature("editor"): return

	if Input.is_action_just_pressed("debug_complete_all"):
		LevelSaving.complete_every_level()
		return
	if Input.is_action_just_pressed("debug_erase_level_save"):
		LevelSaving.erase_save_data()
		return