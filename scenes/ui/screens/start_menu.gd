extends Control

@export var initial_level : LevelPropsResource

func _on_play_test_pressed() -> void:
	LevelManager.load_test_level()


func _on_play_button_pressed() -> void:
	LevelManager.load_level(initial_level)
