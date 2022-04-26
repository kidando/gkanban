tool
extends Control

signal closed
signal deleted(_project_board)
signal updated(_project_board)
signal list_created(_project_data,_list_data)
signal list_updated(_project_data,_list_data)
signal card_created(_project_board,_list,_card)
signal card_updated(_project_board,_list,_card)


var theme_manager = preload("res://addons/gkanban/scripts/theme_manager.gd").new()
var theme_name = null



export (NodePath) var project_board_name_label_path:NodePath
onready var project_board_name_label:Label = get_node(project_board_name_label_path)

export (NodePath) var list_container_path:NodePath
onready var list_container:HBoxContainer = get_node(list_container_path)

export (NodePath) var menu_container_path:NodePath
onready var menu_container:Control = get_node(menu_container_path)

export (NodePath) var project_board_name_and_edit_container_path:NodePath
onready var project_board_name_and_edit_container:MarginContainer = get_node(project_board_name_and_edit_container_path)

export (NodePath) var project_board_name_path:NodePath
onready var project_board_name:Label = get_node(project_board_name_path)

export (NodePath) var project_board_name_edit_path:NodePath
onready var project_board_name_edit:LineEdit = get_node(project_board_name_edit_path)


onready var list_scene = preload('res://addons/gkanban/components/List.tscn')
onready var card_scene = preload("res://addons/gkanban/components/Card.tscn")

onready var list_menu_scene = preload("res://addons/gkanban/components/ListMenu.tscn")
onready var card_menu_scene = preload("res://addons/gkanban/components/CardMenu.tscn")
onready var move_to_list_modal_scene = preload("res://addons/gkanban/components/MoveToListModal.tscn")
onready var confirm_project_board_delete_scene = preload("res://addons/gkanban/components/ConfirmProjectBoardDeleteModal.tscn")

var edit_mode_project_name:bool = false

var selected = false
var project_board = {
	"name":"",
	"lists":[]
}


func _ready():
	enable_project_board_name_edit(false)


func _input(event):
	if event is InputEventMouseMotion:
		var _left_boundary = project_board_name_and_edit_container.rect_global_position.x
		var _right_boundary = project_board_name_and_edit_container.rect_global_position.x + project_board_name_and_edit_container.rect_size.x
		var _top_boundary = project_board_name_and_edit_container.rect_global_position.y
		var _bottom_boundary = project_board_name_and_edit_container.rect_global_position.y + project_board_name_and_edit_container.rect_size.y

		if event.position.x > _left_boundary and event.position.x < _right_boundary and event.position.y > _top_boundary and event.position.y < _bottom_boundary:
			selected = true
		else:
			selected = false

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if !edit_mode_project_name and selected:
				enable_project_board_name_edit(true)
			if !selected and edit_mode_project_name:
				enable_project_board_name_edit(false)


func enable_project_board_name_edit(_enable):
	edit_mode_project_name = _enable
	if _enable:
		project_board_name_edit.text = project_board_name.text
		project_board_name.hide()
		project_board_name_edit.show()
		project_board_name_edit.grab_focus()
	else:
		project_board_name.show()
		project_board_name_edit.hide()
	


func set_app_theme(_theme_name: String)->void:
	theme_name = _theme_name
	for theme in theme_manager.themes:
		if theme_name == theme.name:
			$BG.get("custom_styles/panel").bg_color = theme.colors.pages.project_board.bg
			break

func set_project_board(_project_board):
	project_board = _project_board
	project_board_name_label.text = _project_board.name

	for list in project_board.lists:
		var _list = list_scene.instance()
		_list.connect("move_card_pressed",self,"_on_List_move_card_pressed",[],CONNECT_DEFERRED)
		_list.connect("move_list_pressed",self,"_on_List_move_list_pressed",[],CONNECT_DEFERRED)
		_list.connect("list_menu_pressed",self,"_on_List_list_menu_pressed",[],CONNECT_DEFERRED)
		_list.connect("card_menu_pressed",self,"_on_List_card_menu_pressed",[],CONNECT_DEFERRED)
		_list.connect("list_created",self,"_on_List_list_created",[],CONNECT_DEFERRED)
		_list.connect("list_updated",self,"_on_List_list_updated",[],CONNECT_DEFERRED)
		_list.connect("card_created",self,"_on_List_card_created",[],CONNECT_DEFERRED)
		_list.connect("card_updated",self,"_on_List_card_updated",[],CONNECT_DEFERRED)
		list_container.add_child(_list)
		_list.initialize_list(list)


func _on_BackButton_pressed():
	emit_signal("closed")
	queue_free()

func create_list(_opitions = null):
	var _list = list_scene.instance()
	_list.connect("move_card_pressed",self,"_on_List_move_card_pressed",[],CONNECT_DEFERRED)
	_list.connect("move_list_pressed",self,"_on_List_move_list_pressed",[],CONNECT_DEFERRED)
	_list.connect("list_menu_pressed",self,"_on_List_list_menu_pressed",[],CONNECT_DEFERRED)
	_list.connect("card_menu_pressed",self,"_on_List_card_menu_pressed",[],CONNECT_DEFERRED)
	_list.connect("list_created",self,"_on_List_list_created",[],CONNECT_DEFERRED)
	_list.connect("list_updated",self,"_on_List_list_updated",[],CONNECT_DEFERRED)
	_list.connect("card_created",self,"_on_List_card_created",[],CONNECT_DEFERRED)
	_list.connect("card_updated",self,"_on_List_card_updated",[],CONNECT_DEFERRED)
	list_container.add_child(_list)
	if _opitions == null:
		_list.start(list_container.get_child_count())
	

func _on_List_card_created(_list, _card):
	emit_signal("card_created",self,_list,_card)


func _on_List_card_updated(_list, _card):
	emit_signal("card_updated",self,_list,_card)

func _on_List_list_updated(_list):
	emit_signal("list_updated",self,_list)

func _on_List_list_created(_list):
	var _created_list = {
		'name':_list.list_name_label.text
	}
	emit_signal("list_created",self, _created_list)
		

func _on_AddListButton_pressed():
	create_list()

func delete_menus():
	for menu in menu_container.get_children():
		menu.queue_free()

func _on_List_card_menu_pressed(_list, _card):
	delete_menus()
	var _menu = card_menu_scene.instance()
	_menu.connect("move_card_pressed",self, "_on_CardMenu_move_card_pressed",[],CONNECT_DEFERRED)
	_menu.connect("delete_card_pressed",self, "_on_CardMenu_delete_card_pressed",[],CONNECT_DEFERRED)
	menu_container.add_child(_menu)
	var _x_pos = _card.rect_global_position.x + _card.rect_size.x - 36
	var _y_pos = _card.rect_global_position.y + 36
	_menu.rect_global_position = Vector2(_x_pos,_y_pos)
	_menu.setup_list_card(_list, _card)


func _on_CardMenu_delete_card_pressed(_list, _card):
	delete_menus()
	var i = 0
	for card in _list.list.cards:
		if card.id == _card.card.id:
			_list.list.cards.remove(i)
			break
		i += 1
	emit_signal("list_updated",self,_list)
	_card.queue_free()

func _on_CardMenu_move_card_pressed(_list, _card, _direction):
	delete_menus()
	var i = 0
	var current_list_index = 0
	var current_card_index = 0
	for list in list_container.get_children():
		if list == _list:
			current_list_index = i
			var j = 0
			for card in list.cards_container.get_children():
				if card == _card:
					current_card_index = j
					break;
				j += 1
			break
		i += 1
		
	var list = list_container.get_child(current_list_index)

	var cards_container = list.cards_container


	match _direction:
		"top":
			if cards_container.get_child(0) == _card:
				return

			cards_container.move_child(cards_container.get_child(current_card_index),0)

			var card_item = _list.list.cards.pop_at(current_card_index)
			_list.list.cards.insert(0,card_item)
			_list.emit_signal("list_updated",_list)
		"up":
			if cards_container.get_child(0) == _card:
				return

			cards_container.move_child(cards_container.get_child(current_card_index),current_card_index-1)
			var card_item = _list.list.cards.pop_at(current_card_index)
			_list.list.cards.insert(current_card_index-1,card_item)
			_list.emit_signal("list_updated",_list)
		"down":
			if cards_container.get_child(cards_container.get_child_count()-1) == _card:
				return

			cards_container.move_child(cards_container.get_child(current_card_index),current_card_index+1)
			var card_item = _list.list.cards.pop_at(current_card_index)
			_list.list.cards.insert(current_card_index+1,card_item)
			_list.emit_signal("list_updated",_list)
		"bottom":
			if cards_container.get_child(cards_container.get_child_count()-1) == _card:
				return

			cards_container.move_child(cards_container.get_child(current_card_index),cards_container.get_child_count()-1)
			var card_item = _list.list.cards.pop_at(current_card_index)
			_list.list.cards.insert(cards_container.get_child_count()-1,card_item)
			_list.emit_signal("list_updated",_list)
		"list":
			if list_container.get_child_count() <= 1:
				return
			var _move_to_list_modal = move_to_list_modal_scene.instance()
			_move_to_list_modal.connect('list_menu_button_pressed',self,'_on_MoveToListModal_list_menu_button_pressed',[_list],CONNECT_DEFERRED)
			menu_container.add_child(_move_to_list_modal)
			for singleList in list_container.get_children():
				if singleList != _list:
					_move_to_list_modal.add_menu(singleList, _card)

		

func _on_MoveToListModal_list_menu_button_pressed(_list, _card, _from_list):
	var target_index = get_list_index(_list)
	list_container.get_child(target_index).add_card(_card.card)
	_from_list.remove_card(_card.card)
	_card.queue_free()
			


func _on_List_list_menu_pressed(_list):
	delete_menus()
	var _menu = list_menu_scene.instance()
	_menu.connect("delete_list_pressed",self,"_on_ListMenu_delete_list_pressed",[],CONNECT_DEFERRED)
	_menu.connect("move_list_pressed",self,"_on_ListMenu_move_list_pressed",[],CONNECT_DEFERRED)
	_menu.set_list(_list)
	menu_container.add_child(_menu)
	var _x_pos = _list.rect_global_position.x + _list.rect_size.x - 36
	var _y_pos = _list.rect_global_position.y + 36
	_menu.rect_global_position = Vector2(_x_pos,_y_pos)

func _on_ListMenu_move_list_pressed(_list, _direction):
	move_list(_list, _direction)
	delete_menus()


func _on_ListMenu_delete_list_pressed(_list):
	print(_list)
	for list in list_container.get_children():
		if list == _list:
			list.queue_free()
	delete_menus()

func get_list_index(_list):
	var i = 0
	var current_index = 0
	for list in list_container.get_children():
		if list == _list:
			current_index = i
		i += 1
	return current_index

func move_list(_list, _direction):

	var current_index = get_list_index(_list)

	match _direction:
		"left":
			if list_container.get_child(0) == _list:
				return
			list_container.move_child(list_container.get_child(current_index), current_index-1)
			var list_item = project_board.lists.pop_at(current_index)
			project_board.lists.insert(current_index-1,list_item)
			emit_signal("updated",self)

		
		"right":
			if list_container.get_child(list_container.get_child_count()-1) == _list:
				return
			list_container.move_child(list_container.get_child(current_index), current_index+1)
			var list_item = project_board.lists.pop_at(current_index)
			project_board.lists.insert(current_index+1,list_item)
			emit_signal("updated",self)
		"first":
			if list_container.get_child(0) == _list:
				return
			list_container.move_child(list_container.get_child(current_index), 0)
			var list_item = project_board.lists.pop_at(current_index)
			project_board.lists.insert(0,list_item)
			emit_signal("updated",self)
		"last":
			if list_container.get_child(list_container.get_child_count()-1) == _list:
				return
			list_container.move_child(list_container.get_child(current_index), list_container.get_child_count()-1)
			var list_item = project_board.lists.pop_at(current_index)
			project_board.lists.insert(list_container.get_child_count()-1,list_item)
			emit_signal("updated",self)


func _on_List_move_list_pressed(_list, _direction):
	move_list(_list, _direction)

func _on_List_move_card_pressed(_list, _card, _direction):
	match _direction:
		"left":
			if list_container.get_child(0) == _list:
				return

			var current_index = get_list_index(_list)

			list_container.get_child(current_index-1).add_card(_card.card)

			_card.queue_free()
		"right":
			if list_container.get_child(list_container.get_child_count()-1) == _list:
				return

			var current_index = get_list_index(_list)

			list_container.get_child(current_index+1).add_card(_card.card)
			_card.queue_free()


func _on_ProjectBoardNameEdit_text_entered(new_text:String):
	project_board_name.text = project_board_name_edit.text
	project_board.name = project_board_name_edit.text
	emit_signal("updated",self)
	enable_project_board_name_edit(false)


func _on_DeleteButton_pressed():
	delete_menus()
	var _dialog = confirm_project_board_delete_scene.instance()
	_dialog.connect("project_board_deleted",self,"_on_MenuConfirmProjectBoardDelete_project_board_deleted",[],CONNECT_DEFERRED)
	menu_container.add_child(_dialog)
	_dialog.set_project_board(project_board)

func _on_MenuConfirmProjectBoardDelete_project_board_deleted(_project_board):
	emit_signal("deleted", _project_board)
	queue_free()
