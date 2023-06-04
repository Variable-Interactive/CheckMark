extends Node

enum RightMenuItems {
	NEW_NOTE_TASK,
	NEW_CHECKBOX_TASK,
	NEW_IMAGE_TASK,
	NEW_AUDIO_TASK,
	NEW_LINK_TASK
	}

var projects := []  # Array of projects
var current_project: Project

onready var control: Node = get_tree().current_scene
onready var boards := control.find_node("Boards") as VBoxContainer
onready var mind_map := control.find_node("MindMap") as MindMap
onready var status_bar := control.find_node("StatusBar")

onready var open_board: FileDialog = control.find_node("OpenBoard")
onready var save_board: FileDialog = control.find_node("SaveBoard")


# Todo move these to a separate Script
func change_project(idx):
	if current_project:
		current_project.update_tasks_array()
		mind_map.clear_tasks()
	current_project = Global.projects[idx]
	mind_map.new_render()
	Global.current_project.update_completed_tasks()


func remove_project(idx):
	boards.get_child(idx).queue_free()
	if projects[idx] == current_project:
		change_project(idx - 1)
	projects.remove(idx)


func new_project():
	var button = preload("res://src/UI/Board Button.tscn").instance()
	boards.add_child(button)
	button.text = str("Board ", button.get_index()+1)
	button.connect("switch", Global, "change_project")

	var project = Project.new()
	Global.projects.append(project)

	Global.change_project(button.get_index())
