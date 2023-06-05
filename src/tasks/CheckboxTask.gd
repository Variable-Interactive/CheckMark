extends BaseTask

onready var main = get_tree().current_scene
onready var name_label: LineEdit = $"%Title"
onready var check_box: CheckBox = $"%CheckBox"
onready var detail: TextEdit = $"%Detail"


func serialize() -> Dictionary:
	var information = .serialize()
	information["state"] = check_box.pressed
	information["title"] = name_label.text
	information["detail"] = detail.text
	return information


func deserialize(information: Dictionary):
	if information.has("state"):
		check_box.pressed = information["state"]
	if information.has("title"):
		name_label.text = information["title"]
	if information.has("detail"):
		detail.text = information["detail"]
		hint_tooltip = information.detail

	Global.current_project.update_completed_tasks()
	.deserialize(information)


func close_node() -> void:
	Global.current_project.update_completed_tasks()
	.close_node()


func get_type():
	return "checkbox_task"


func _on_Name_focus_entered():
	yield(get_tree().create_timer(0.1), "timeout")
	name_label.select_all()


func _on_Detail_text_changed() -> void:
	hint_tooltip = detail.text


func _on_CheckBox_toggled(button_pressed):
	Global.current_project.update_completed_tasks()
	animate_progress(button_pressed)


func _on_Content_visibility_changed() -> void:
	if $VBoxContainer/CollapsibleContainer/Content.visible:
		pass
	else:
		yield(get_tree(), "idle_frame")
		resize_task(Vector2(rect_size.x, 0))


func animate_progress(value :bool):
	var tween = $Tween
	var progress = $VBoxContainer/ProgressBar
	if value:
		tween.interpolate_property(progress, "value", progress.value, 100, 0.2)
	else:
		tween.interpolate_property(progress, "value", progress.value, 0, 0.2)
	tween.start()
