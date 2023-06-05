extends Control

"""
The purpose of this script is to do the basic setup
"""

onready var right_menu = $Dialogs/RightMenu

var mouse_inside_menu = false
var zoom_amount = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.window_maximized = true
	setup_right_menu()
	Global.new_project()
#	OpenSave.load_project("res://Tutorial/Tutorial.res")
#	OpenSave.load_project("user://old_project.vplan")

	for child in Global.boards.get_children():
		if !child.is_connected("switch", Global, "change_project"):
			child.connect("switch", Global, "change_project")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("right_click"):
		right_menu.rect_position = get_global_mouse_position()
		right_menu.popup()

	if Input.is_action_just_pressed("left_click"):
		if not mouse_inside_menu:
			right_menu.hide()

	if Input.is_action_just_pressed("zoom1"):
		var factor = 0
		Global.mind_map.zoom = 0.579 + (1.149 * factor)

	if Input.is_action_just_pressed("zoom2"):
		var factor = 1.0/5.0
		Global.mind_map.zoom = 0.579 + (1.149 * factor)

	if Input.is_action_just_pressed("zoom3"):
		var factor = 2.0/5.0
		Global.mind_map.zoom = 0.579 + (1.149 * factor)

	if Input.is_action_just_pressed("zoom4"):
		var factor = 3.0/5.0
		Global.mind_map.zoom = 0.579 + (1.149 * factor)

	if Input.is_action_just_pressed("zoom5"):
		var factor = 4.0/5.0
		Global.mind_map.zoom = 0.579 + (1.149 * factor)

	if Input.is_action_just_pressed("zoom6"):
		var factor = 1
		Global.mind_map.zoom = 0.579 + (1.149 * factor)


func _on_Main_tree_exiting():
	OpenSave.save_project("user://old_project.vplan", Global.current_project)


func setup_right_menu():
	for key in Global.RightMenuItems.keys():
		right_menu.add_item(key.replace("_", " ").capitalize())


func _on_RightMenu_index_pressed(index):
	var project: Project = Global.current_project
	match index:
		Global.RightMenuItems.NEW_NOTE_TASK:
			project.add_task({"type": "note_task"})
		Global.RightMenuItems.NEW_CHECKBOX_TASK:
			project.add_task({"type": "checkbox_task"})
		Global.RightMenuItems.NEW_IMAGE_TASK:
			project.add_task({"type": "image_task"})
		Global.RightMenuItems.NEW_AUDIO_TASK:
			project.add_task({"type": "audio_task"})
		Global.RightMenuItems.NEW_LINK_TASK:
			project.add_task({"type": "link_task"})


func _on_RightMenu_mouse_exited():
	mouse_inside_menu = false


func _on_RightMenu_mouse_entered():
	mouse_inside_menu = true


# Todo move these to a separate Script
func _on_Add_pressed():
	Global.new_project()


func _on_Delete_pressed():
	if Global.projects.size() > 1:
		var idx = Global.projects.find(Global.current_project)
		Global.remove_project(idx)
