tool
extends Control

signal project_board_deleted(_project_board_deleted)

var project_board = null

func set_project_board(_project_board):
	project_board = _project_board
	$ColorRect/CenterContainer/VBoxContainer/PanelContainer/Label.text = str("Are you sure you want to delete the project board: ",project_board.name,"?")

func _on_CancelButton_pressed():
	queue_free()


func _on_DeleteButton_pressed():
	emit_signal("project_board_deleted",project_board)
	queue_free()
