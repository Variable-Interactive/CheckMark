extends BaseTask

onready var link_button = $LinkButton

var url := "https://godotengine.org/"

func serialize() -> Dictionary:
	var information = .serialize()
	information["url"] = url
	return information


func deserialize(information) -> void:
	# overrides (information)
	if information.has("url"):
		url = information["url"]
		link_button.text = url
	.deserialize(information)


func show_options():
	# Todo add these two to the base class later
	Global.task_options.get_node("VBoxContainer/LineEdit").text = link_button.text
	Global.task_options.get_node("VBoxContainer/Comment").text = hint_tooltip
	.show_options()


func load_options():
	url = Global.task_options.get_node("VBoxContainer/LineEdit").text
	link_button.text = url


func resize_task(new_minsize):
	rect_size.x = new_minsize.x


func get_type():
	return "link_task"


func _on_LinkButton_pressed():
	var _error = OS.shell_open(link_button.text)
