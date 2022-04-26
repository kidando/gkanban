tool
extends ColorRect

signal closed
signal project_board_added(_data)

export (NodePath) var project_board_name_input_path:NodePath
onready var project_board_name_input:LineEdit = get_node(project_board_name_input_path)

export (NodePath) var project_board_description_textarea_path:NodePath
onready var project_board_description_textarea:TextEdit = get_node(project_board_description_textarea_path)

export (NodePath) var alert_container_path:NodePath
onready var alert_container:MarginContainer = get_node(alert_container_path)

onready var alert_scene = preload("res://addons/gkanban/components/Alert.tscn")

var alert_visible = false

func _ready()->void:
	project_board_name_input.grab_focus()


func _on_CancelButton_pressed()->void:
	emit_signal("closed")
	queue_free()

func show_alert(_text: String, _variant: String="danger")->void:
	var _alert = alert_scene.instance()
	_alert.connect("closed",self,"_on_Alert_closed",[],CONNECT_DEFERRED)
	alert_container.add_child(_alert)
	_alert.start(_text, _variant)


func _on_AddButton_pressed()->void:
	var _name = project_board_name_input.text
	var _description = project_board_description_textarea.text

	if _name == "":
		if !alert_visible:
			show_alert("You must enter a project board name")
			alert_visible = true
		return

	var _project_board_data = {
		'name':_name,
		'description':_description
	}

	emit_signal("project_board_added",_project_board_data)
	emit_signal("closed")
	queue_free()
	

func _on_Alert_closed():
	alert_visible = false


