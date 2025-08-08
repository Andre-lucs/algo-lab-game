extends Node

signal closed_alert(title: String)
signal finished_alert_queue

var current_alert : Control = null
var current_alert_parent : Node = null
var alert_tween : Tween
var alert_queue : Array[AlertProps] = []

func _ready() -> void:
	$AlertPanel.hide()	# Ensure the alert panel is hidden initially

func show_alert_from_props(alert_props: AlertProps, target_canvas_layer: Node = current_alert_parent) -> void:
	if current_alert:
		alert_queue.append(alert_props)
		return
	if alert_props.next_alert:
		alert_queue.append(alert_props.next_alert)
	
	%Title.text = alert_props.title
	%Content.text = alert_props.content
	if alert_props.custom_content:
		for c in %CustomContentContainer.get_children():
			c.free()
		%CustomContentContainer.add_child(alert_props.custom_content)
		alert_props.custom_content.show()
		%CustomContentContainer.show()
	else:
		%CustomContentContainer.hide()

	# Hide the content label to give more space to the custom content
	if alert_props.hide_content_label:
		%Content.hide()
	else:
		%Content.show()
	
	var alert_parent : Node = target_canvas_layer if target_canvas_layer else alert_props.canvas_layer
	if not alert_parent:
		alert_parent = get_tree().root  # Fallback to root if no canvas layer is specified

	var alert_instance = $AlertPanel.duplicate()
	alert_parent.add_child(alert_instance)
	current_alert_parent = alert_parent
	current_alert = alert_instance
	current_alert.show()
	var current_panel = current_alert.get_child(0)
	var current_background = current_alert
	current_panel.pivot_offset = current_panel.size/2
	current_panel.scale = Vector2(0.2, 0.2)
	current_background.modulate = Color.TRANSPARENT
	alert_tween = current_panel.create_tween().set_parallel()
	alert_tween.tween_property(current_panel, "scale", Vector2.ONE, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	alert_tween.tween_property(current_background, "modulate", Color.WHITE, 0.3)

func close_alert() -> void:
	if alert_tween and alert_tween.is_running():
		alert_tween.stop()
	
	var current_panel = current_alert.get_child(0)
	var current_background = current_alert
	current_panel.scale = Vector2.ONE
	alert_tween = current_panel.create_tween().set_parallel()
	alert_tween.tween_property(current_panel, "scale", Vector2(0.2,0.2), 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	alert_tween.tween_property(current_background, "modulate", Color.TRANSPARENT, 0.3)
	await alert_tween.finished
	if current_alert and current_alert.is_inside_tree():
		current_alert.queue_free()
		current_alert = null
	var title = %Title.text
	closed_alert.emit(title)

func _input(event: InputEvent) -> void:
	# clicked outside the alert panel
	if event is InputEventMouseButton and event.pressed and current_alert and not current_alert.get_child(0).get_child(0).get_rect().has_point(event.position):
		close_alert()
	

func _on_closed_alert(title:String) -> void:
	if alert_queue.is_empty():
		finished_alert_queue.emit()
		current_alert_parent = null
		return
	show_alert_from_props.call_deferred(alert_queue.pop_front())
