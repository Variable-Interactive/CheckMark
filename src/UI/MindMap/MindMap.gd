class_name MindMap
extends GraphEdit

"""
The purpose of this script is to control the display of actual GraphNodes
From the data of the current project
"""

func clear_tasks():
	for child in get_children():
		if child is GraphNode:
			child.queue_free()
	if minimap_enabled:
		minimap_enabled = false
		yield(get_tree(), "idle_frame")
		minimap_enabled = true


func new_render():
	var project: Project = Global.current_project
	for task in project.tasks:
		render_task(task)


func render_task(info: Dictionary):
	var new_task: GraphNode
	if info["type"] == "image_task":
		new_task = preload("res://src/tasks/ImageTask.tscn").instance()
	if info["type"] == "checkbox_task":
		new_task = preload("res://src/tasks/CheckboxTask.tscn").instance()
	if info["type"] == "audio_task":
		new_task = preload("res://src/tasks/AudioTask.tscn").instance()
	if info["type"] == "note_task":
		new_task = preload("res://src/tasks/NoteTask.tscn").instance()
	if info["type"] == "link_task":
		new_task = preload("res://src/tasks/LinkTask.tscn").instance()
	if new_task:
		new_task.connect("close_request", self, "remove_task", [info])
		add_child(new_task)
		new_task.deserialize(info)


func remove_task(info: Dictionary):
	Global.current_project.tasks.erase(info)
