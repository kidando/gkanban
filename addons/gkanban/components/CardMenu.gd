tool
extends Control

signal move_card_pressed(_list, _card, _direction)
signal delete_card_pressed(_list, _card)

var list = null
var card = null

var selected = false

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

func setup_list_card(_list, _card):
	list = _list
	card = _card



func _on_MoveToTopButton_pressed():
	emit_signal("move_card_pressed",list,card,"top")


func _on_MoveUpButton_pressed():
	emit_signal("move_card_pressed",list,card,"up")


func _on_MoveToBottomButton_pressed():
	emit_signal("move_card_pressed",list,card,"bottom")


func _on_MoveToListButton_pressed():
	emit_signal("move_card_pressed",list,card,"list")


func _on_DeleteCardButton_pressed():
	emit_signal("delete_card_pressed",list,card)


func _on_MoveDownButton_pressed():
	emit_signal("move_card_pressed",list,card,"down")



func _on_CloseButton_pressed():
	queue_free()
