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
	update_preview()
	.deserialize(information)


func close_node() -> void:
	for child in preview.get_children():
		child.queue_free()
	yield(get_tree(), "idle_frame")
	Global.current_project.update_completed_tasks()
	.close_node()


func get_type():
	return "checkbox_task"


func get_completed_total_checks() -> Vector2:
	var result := Vector2.ZERO
	for check in preview.get_children():
		result += check.get_contribution()
	return result


func update_preview():
	for child in preview.get_children():
		child.queue_free()
	for l in detail.get_line_count():
		var check = preload("res://src/UI/Nodes/CheckEntry.tscn").instance()
		preview.add_child(check)
		check.bblize_text(detail.get_line(l))
		check.connect("text_changed", self, "update_detail_line")

	yield(get_tree(), "idle_frame")
	Global.current_project.update_completed_tasks()
	animate_progress()


func update_detail_line(new_text: String, index):
	detail.set_line(index, new_text)
	yield(get_tree(), "idle_frame")
	Global.current_project.update_completed_tasks()
	animate_progress()


func _on_Name_focus_entered():
	yield(get_tree(), "idle_frame")
	name_label.select_all()


func _on_Content_tab_changed(tab: int) -> void:
	if tab == 0:
		update_preview()


func _on_Detail_text_changed() -> void:
	hint_tooltip = detail.text


func _on_Content_visibility_changed() -> void:
	if $VBoxContainer/CollapsibleContainer/Content.visible:
		pass
	else:
		yield(get_tree(), "idle_frame")
		resize_task(Vector2(rect_size.x, 0))


func animate_progress():
	var value = get_completed_total_checks()
	var percent: float = 0
	if value.y != 0:
		percent = (value.x / value.y) * 100
	var tween = get_tree().create_tween()
	var progress = $VBoxContainer/ProgressBar
	tween.tween_property(progress, "value", percent, 0.2)
