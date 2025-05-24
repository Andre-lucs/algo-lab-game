extends Control


func _on_play_test_pressed() -> void:
	LevelManager.load_test_level()


func _on_play_button_pressed() -> void:
	LevelManager.load_level_number(1) # will fall back to test level if no level is set
