extends Panel

"""
The purpose of this script is to Handle Top Menu Actions
"""

func _on_OpenBoardButton_pressed() -> void:
	Global.open_board.connect("file_selected", OpenSave, "load_project")
	Global.open_board.popup_centered()


func _on_SaveBoardButton_pressed() -> void:
	Global.save_board.connect("file_selected", OpenSave, "save_project", [Global.current_project])
	Global.save_board.popup_centered()
