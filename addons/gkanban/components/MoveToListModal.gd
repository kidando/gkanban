tool
extends Control

signal list_menu_button_pressed(_list, _card)

export (NodePath) var list_menu_container_path:NodePath
onready var list_menu_container:VBoxContainer = get_node(list_menu_container_path)
export (NodePath) var list_dialog_path:NodePath
onready var list_dialog:VBoxContainer = get_node(list_dialog_path)

onready var menu_button_scene = preload("res://addons/gkanban/components/MenuListButton.tscn")

var selected = false

func _input(event):
	if event is InputEventMouseMotion:
		var _left_boundary = list_dialog.rect_global_position.x
		var _right_boundary = list_dialog.rect_global_position.x + list_dialog.rect_size.x
		var _top_boundary = list_dialog.rect_global_position.y
		var _bottom_boundary = list_dialog.rect_global_position.y + list_dialog.rect_size.y

		if event.position.x > _left_boundary and event.position.x < _right_boundary and event.position.y > _top_boundary and event.position.y < _bottom_boundary:
			selected = true
		else:
			selected = false

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !selected:
				queue_free()

func add_menu(_list, _card):
	var _menu_button = menu_button_scene.instance()
	list_menu_container.add_child(_menu_button)
	_menu_button.text = _list.list_name_label.text
	_menu_button.connect("pressed",self,"_on_MenuButton_pressed",[_list, _card],CONNECT_DEFERRED)
	
func _on_MenuButton_pressed(_list, _card):
	emit_signal("list_menu_button_pressed",_list, _card)
	queue_free()


func _on_PrimaryButton_pressed():
	queue_free()
