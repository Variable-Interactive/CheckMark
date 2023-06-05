extends Node

"""
The purpose of this script is to handle Project Saving and Loading
"""

func save_project(path :String, project: Project):
	var data = project.serialize()
	var file := File.new()
	var _error = file.open(path, File.WRITE)
	if _error == OK:
#		$HBoxContainer/Boards.get_child(current_board.get_index() - 1).text = path.get_file()
		file.store_var(data)
		file.close()


func load_project(path :String):
	if path.ends_with(".vplan") or path.ends_with(".res"):
		var file := File.new()
		var error = file.open(path, File.READ)
		if error != OK:
			return

		var button = preload("res://src/UI/Nodes/BoardButton.tscn").instance()
		Global.boards.add_child(button)
		button.text = str("Board ", button.get_index()+1)
		button.connect("switch", Global, "change_project")
		var project = Project.new()
		Global.projects.append(project)
		Global.change_project(button.get_index())

		Global.boards.get_child(Global.boards.get_child_count() - 1).text = path.get_file()
		Global.status_bar.get_node("ProjName").text = path.get_file()

		var data = file.get_var()
		project.deserialize(data)
		file.close()
