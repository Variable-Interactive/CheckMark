class_name BaseTask
extends GraphNode

onready var options_button: Button = find_node("Options")

func _ready() -> void:
	connect("close_request", self, "close_node")
	connect("resize_request", self, "resize_task")
	if options_button:
		options_button.connect("pressed", self, "show_options")


func serialize() -> Dictionary:
	var information = {
		"type" : get_type(),
		"position" : offset,
		"size" : rect_size,
		"comment" : hint_tooltip
	}
	return information


func deserialize(information: Dictionary) -> void:
	offset = (
		(
			get_tree().current_scene.get_viewport().get_mouse_position()
			+ get_parent().scroll_offset
		) / get_parent().zoom
	)
	resize_task(rect_size)
	hint_tooltip = "Comment..."
	if information.has("position"):
		offset = information["position"]
	if information.has("size"):
		resize_task(information["size"])
	if information.has("comment"):
		hint_tooltip = information["comment"]


func get_type():
	return "base_task"


func close_node() -> void:
	queue_free()


func resize_task(new_minsize):
	rect_size = new_minsize


func show_options() -> void:
	Global.task_options.connect("popup_hide", self, "disconnect_option_dialog")
	Global.task_options.get_node("Load").connect("pressed", self, "load_options")
	Global.task_options.get_node("VBoxContainer/Comment").connect("text_changed", self, "change_comment")
	Global.task_options.popup_centered()


func disconnect_option_dialog() -> void:
	Global.task_options.disconnect("popup_hide", self, "disconnect_option_dialog")
	Global.task_options.get_node("Load").disconnect("pressed", self, "load_options")
	Global.task_options.get_node("VBoxContainer/Comment").disconnect("text_changed", self, "change_comment")


func change_comment() -> void:
	hint_tooltip = Global.task_options.get_node("VBoxContainer/Comment").text


func load_options() -> void:
	pass
