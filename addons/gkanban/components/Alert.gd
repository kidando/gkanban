tool
extends PanelContainer

signal closed

export (NodePath) var alert_label_path:NodePath
onready var alert_label:Label = get_node(alert_label_path)

func start(_text:String, _variant:String="danger")->void:
	alert_label.text = _text


func _on_CloseButton_pressed()->void:
	emit_signal("closed")
	queue_free()
