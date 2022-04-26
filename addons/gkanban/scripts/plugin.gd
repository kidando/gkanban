tool
extends EditorPlugin

var plugin_interface = preload("res://addons/gkanban/components/PluginInterface.tscn").instance()

func _enter_tree():
	get_editor_interface().get_editor_viewport().add_child(plugin_interface)
	make_visible(false)


func _exit_tree():
	if plugin_interface:
		plugin_interface.queue_free()
		
func has_main_screen()->bool:
	return true
	
func get_plugin_name()-> String:
	return "G-Kanban"
	
func get_plugin_icon()->Texture:
	return get_editor_interface().get_base_control().get_icon("Spatial","EditorIcons")
	
func make_visible(visible:bool)->void:
	if plugin_interface:
		plugin_interface.visible = visible
