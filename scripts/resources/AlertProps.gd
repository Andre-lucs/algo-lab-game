class_name AlertProps extends Resource

@export var title : String
@export_multiline var content : String
@export var hide_content_label : bool = false
## The alert to show after this one is closed.
## If null, no alert will be shown next.
@export var next_alert : AlertProps = null

## Custom content is not passed from the resource, but can be set in the alert script.