extends Node

signal closed_alert(title: String)

var current_alert : Control = null
var alert_tween : Tween

func _ready() -> void:
	$AlertPanel.hide()	# Ensure the alert panel is hidden initially

func show_alert(title : String, content: String, target_canvas_layer : CanvasLayer, custom_content : CanvasItem = null, hide_content_label:= false, next_alert : AlertProps = null) -> void:
	if current_alert:
		printerr("Cannot show more than one alert at a time.")
		return
	%Title.text = title
	%Content.text = content
	if custom_content:
		for c in %CustomContentContainer.get_children():
			c.queue_free()  # Clear previous custom content
		%CustomContentContainer.add_child(custom_content)
		custom_content.show()
		%CustomContentContainer.show()
	else:
		%CustomContentContainer.hide()

	# Hide the content label to give more space to the custom content
	if hide_content_label:
		%Content.hide()
	else:
		%Content.show()
	
	var alert_instance = $AlertPanel.duplicate()
	target_canvas_layer.add_child(alert_instance)
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

	if next_alert:
		await closed_alert
		show_alert_from_props.call_deferred(next_alert, target_canvas_layer, custom_content)

func show_alert_from_props(alert_props: AlertProps, target_canvas_layer: CanvasLayer, custom_content: CanvasItem = null) -> void:
	show_alert(alert_props.title, alert_props.content, target_canvas_layer, custom_content, alert_props.hide_content_label, alert_props.next_alert)

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
