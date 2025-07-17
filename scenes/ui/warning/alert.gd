extends Node

signal closed_alert

var current_alert : Control = null
var alert_tween : Tween

func _ready() -> void:
	$AlertPanel.hide()	# Ensure the alert panel is hidden initially

func show_alert(title : String, content: String, target_canvas_layer : CanvasLayer, custom_content : CanvasItem = null, hide_content_label:= false) -> void:
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
	closed_alert.emit()

func _input(event: InputEvent) -> void:
	# clicked outside the alert panel
	if event is InputEventMouseButton and event.pressed and current_alert and not current_alert.get_child(0).get_child(0).get_rect().has_point(event.position):
		close_alert()
