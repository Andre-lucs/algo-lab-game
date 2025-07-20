class_name AlertProps extends Resource

@export var title : String
@export_multiline var content : String
## The alert to show after this one is closed.
## If null, no alert will be shown next.
@export var next_alert : AlertProps = null

var custom_content : CanvasItem = null
var hide_content_label : bool = false
var canvas_layer : CanvasLayer = null

func _init(title: String = "", content: String = "", next_alert: AlertProps = null, canvas_layer: CanvasLayer = null) -> void:
	self.title = title
	self.content = content
	self.next_alert = next_alert
	self.canvas_layer = canvas_layer

static func new_custom(title: String, content: String, custom_content: CanvasItem, next_alert: AlertProps = null, hide_content_label: bool = false) -> AlertProps:
	var alert = AlertProps.new(title, content, next_alert)
	alert.custom_content = custom_content
	alert.hide_content_label = hide_content_label
	return alert