extends Node

@onready var scene_transition := $SceneTransition

var _last_ui_scene : Node = null
var random_rotation : bool = false

func change_scene(scene: PackedScene, transition: bool = true, transition_angle : float = -1) -> void:
	change_scene_to_node(scene.instantiate(), transition, transition_angle)

func change_scene_to_node(scene: Node, transition: bool = true, transition_angle : float = -1) -> void:
	if not is_inside_tree():
		return
	if transition:
		if transition_angle != -1:
			scene_transition.rotation_degrees = transition_angle
		elif random_rotation:
			scene_transition.rotation_degrees = randf_range(0, 360)
		else:
			scene_transition.rotation_degrees = 0
		
		scene_transition.play()
		await scene_transition.finished
	
	_set_new_current_scene(scene)
	
	if transition:
		scene_transition.play_backwards()
		await scene_transition.finished

func go_to_last_ui_scene(play_transition : bool = true) -> void:
	if not _last_ui_scene:
		print("No last UI scene to return to.")
		return
	if not is_inside_tree():
		return
	
	if play_transition:
		scene_transition.play()
		await scene_transition.finished
	
	_set_new_current_scene(_last_ui_scene)

	scene_transition.play_backwards()
	await scene_transition.finished

func _set_new_current_scene(new_scene: Node) -> void:
	if not is_inside_tree():
		return
	var current_scene = get_tree().current_scene
	if current_scene is Control or current_scene is CanvasLayer:
		if _last_ui_scene and _last_ui_scene != current_scene:
			_last_ui_scene.queue_free()
		_last_ui_scene = current_scene
		get_tree().root.remove_child(current_scene)
	else:
		current_scene.queue_free()
	
	get_tree().root.add_child(new_scene)
	get_tree().current_scene = new_scene
