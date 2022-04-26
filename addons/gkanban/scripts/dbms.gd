extends Node

const SAVE_DIR = "res://.gkanban/"
var settings_path = SAVE_DIR+"settings.dat"
var settings_options = null

var projects_path = SAVE_DIR+"project_boards.dat"
var project_boards = []

func save_settings(_data):
	var dir = Directory.new()
	if !dir.dir_exists(SAVE_DIR):
		dir.make_dir_recursive(SAVE_DIR)
		
	var file = File.new()
	var error = file.open(settings_path, File.WRITE)
	if error == OK:
		file.store_var(_data)
		file.close()

func load_settings():
	var file = File.new()
	if file.file_exists(settings_path):
		var error = file.open(settings_path, File.READ)
		if error == OK:
			settings_options = file.get_var()
			file.close()
	else:
		settings_options = initialize_settings()
		save_settings(settings_options)
	
# Load project_boards data file
func get_project_boards():
	return project_boards

func load_projects():
	var file = File.new()
	if file.file_exists(projects_path):
		var error = file.open(projects_path, File.READ)
		if error == OK:
			project_boards = file.get_var()
			file.close()
	else:
		project_boards = initialize_projects()
		save_project_boards(project_boards)

func delete_project(_project_board):
	var i = 0
	for project in project_boards:
		if project.id == _project_board.id:
			project_boards.remove(i)
			break
		i += 1
	save_project_boards(project_boards)

func update_card(_project_board, _list, _card):
	for project_board in project_boards:
		if project_board.id == _project_board.project_board.id:
			for list in project_board.lists:
				if list.id == _list.list.id:
					for card in list.cards:
						if card.id == _card.card.id:
							card.title = _card.card.title
							card.color = _card.card.color
							break
					break
			break
	save_project_boards(project_boards)

func add_card_to_list(_project_board, _list, _card):
	for project_board in project_boards:
		if project_board.id == _project_board.project_board.id:
			for list in project_board.lists:
				if list.id == _list.list.id:
					var _new_card = {
						'id': get_datetime_as_id(),
						"title":_card.card.title,
						"color":_card.card.color
					}
					list.cards.append(_new_card)
					break
			break
	save_project_boards(project_boards)

func add_moved_card_to_list(_project_board, _list, _card):
	for project_board in project_boards:
		if project_board.id == _project_board.project_board.id:
			for list in project_board.lists:
				if list.id == _list.list.id:
					var _new_card = {
						'id': _card.card.id,
						"title":_card.card.title,
						"color":_card.card.color
					}
					list.cards.push_front(_new_card)
					break
			break
	save_project_boards(project_boards)

func save_project_boards(_data):
	var file = File.new()
	var error = file.open(projects_path, File.WRITE)
	if error == OK:
		file.store_var(_data)
		file.close()

func get_datetime_as_id():
	var _date_time = OS.get_datetime()
	return str(_date_time.year,_date_time.month,_date_time.day,_date_time.weekday,_date_time.hour,_date_time.minute,_date_time.second)

func update_list(_project_board, _list):
	for project_board in project_boards:
		if project_board.id == _project_board.project_board.id:
			for list in project_board.lists:
				if list.id == _list.list.id:
					list.name == _list.list.name
					list.cards = _list.list.cards
					break
			break
	save_project_boards(project_boards)

func update_project_board(_project_board):
	for project_board in project_boards:
		if project_board.id == _project_board.project_board.id:
			project_board.name = _project_board.project_board.name
			project_board.description = _project_board.project_board.description
			project_board.lists = _project_board.project_board.lists
			break;
	save_project_boards(project_boards)

func add_project_board(_project_board):
	var _new_project: Dictionary = {}
	var _date_time = OS.get_datetime()
	var _created_at = str(_date_time.year,"-",_date_time.month,"-",_date_time.day," ",_date_time.hour,":",_date_time.minute,":",_date_time.second)
	var _updated_at = str(_date_time.year,"-",_date_time.month,"-",_date_time.day," ",_date_time.hour,":",_date_time.minute,":",_date_time.second)
	_new_project = {
		'id': get_datetime_as_id(),
		'name':_project_board.name,
		'description':_project_board.description,
		'created_at':_created_at,
		'updated_at':_updated_at,
		'lists':[]
	}
	project_boards.append(_new_project)
	save_project_boards(project_boards)
	return project_boards

func add_list_to_project_board(_project_board, _list_data):
	for project_board in project_boards:
		if project_board.id == _project_board.project_board.id:
			var _new_list = {
				'id': get_datetime_as_id(),
				'name':_list_data.name,
				'cards':[]
			}
			project_board.lists.append(_new_list)
			break
	save_project_boards(project_boards)

func initialize_settings()->Dictionary:
	return {
		"theme":"Kidash Mellow"
	}
func initialize_projects()->Array:
	return []
