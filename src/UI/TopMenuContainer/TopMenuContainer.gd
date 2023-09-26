extends Panel

"""
The purpose of this script is to Handle Top Menu Actions
"""

func _on_OpenBoardButton_pressed() -> void:
	Global.open_board.connect("file_selected", OpenSave, "load_project")
	if Global.last_open_dir != "":
		Global.open_board.current_dir = Global.last_open_dir
	Global.open_board.popup_centered()


func _on_SaveBoardButton_pressed() -> void:
	Global.save_board.connect("file_selected", OpenSave, "save_project", [Global.current_project])
	if Global.current_project.save_path != "":
		Global.save_board.current_dir = Global.current_project.save_path.get_base_dir()
	Global.save_board.popup_centered()
