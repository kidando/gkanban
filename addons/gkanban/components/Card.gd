tool
extends PanelContainer

signal move_card_pressed(_card,_direction)
signal delete_card_pressed(_card)
signal menu_pressed(_card)
signal created(_card)
signal updated(_card)

var card = {
	"id":"",
	"title":"",
	"color":""
}


export (NodePath) var title_path:NodePath
onready var title:RichTextLabel = get_node(title_path)

export (NodePath) var title_edit_path:NodePath
onready var title_edit:TextEdit = get_node(title_edit_path)

export (NodePath) var card_buttons_container_path:NodePath
onready var card_buttons_container:HBoxContainer = get_node(card_buttons_container_path)

export (NodePath) var card_title_and_edit_container_path:NodePath
onready var card_title_and_edit_container:MarginContainer = get_node(card_title_and_edit_container_path)

export (NodePath) var card_title_container_path:NodePath
onready var card_title_container:MarginContainer = get_node(card_title_container_path)

export (NodePath) var card_title_edit_container_path:NodePath
onready var card_title_edit_container:MarginContainer = get_node(card_title_edit_container_path)

export (NodePath) var buttons_bg_path:NodePath
onready var buttons_bg:PanelContainer = get_node(buttons_bg_path)

export (NodePath) var radio_default_btn_path:NodePath
onready var radio_default_btn:CheckBox = get_node(radio_default_btn_path)

export (NodePath) var radio_green_btn_path:NodePath
onready var radio_green_btn:CheckBox = get_node(radio_green_btn_path)

export (NodePath) var radio_red_btn_path:NodePath
onready var radio_red_btn:CheckBox = get_node(radio_red_btn_path)

export (NodePath) var radio_yellow_btn_path:NodePath
onready var radio_yellow_btn:CheckBox = get_node(radio_yellow_btn_path)

var selected :bool = false

var can_switch_to_quick_edit: bool = false

var quick_edit_on:bool = false

var card_color:= "default"

var colors:= {
	"default":{
		"normal": Color("#ff819aa9"),
		"hover": Color("#ff8da2af")
	},
	"green":{
		"normal": Color("#ff21C063"),
		"hover": Color("#ff23D16C")
	},
	"red":{
		"normal": Color("#ffC1334D"),
		"hover": Color("#ffCC3E58")
	},
	"yellow":{
		"normal": Color("#ff2374AB"),
		"hover": Color("#ff267FBA")
	}
}


func _ready():
	edit_mode(false)

func start(_card_number):
	title.bbcode_text = str("[Card #",_card_number,"]")
	card ={
		"title":title.bbcode_text,
		"color":"default"
	}
	radio_default_btn.pressed = true
	emit_signal("created",self)

func setup_card(_card_data):
	card = _card_data
	title.bbcode_text = _card_data.title
	card_color = _card_data.color

	radio_default_btn.pressed = true
	radio_red_btn.pressed = true
	radio_green_btn.pressed = true
	radio_yellow_btn.pressed = true

	match card_color:
		"default":
			radio_default_btn.pressed = true
		"green":

			radio_green_btn.pressed = true
		"red":
			radio_red_btn.pressed = true
		"yellow":
			radio_yellow_btn.pressed = true

func _process(delta):
	if selected:
		get("custom_styles/panel").bg_color = Color("#ffdae2e7")
		card_buttons_container.modulate = Color(1,1,1,1)
		buttons_bg.get("custom_styles/panel").bg_color = colors.get(card_color).hover
	else:
		get("custom_styles/panel").bg_color = Color("#ffc9d5dc")
		card_buttons_container.modulate = Color(1,1,1,0)
		buttons_bg.get("custom_styles/panel").bg_color = colors.get(card_color).normal


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
			if !quick_edit_on and selected and can_switch_to_quick_edit:
				edit_mode(true)

			if !selected and quick_edit_on:
				edit_mode(false)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			if quick_edit_on:
				edit_mode(false)

func edit_mode(_enable:bool):
	if _enable:
		quick_edit_on = true
		card_title_edit_container.show()
		card_title_container.hide()
		title_edit.text = title.bbcode_text
		title_edit.select_all()
	else:
		quick_edit_on = false
		card_title_edit_container.hide()
		card_title_container.show()




func _on_EditCardButton_pressed():
	if quick_edit_on:
		return


func _on_DeleteCardButton_pressed():
	if quick_edit_on:
		return
	emit_signal("delete_card_pressed",self)


func _on_MoveCardUpButton_pressed():
	if quick_edit_on:
		return
	emit_signal("move_card_pressed",self, "up")


func _on_MoveCardDownButton_pressed():
	if quick_edit_on:
		return
	emit_signal("move_card_pressed",self, "down")


func _on_MoveCardLeftButton_pressed():
	if quick_edit_on:
		return
	emit_signal("move_card_pressed",self, "left")


func _on_MoveCardRightButton_pressed():
	if quick_edit_on:
		return
	emit_signal("move_card_pressed",self, "right")


func _on_CardMenuButton_pressed():
	if quick_edit_on:
		return
	emit_signal("menu_pressed",self)


func _on_CardTitleContainer_mouse_entered():
	can_switch_to_quick_edit = true


func _on_CardTitleContainer_mouse_exited():
	can_switch_to_quick_edit = false


func _on_CancelEditButton_pressed():
	edit_mode(false)


func _on_SaveChangesButton_pressed():
	title.bbcode_text = title_edit.text
	card.title = title.bbcode_text
	emit_signal("updated",self)
	edit_mode(false)

func _on_DefaultColorButton_pressed():
	card_color = "default"
	card.color = "default"
	emit_signal("updated",self)


func _on_GreenColorButton_pressed():
	card_color = "green"
	card.color = "green"
	emit_signal("updated",self)


func _on_RedColorButton_pressed():
	card_color = "red"
	card.color = "red"
	emit_signal("updated",self)


func _on_YellowColorButton_pressed():
	card_color = "yellow"
	card.color = "yellow"
	emit_signal("updated",self)
