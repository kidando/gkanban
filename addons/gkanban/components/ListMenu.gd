tool
extends Control

signal move_list_pressed(_list, _direction)
signal delete_list_pressed(_list)


var selected: bool = false

var list = null

func _input(event):
	if event is InputEventMouseMotion:
		var _left_boundary = $BG.rect_global_position.x
		var _right_boundary = $BG.rect_global_position.x + $BG.rect_size.x
		var _top_boundary = $BG.rect_global_position.y
		var _bottom_boundary = $BG.rect_global_position.y + $BG.rect_size.y

		if event.position.x > _left_boundary and event.position.x < _right_boundary and event.position.y > _top_boundary and event.position.y < _bottom_boundary:
			selected = true
		else:
			selected = false

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !selected:
				
				queue_free()


func _on_MoveToFirstButton_pressed():
	emit_signal("move_list_pressed",list,"first")

func set_list(_list):
	list = _list

func _on_MoveLeftButton_pressed():
	emit_signal("move_list_pressed",list,"left")


func _on_MoveRightButton_pressed():
	emit_signal("move_list_pressed",list,"right")


func _on_Delete_pressed():
	emit_signal("delete_list_pressed",list)


func _on_MoveToLast_pressed():
	emit_signal("move_list_pressed",list,"last")


func _on_CloseButton_pressed():
	queue_free()
