class_name Project
extends Reference

"""
The purpose of this script is to do project related functions
"""

var tasks = [] setget , get_tasks  # Array of task dictionaries


func get_tasks() -> Array:
	return tasks


func update_tasks_array():
	if self == Global.current_project:  # if it is current project
		tasks = []
		for task in Global.mind_map.get_children():
			if task is GraphNode:
				tasks.append(task.serialize())


func update_completed_tasks():
	var comp: Vector2 = _get_completed_number()
	Global.status_bar.get_node("Completed").text = str("Completed ", comp.x, " out of ", comp.y)


func serialize() -> Dictionary:
	if self == Global.current_project:  # if it is current project
		update_tasks_array()
	var data = {
			"tasks": tasks
		}
	return data


func deserialize(data: Dictionary):
	if data.has("tasks"):
		tasks = data["tasks"]


func add_task(info :Dictionary):  # Task removal is handled by MindMap.gd
	tasks.append(info)
	Global.mind_map.render_task(info)


func _get_completed_number() -> Vector2:
	var total_checks: int = 0
	var completed: int = 0
	for task in tasks:
		if task.has("type"):
			if task["type"] == "checkbox_task":
				total_checks += 1
				if task.has("state"):
					if task["state"] == true:
						completed += task.checked_boxes
	return Vector2(completed, total_checks)
