extends GraphNode

onready var main = get_tree().current_scene
onready var name_label = $VBoxContainer/Name
onready var check_box = $VBoxContainer/HBoxContainer/CheckBox
onready var detail_dial = get_tree().current_scene.get_node("Dialogs/Detail")
onready var added_to_check_list = false
var total_checks = 1
var checked_boxes = 0
var detail = ""
var opened = false
var information = {
	"type" : "checkbox_task",
	"name" : "Check Box Task",
	"position" : offset,
	"state": false,
	"detail": ""
}

func start(info):
	name_label.text = info.name
	offset = info.position
	check_box.pressed = info.state
	detail = info.detail
	hint_tooltip = info.detail
	if not added_to_check_list:
		main.total_completed += 1
		added_to_check_list = true
		Global.current_project.update_completed_tasks()
	information = info
	opened = true


func _ready():
	if not opened:
		information.position = (get_tree().current_scene.get_viewport().get_mouse_position() + get_parent().scroll_offset) / get_parent().zoom
		start(information)


func _on_LineEdit_text_entered(new_text):
	name_label.text = new_text
	information.name = new_text

func _on_Name_focus_entered():
	yield(get_tree().create_timer(0.1), "timeout")
	name_label.select_all()


func _on_Information_pressed():
	detail_dial.popup_centered()
	detail_dial.get_node("TextEdit").connect("text_changed", self, "_on_Detail_changed")
	detail_dial.connect("popup_hide", self, "_On_Detail_hide")
	detail_dial.get_node("TextEdit").text = detail


func _on_Detail_changed():
	detail = detail_dial.get_node("TextEdit").text
	information.detail = detail


func _On_Detail_hide():
	detail_dial.get_node("TextEdit").disconnect("text_changed", self, "_on_Detail_changed")
	detail_dial.disconnect("popup_hide", self, "_On_Detail_hide")
	detail = detail_dial.get_node("TextEdit").text
	information.detail = detail
	hint_tooltip = information.detail


func _on_CheckboxTask_dragged(_from, to):
	information.position = to


func _on_CheckboxTask_close_request():
	main.completed -= 1
	queue_free()


func _on_CheckBox_toggled(button_pressed):
	if button_pressed:
		main.completed += 1
		checked_boxes += 1
	else:
		main.completed -= 1
		checked_boxes -= 1
	Global.current_project.update_completed_tasks()

	information.state = button_pressed
	animate_progress(button_pressed)


func animate_progress(value :bool):
	var tween = $Tween
	var progress = $VBoxContainer/HBoxContainer/ProgressBar
	if value:
		tween.interpolate_property(progress, "value",progress.value, 100, 0.2)
	else:
		tween.interpolate_property(progress, "value",progress.value, 0, 0.2)
	tween.start()
