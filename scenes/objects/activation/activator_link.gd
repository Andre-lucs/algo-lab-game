extends Link
class_name ActivatorLink

@export var origin : Activatable
@export var destination : Activatable

signal activated_destination(destination:Activatable)

func _ready() -> void:
	super()
	assert(origin_connection != null, "Origin connection is null")
	assert(destination_connection != null, "Destination connection is null")
	if origin_connection.activatable == null or destination_connection.activatable == null:
		printerr("Origin or destination_node not set")
		delete()
		return

	origin = origin_connection.activatable
	destination = destination_connection.activatable

	# Connect the trigger_signals
	var triggers = origin.get_trigger_signals()

	for trigger in triggers:
		origin.target.connect(trigger, func(_arg0 = null, _arg1 = null,_arg2 = null,_arg3 = null,_arg4 = null): activate())
	
func activate() -> void:
	destination.activate()
	activated_destination.emit(destination)

func _on_object_popup_menu_clicked_option(idx:int) -> void:
	match idx:
		0:
			delete()
		_:
			print("Unknown option clicked")

func delete() -> void:
	queue_free()
