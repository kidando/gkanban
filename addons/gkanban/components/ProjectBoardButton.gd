tool
extends Button

signal project_board_selected(_project)

var project_board: Dictionary = {}

func set_project_board(_project_board: Dictionary):
	project_board = _project_board
	text = project_board.name


func _on_ProjectBoardButton_pressed():
	emit_signal("project_board_selected",project_board)
