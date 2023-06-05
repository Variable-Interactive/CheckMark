tool
extends HBoxContainer

signal text_changed


func bblize_text(text: String):
	if text.begins_with("[] "):
		text = text.trim_prefix("[] ")
		$CheckBox.visible = true
		$CheckBox.pressed = false
	elif text.begins_with("[x] "):
		text = text.trim_prefix("[x] ")
		$CheckBox.visible = true
		$CheckBox.pressed = true
	if text == "":
		rect_min_size.y = rect_size.y
		$Text.visible = false
	$Text.bbcode_text = text


func get_state():
	return $CheckBox.pressed


func _on_CheckBox_toggled(button_pressed: bool) -> void:
	var text: String
	Global.current_project.update_completed_tasks()
	if button_pressed:
		text = str("[x] ", $Text.bbcode_text)
	else:
		text = str("[] ", $Text.bbcode_text)
	emit_signal("text_changed", text, get_index())
