extends GraphNode

onready var link_button = $LinkButton
onready var link_options = get_tree().current_scene.get_node("Dialogs/PathOptions")
var opened = false

var information = {
	"type" : "link_task",
	"link" : "https://godotengine.org/",
	"position" : offset,
	"size" : rect_size,
	"comment" : "Comment..."
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if not opened:
		information.position = (get_tree().current_scene.get_viewport().get_mouse_position() + get_parent().scroll_offset) / get_parent().zoom
		start(information)


func start(info):
	hint_tooltip = info.comment
	link_button.text = info.link
	offset = info.position
	_on_LinkTask_resize_request(info.size)
	information = info
	opened = true

func _on_Options_pressed():
	link_options.popup_centered()
	link_options.get_node("VBoxContainer/LineEdit").text = link_button.text
	link_options.get_node("VBoxContainer/Comment").text = information.comment
	
	link_options.connect("popup_hide", self, "_On_Option_hide")
	link_options.get_node("Load").connect("pressed", self, "_on_load_pressed")
	link_options.get_node("VBoxContainer/Comment").connect("text_changed", self, "on_comment_changed")


func _On_Option_hide():
	link_options.disconnect("popup_hide", self, "_On_Option_hide")
	link_options.get_node("Load").disconnect("pressed", self, "_on_load_pressed")
	link_options.get_node("VBoxContainer/Comment").disconnect("text_changed", self, "on_comment_changed")
	
	information.hint = link_options.get_node("VBoxContainer/LineEdit").text
	information.comment = link_options.get_node("VBoxContainer/Comment").text
	hint_tooltip = information.comment


func on_comment_changed():
	information.comment = link_options.get_node("VBoxContainer/Comment").text


func _on_load_pressed():
	var text = link_options.get_node("VBoxContainer/LineEdit").text
	link_button.text = text
	information.link = text
	link_options.hide()


func _on_LinkTask_resize_request(new_minsize):
	rect_size.x = new_minsize.x
	information.size = new_minsize


func _on_LinkTask_dragged(_from, to):
	information.position = to


func _on_LinkTask_close_request():
	queue_free()


func _on_LinkButton_pressed():
	var _error = OS.shell_open(link_button.text)
