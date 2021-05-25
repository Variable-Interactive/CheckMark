extends GraphNode

onready var note = $TextEdit
var opened = false

var information = {
	"type" : "note_task",
	"position" : offset,
	"size" : rect_size,
	"text" : ""
}

func start(info):
	offset = info.position
	note.text = info.text
	_on_NoteTask_resize_request(info.size)
	update_note_size()
	information = info
	opened = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if not opened:
		information.position = (get_tree().current_scene.get_viewport().get_mouse_position() + get_parent().scroll_offset) / get_parent().zoom
		start(information)


func update_note_size():
	note.rect_min_size.y = rect_size.y - 50


func _on_NoteTask_dragged(_from, to):
	information.position = to


func _on_NoteTask_resize_request(new_minsize):
	note.rect_min_size.y = 0
	rect_size = new_minsize
	information.size = rect_size
	update_note_size()


func _on_NoteTask_close_request():
	queue_free()


func _on_TextEdit_text_changed():
	information.text = note.text
