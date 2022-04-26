tool
extends Control

var dbms = preload("res://addons/gkanban/scripts/dbms.gd").new()

var pages = [
	{
		"name": "Start Page",
		"scene": preload("res://addons/gkanban/pages/StartPage.tscn")
	},
	{
		"name": "Project Board",
		"scene": preload("res://addons/gkanban/pages/ProjectBoard.tscn")
	}
]

func _ready():
	dbms.load_settings()
	dbms.load_projects()
	load_start_page()

func load_start_page():
	var start_page = pages[0].scene.instance()
	start_page.connect("project_board_added",self,"_on_StartPage_project_board_added",[],CONNECT_DEFERRED)
	start_page.connect("project_board_selected",self,"_on_StartPage_project_board_selected",[],CONNECT_DEFERRED)
	add_child(start_page)
	start_page.set_app_theme(dbms.settings_options.theme)
	start_page.set_project_boards(dbms.project_boards)

func reload_project_board(_project_board):
	var _project_boards = dbms.get_project_boards()
	var _active_project_board = {}
	for _single_project_board in _project_boards:
		if _single_project_board.id == _project_board.project_board.id:
			_active_project_board = _single_project_board
			break	
	load_project_board(_active_project_board)
	_project_board.queue_free()


func load_project_board(_project_board):
	
	var project_board = pages[1].scene.instance()
	project_board.connect("closed",self,"_on_Project_board_closed",[],CONNECT_DEFERRED)
	project_board.connect("updated",self,"_on_Project_board_updated",[],CONNECT_DEFERRED)
	project_board.connect("deleted",self,"_on_Project_board_deleted",[],CONNECT_DEFERRED)
	project_board.connect("list_created",self,"_on_Project_board_list_created",[],CONNECT_DEFERRED)
	project_board.connect("list_updated",self,"_on_Project_board_list_updated",[],CONNECT_DEFERRED)
	project_board.connect("card_created",self,"_on_Project_board_card_created",[],CONNECT_DEFERRED)
	project_board.connect("card_updated",self,"_on_Project_board_card_updated",[],CONNECT_DEFERRED)
	project_board.set_app_theme(dbms.settings_options.theme)
	add_child(project_board)
	project_board.set_project_board(_project_board)

func _on_Project_board_card_updated(_project_board, _list, _card):
	dbms.update_card(_project_board, _list, _card)

func _on_Project_board_card_created(_project_board, _list, _card):
	dbms.add_card_to_list(_project_board, _list, _card)
	reload_project_board(_project_board)

func _on_Project_board_list_updated(_project_board, _list):
	dbms.update_list(_project_board, _list)

func _on_Project_board_updated(_project_board):
	dbms.update_project_board(_project_board)

func _on_Project_board_list_created(_project_board, _list_data):
	dbms.add_list_to_project_board(_project_board, _list_data)
	reload_project_board(_project_board)


func _on_StartPage_project_board_added(_project_board_data)->void:
	var _projects = dbms.add_project_board(_project_board_data)

	for page in get_children():
		page.set_project_boards(_projects)

func _on_StartPage_project_board_selected(_project_board):
	load_project_board(_project_board)

func _on_Project_board_deleted(_project_board):
	dbms.delete_project(_project_board)
	dbms.load_projects()
	load_start_page()

func _on_Project_board_closed():
	load_start_page()
