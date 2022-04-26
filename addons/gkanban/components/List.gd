tool
extends PanelContainer

signal move_card_pressed(_list, _card, _direction)
signal move_list_pressed(_list, _direction)
signal list_menu_pressed(_list)
signal card_menu_pressed(_list, _card)
signal list_created(_list)
signal list_updated(_list)
signal card_created(_list, _card)
signal card_updated(_list, _card)

export (NodePath) var cards_container_path:NodePath
onready var cards_container:VBoxContainer = get_node(cards_container_path)

export (NodePath) var list_name_label_path:NodePath
onready var list_name_label:Label = get_node(list_name_label_path)

export (NodePath) var list_name_edit_path:NodePath
onready var list_name_edit:LineEdit = get_node(list_name_edit_path)

export (NodePath) var list_buttons_container_path:NodePath
onready var list_buttons_container:HBoxContainer = get_node(list_buttons_container_path)

onready var card_scene = preload("res://addons/gkanban/components/Card.tscn")

var selected: bool = false

var label_can_be_edited: bool = false

var edit_mode: bool = false

var list = {
	"name":"",
	"cards":[]
}


func _ready():
	enable_label_edit(false)


func initialize_list(_list):
	list = _list
	list_name_label.text = list.name
	for card_data in list.cards:
		var _card = card_scene.instance()
		_card.connect("move_card_pressed",self,"_on_Card_move_card_pressed",[],CONNECT_DEFERRED)
		_card.connect("delete_card_pressed",self,"_on_Card_delete_card_pressed",[],CONNECT_DEFERRED)
		_card.connect("menu_pressed",self,"_on_Card_menu_pressed",[],CONNECT_DEFERRED)
		_card.connect("created",self,"_on_Card_created",[],CONNECT_DEFERRED)
		_card.connect("updated",self,"_on_Card_updated",[],CONNECT_DEFERRED)
		cards_container.add_child(_card)
		_card.setup_card(card_data)



func _process(delta):
	if selected:
		list_buttons_container.modulate = Color(1,1,1,1)
	else:
		list_buttons_container.modulate = Color(1,1,1,0)

func _input(event):
	if event is InputEventMouseMotion:
		var _left_boundary = rect_global_position.x
		var _right_boundary = rect_global_position.x + rect_size.x
		var _top_boundary = rect_global_position.y
		var _bottom_boundary = rect_global_position.y + rect_size.y

		if event.position.x > _left_boundary and event.position.x < _right_boundary and event.position.y > _top_boundary and event.position.y < _bottom_boundary:
			selected = true
		else:
			selected = false

	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			if label_can_be_edited and !edit_mode and selected:
				enable_label_edit(true)
			if !selected and edit_mode:
				enable_label_edit(false)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if edit_mode:
				enable_label_edit(false)


func enable_label_edit(_enable: bool):
	edit_mode = _enable
	if _enable:
		list_name_edit.show()
		list_name_label.hide()
		list_name_edit.text = list_name_label.text
		list_name_edit.grab_focus()
		list_name_edit.select_all()
	else:
		label_can_be_edited = false
		list_name_edit.hide()
		list_name_label.show()

func start(_list_number):
	list_name_label.text = str("[List #",_list_number,"]")
	emit_signal("list_created",self)

func setup(_title, _cards_data):
	list_name_label.text = _title
	for card_data in _cards_data:
		var _card = card_scene.instance()
		_card.connect("move_card_pressed",self,"_on_Card_move_card_pressed",[],CONNECT_DEFERRED)
		_card.connect("delete_card_pressed",self,"_on_Card_delete_card_pressed",[],CONNECT_DEFERRED)
		_card.connect("menu_pressed",self,"_on_Card_menu_pressed",[],CONNECT_DEFERRED)
		_card.connect("created",self,"_on_Card_created",[],CONNECT_DEFERRED)
		_card.connect("updated",self,"_on_Card_updated",[],CONNECT_DEFERRED)
		cards_container.add_child(_card)
		_card.setup_card(card_data)

func _on_Card_updated(_card):
	emit_signal("card_updated",self,_card)

func _on_AddCardButton_pressed():
	var _card = card_scene.instance()
	_card.connect("move_card_pressed",self,"_on_Card_move_card_pressed",[],CONNECT_DEFERRED)
	_card.connect("delete_card_pressed",self,"_on_Card_delete_card_pressed",[],CONNECT_DEFERRED)
	_card.connect("menu_pressed",self,"_on_Card_menu_pressed",[],CONNECT_DEFERRED)
	_card.connect("created",self,"_on_Card_created",[],CONNECT_DEFERRED)
	_card.connect("updated",self,"_on_Card_updated",[],CONNECT_DEFERRED)
	cards_container.add_child(_card)
	_card.start(cards_container.get_child_count())

func _on_Card_created(_card):
	emit_signal("card_created",self,_card)

func remove_card(_card_data):
	var i = 0
	for card in list.cards:
		if card.id == _card_data.id:
			list.cards.remove(i)
			break
		i += 1
	emit_signal("list_updated",self)

func add_card(_card_data):
	var _card = card_scene.instance()
	list.cards.push_front({
		'id':_card_data.id,
		'title':_card_data.title,
		'color':_card_data.color
	})

	_card.connect("move_card_pressed",self,"_on_Card_move_card_pressed",[],CONNECT_DEFERRED)
	_card.connect("delete_card_pressed",self,"_on_Card_delete_card_pressed",[],CONNECT_DEFERRED)
	_card.connect("menu_pressed",self,"_on_Card_menu_pressed",[],CONNECT_DEFERRED)
	_card.connect("created",self,"_on_Card_created",[],CONNECT_DEFERRED)
	_card.connect("updated",self,"_on_Card_updated",[],CONNECT_DEFERRED)
	cards_container.add_child(_card)
	_card.setup_card(_card_data)
	cards_container.move_child(cards_container.get_child(cards_container.get_child_count()-1),0)
	emit_signal("list_updated",self)

func _on_Card_move_card_pressed(_card, _direction):
	match _direction:
		"up":
			if cards_container.get_child(0) == _card:
				return

			var i = 0
			var _index = 0
			for card in cards_container.get_children():
				if card == _card:
					_index = i
					break
				i += 1
			cards_container.move_child(cards_container.get_child(_index),_index - 1)

			var card_item = list.cards.pop_at(_index)
			list.cards.insert(_index - 1,card_item)
			emit_signal("list_updated",self)
			
			
		"down":
			if cards_container.get_child(cards_container.get_child_count() - 1) == _card:
				return

			var i = 0
			var _index = 0
			for card in cards_container.get_children():
				if card == _card:
					_index = i
					break
				i += 1
			cards_container.move_child(cards_container.get_child(_index),_index + 1)

			var card_item = list.cards.pop_at(_index)
			list.cards.insert(_index + 1,card_item)
			emit_signal("list_updated",self)
			
		"left":
			emit_signal("move_card_pressed",self,_card,"left")
		"right":
			emit_signal("move_card_pressed",self,_card,"right")

func _on_Card_delete_card_pressed(_card):
	_card.queue_free()

func _on_Card_menu_pressed(_card):
	if edit_mode:
		enable_label_edit(false)
	emit_signal("card_menu_pressed",self, _card)


func _on_ListName_mouse_entered():
	label_can_be_edited = true


func _on_ListName_mouse_exited():
	label_can_be_edited = false


func _on_ListNameEdit_text_entered(new_text):
	if edit_mode:
		list_name_label.text = list_name_edit.text
		list.name = list_name_edit.text
		emit_signal("list_updated",self)
		enable_label_edit(false)


func _on_MoveLeftButton_pressed():
	if edit_mode:
		enable_label_edit(false)
	emit_signal("move_list_pressed",self,"left")


func _on_MoveRightButton_pressed():
	if edit_mode:
		enable_label_edit(false)
	emit_signal("move_list_pressed",self,"right")


func _on_MenuButton_pressed():
	emit_signal("list_menu_pressed",self)
