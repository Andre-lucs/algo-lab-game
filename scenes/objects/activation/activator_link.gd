extends Path2D
class_name ActivatorLink

@export var origin : Activatable
@export var destination : Activatable
@export var origin_point : Vector2
@export var destination_point : Vector2

@onready var line : ClickableLine2D = $ClickableLine2D
@onready var menu : ObjectPopupMenu = $ObjectPopupMenu
@onready var plug : Node2D = $Plug

signal activated_destination(destination:Activatable)

func _ready() -> void:
	if origin == null or destination == null:
		print("Origin or destination not set")
		return
	
	line.add_point(origin_point)
	line.add_point(destination_point)
	plug.position = destination_point
	plug.rotation = (destination_point - origin_point).angle()

	# Connect the trigger_signals
	var triggers = origin.get_trigger_signals()

	for trigger in triggers:
		origin.target.connect(trigger, activate)
	

func activate(_arg0 = null, _arg1 = null,_arg2 = null,_arg3 = null,_arg4 = null) -> void:
	destination.activate()
	activated_destination.emit(destination)

func _on_clickable_line_2d_clicked(_event : InputEventMouseButton, _global_position:Vector2, _segment:int, _offset:float) -> void:
	if _event.is_action_pressed("object_menu"):
		menu.show_popup()

func _on_object_popup_menu_clicked_option(idx:int) -> void:
	match idx:
		0:
			delete()
		_:
			print("Unknown option clicked")

func delete() -> void:
	queue_free()

func _exit_tree() -> void:
	# Disconnect the trigger_signals
	var triggers = origin.get_trigger_signals()

	for trigger in triggers:
		origin.target.disconnect(trigger, activate)
