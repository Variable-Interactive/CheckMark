extends BaseTask

onready var name_label: LineEdit = $"%Title"
onready var detail: TextEdit = $"%Text"
onready var preview: VBoxContainer = $"%Preview"


func serialize() -> Dictionary:
	var information = .serialize()
	information["title"] = name_label.text
	information["detail"] = detail.text
	return information


func deserialize(information: Dictionary):
	if information.has("title"):
		name_label.text = information["title"]
	if information.has("detail"):
		detail.text = information["detail"]
		hint_tooltip = information.detail
	Global.current_project.update_completed_tasks()
	update_preview()
	.deserialize(information)


func close_node() -> void:
	Global.current_project.update_completed_tasks()
	.close_node()


func get_type():
	return "checkbox_task"


func get_completed_total_checks() -> Vector2:
	var comp := 0
	for check in preview.get_children():
		if check.get_state() == true:
			comp += 1
	return Vector2(comp, preview.get_child_count())


func update_preview():
	for child in preview.get_children():
		child.queue_free()
	for l in detail.get_line_count():
		var check = preload("res://src/UI/Nodes/CheckEntry.tscn").instance()
		preview.add_child(check)
		check.bblize_text(detail.get_line(l))
		check.connect("text_changed", self, "update_detail_line")


func update_detail_line(new_text: String, index):
	detail.set_line(index, new_text)

func _on_Name_focus_entered():
	yield(get_tree().create_timer(0.1), "timeout")
	name_label.select_all()


func _on_Content_tab_changed(tab: int) -> void:
	if tab == 0:
		update_preview()


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
