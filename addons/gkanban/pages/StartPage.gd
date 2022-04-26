tool
extends Control

signal project_board_added(_data)
signal project_board_selected(_project_board)

var theme_manager = preload("res://addons/gkanban/scripts/theme_manager.gd").new()
var theme_name = null

var project_boards: Array = []

onready var modal_container = $ModalContainer
var add_project_board_modal_exists: bool = false

export (NodePath) var project_board_container_path:NodePath
onready var project_board_container:VBoxContainer = get_node(project_board_container_path)

var add_project_board_modal_scene = preload("res://addons/gkanban/components/AddProjectBoardModal.tscn")
var project_board_button_scene = preload("res://addons/gkanban/components/ProjectBoardButton.tscn")

func set_app_theme(_theme_name: String)->void:
	theme_name = _theme_name
	for theme in theme_manager.themes:
		if theme_name == theme.name:
			$BG.get("custom_styles/panel").bg_color = theme.colors.pages.start_page.bg
			break

func set_project_boards(_project_boards:Array)->void:
	project_boards = _project_boards
	load_project_boards()

func load_project_boards()->void:
	for project_board in project_board_container.get_children():
		project_board.queue_free()

	for project_board in project_boards:
		var _project_board_button = project_board_button_scene.instance()
		_project_board_button.set_project_board(project_board)
		_project_board_button.connect("project_board_selected",self,"_on_Project_board_button_project_board_selected",[],CONNECT_DEFERRED)
		project_board_container.add_child(_project_board_button)

	

func _on_AddProjectBoardBtn_pressed()->void:
	if !add_project_board_modal_exists:
		var _add_project_board_modal = add_project_board_modal_scene.instance()
		_add_project_board_modal.connect("closed",self,"_on_AddProjectBoardModal_closed",[],CONNECT_DEFERRED)
		_add_project_board_modal.connect("project_board_added",self,"_on_AddProjectBoardModal_project_board_added",[],CONNECT_DEFERRED)
		modal_container.add_child(_add_project_board_modal)
		add_project_board_modal_exists = true
		
		
func _on_AddProjectBoardModal_closed()->void:
	add_project_board_modal_exists = false

func _on_AddProjectBoardModal_project_board_added(_project_board_data)->void:
	emit_signal("project_board_added",_project_board_data)

func _on_Project_board_button_project_board_selected(_project_board):
	emit_signal("project_board_selected",_project_board)
	queue_free()
