extends Control

@onready var level_select_screen : PackedScene = load("uid://ci8l4lwwvvbjw")

func _on_play_button_pressed() -> void:
	SceneManager.change_scene(level_select_screen)

func _on_play_test_pressed() -> void:
	LevelManager.load_test_level()
