extends Link
class_name ActivatorLink

@export var origin : Activatable
@export var destination : Activatable

signal activated_destination(destination:Activatable)

var _connected_triggers : Array[String] = []
@onready var trigger_activate_callable : Callable = func(_a1=null,_a2=null,_a3=null,_a4=null,_a5=null,_a6=null,_a7=null,_a8=null,_a9=null,_a10=null): activate()

func _ready() -> void:
	super()
	assert(origin_connection != null, "Origin connection is null")
	assert(destination_connection != null, "Destination connection is null")
	if origin_connection.activatable == null or destination_connection.activatable == null:
		printerr("Origin or destination_node not set")
		delete()
		return
	
	_connect_origin(origin_connection)
	_connect_destination(destination_connection)

func activate() -> void:
	if destination:
		destination.activate()
		activated_destination.emit(destination)

func delete() -> void:
	_disconnect_origin()
	_disconnect_destination()
	queue_free()

func _on_start_connection_changed(new_origin_connection: ConnectionArea) -> void:
	_disconnect_origin()
	if new_origin_connection and new_origin_connection.activatable:
			_connect_origin(new_origin_connection)
	else:
			origin = null

func _on_end_connection_changed(new_destination_connection: ConnectionArea) -> void:
	_disconnect_destination()
	if new_destination_connection and new_destination_connection.activatable:
			_connect_destination(new_destination_connection)
	else:
			destination = null

func _connect_origin(connection: ConnectionArea) -> void:
	origin = connection.activatable
	if origin:
			var triggers = origin.get_trigger_signals()
			for trigger in triggers:
					if not origin.target.is_connected(trigger, trigger_activate_callable):
							origin.target.connect(trigger, trigger_activate_callable)
							_connected_triggers.append(trigger)

func _disconnect_origin() -> void:
	if origin and origin.target:
			for trigger in _connected_triggers:
					if origin.target.is_connected(trigger, trigger_activate_callable):
							origin.target.disconnect(trigger, trigger_activate_callable)
	_connected_triggers.clear()
	origin = null

func _connect_destination(connection: ConnectionArea) -> void:
	destination = connection.activatable

func _disconnect_destination() -> void:
	destination = null
