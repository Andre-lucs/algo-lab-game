extends Node

var test_level : PackedScene = preload("res://levels/test_level.tscn")

var layouts := [
]

func get_random_layout() -> PackedScene:
	return layouts.pick_random()

func load_test_level():
	get_tree().change_scene_to_packed(test_level)
	
func load_level(level: LevelPropsResource):
	if level == null:
		print("LevelPropsResource is not set.")
		load_test_level()
		return
	var layout = level.custom_layout if level.custom_layout else get_random_layout()
	if layout:
		var layout_instance = layout.instantiate()
		layout_instance.set("level_props", level)
		print("Layout instance: ", layout_instance)
		print(level)
		get_tree().root.add_child(layout_instance)
		get_tree().current_scene.queue_free()
		get_tree().current_scene = layout_instance

		
	else:
		print("No layout defined, using default layout.")
		get_tree().change_scene_to_packed(test_level)

func load_level_number(level: int):
	var level_props = load("res://levels/level_data/level_%d.tres" % level)
	if level_props is LevelPropsResource:
		load_level(level_props)
	else:
		print("LevelPropsResource not found, loading test level.")
		load_test_level()
		return
