extends BaseTask

onready var note = $TextEdit


func serialize() -> Dictionary:
	var information = .serialize()
	information["text"] = note.text
	return information


func deserialize(information) -> void:
	if information.has("text"):
		note.text = information["text"]
	.deserialize(information)


func resize_task(new_minsize):
	note.rect_min_size.y = rect_size.y - 50
	.resize_task(new_minsize)


func get_type():
	return "note_task"
