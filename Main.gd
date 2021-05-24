extends Panel

enum right_menu_items {NEW_NOTE_TASK, NEW_CHECKBOX_TASK, NEW_IMAGE_TASK, NEW_AUDIO_TASK, NEW_LINK_TASK}

var total_completed :int = 0
var completed :int = 0

onready var current_board = $VBoxContainer/GraphEdit
onready var right_menu = $Dialogs/RightMenu

var mouse_inside_menu = false
var data := []
var zoom_amount = 0.1


# Called when the node enters the scene tree for the first time.
func _ready():
	OS.window_maximized = true
	setup_right_menu()
	load_project("res://Tutorial/Tutorial.res")
	load_project("user://old_project.vplan")
	
	for child in $HBoxContainer/Boards.get_children():
		child.connect("switch", self, "Switch_board")



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("right_click"):
		right_menu.rect_position = get_global_mouse_position()
		right_menu.popup()
	
	if Input.is_action_just_pressed("left_click"):
		if not mouse_inside_menu:
			right_menu.hide()
	
	if Input.is_action_just_pressed("zoom1"):
		var factor = 0
		current_board.zoom = 0.579 + (1.149 * factor)
	
	if Input.is_action_just_pressed("zoom2"):
		var factor = 1.0/5.0
		current_board.zoom = 0.579 + (1.149 * factor)
	
	if Input.is_action_just_pressed("zoom3"):
		var factor = 2.0/5.0
		current_board.zoom = 0.579 + (1.149 * factor)
	
	if Input.is_action_just_pressed("zoom4"):
		var factor = 3.0/5.0
		current_board.zoom = 0.579 + (1.149 * factor)
	
	if Input.is_action_just_pressed("zoom5"):
		var factor = 4.0/5.0
		current_board.zoom = 0.579 + (1.149 * factor)
	
	if Input.is_action_just_pressed("zoom6"):
		var factor = 1
		current_board.zoom = 0.579 + (1.149 * factor)


func setup_right_menu():
	right_menu.add_item("New Note Task")
	right_menu.add_item("New CheckBox Task")
	right_menu.add_item("New Image Task")
	right_menu.add_item("New Audio Task")
	right_menu.add_item("New Link Task")


func update_completed():
	$VBoxContainer/Stats/Completed.text = str("Completed ", completed, " out of ", total_completed)


func _on_RightMenu_index_pressed(index):
	if index == right_menu_items.NEW_NOTE_TASK:
		var new_task = preload("res://src/tasks/NoteTask.tscn").instance()
		current_board.add_child(new_task)
	elif index == right_menu_items.NEW_CHECKBOX_TASK:
		var new_task = preload("res://src/tasks/CheckboxTask.tscn").instance()
		current_board.add_child(new_task)
	elif index == right_menu_items.NEW_IMAGE_TASK:
		var new_task = preload("res://src/tasks/ImageTask.tscn").instance()
		current_board.add_child(new_task)
	elif index == right_menu_items.NEW_AUDIO_TASK:
		var new_task = preload("res://src/tasks/AudioTask.tscn").instance()
		current_board.add_child(new_task)
	elif index == right_menu_items.NEW_LINK_TASK:
		var new_task = preload("res://src/tasks/LinkTask.tscn").instance()
		current_board.add_child(new_task)


func _on_Main_tree_exiting():
	save_project("user://old_project.vplan")


func save_project(path :String):
	data = []
	for children in current_board.get_children():
		if children.get_class() == "GraphNode":
			data.append(children.information)
	var file := File.new()
	var _error = file.open(path, File.WRITE)
	if _error == OK:
		$HBoxContainer/Boards.get_child(current_board.get_index() - 1).text = path.get_file()
		file.store_var(data)
		file.close()


func load_project(path :String):
	if path.ends_with(".vplan") or path.ends_with(".res"):
		var file := File.new()
		var error = file.open(path, File.READ)
		if error != OK:
			return
		
		_on_Add_pressed()
		$HBoxContainer/Boards.get_child($HBoxContainer/Boards.get_child_count() - 1).text = path.get_file()
		$VBoxContainer/Stats/ProjName.text = path.get_file()
		
		data = file.get_var()
		for info in data:
			handle_loading(info)
		file.close()


func handle_loading(info :Dictionary):
	if info.type == "image_task":
		var new_task = preload("res://src/tasks/ImageTask.tscn").instance()
		current_board.add_child(new_task)
		new_task.start(info)
	if info.type == "checkbox_task":
		var new_task = preload("res://src/tasks/CheckboxTask.tscn").instance()
		current_board.add_child(new_task)
		new_task.start(info)
	if info.type == "audio_task":
		var new_task = preload("res://src/tasks/AudioTask.tscn").instance()
		current_board.add_child(new_task)
		new_task.start(info)
	if info.type == "note_task":
		print("f")
		var new_task = preload("res://src/tasks/NoteTask.tscn").instance()
		current_board.add_child(new_task)
		new_task.start(info)
	if info.type == "link_task":
		var new_task = preload("res://src/tasks/LinkTask.tscn").instance()
		current_board.add_child(new_task)
		new_task.start(info)


func _on_RightMenu_mouse_exited():
	mouse_inside_menu = false


func _on_RightMenu_mouse_entered():
	mouse_inside_menu = true


func _on_Add_pressed():
	var button = preload("res://src/UI/Board Button.tscn").instance()
	$HBoxContainer/Boards.add_child(button)
	button.text = str("Board ", button.get_index()+1)
	button.connect("switch", self, "Switch_board")
	var new_graph = preload("res://src/UI/GraphEdit.tscn").instance()
	$VBoxContainer.add_child(new_graph)
	$VBoxContainer.move_child(new_graph, new_graph.get_index() - 1)
	Switch_board(button.get_index())


func Switch_board(idx):
	for child in $VBoxContainer.get_children():
		if child.get_class() == "GraphEdit":
			child.visible = (child.get_index() == (idx + 1))
			if child.get_index() == (idx + 1):
				current_board = child
				$VBoxContainer/Stats/ProjName.text = $HBoxContainer/Boards.get_child(idx).text
				total_completed = 0
				completed = 0
				for task in child.get_children():
					if task.get_class() == "GraphNode" && task.information.type == "checkbox_task":
						total_completed += task.total_checks
						completed += task.checked_boxes
				update_completed()

func _on_Delete_pressed():
	var idx = current_board.get_index()
	if idx != 1:
		current_board.queue_free()
		$HBoxContainer/Boards.get_child(idx - 1).queue_free()
		current_board = $VBoxContainer.get_child(idx - 1)
		Switch_board(idx - 2)


func _on_MoveUp_pressed():
	var idx = current_board.get_index()
	if idx != 1:
		$HBoxContainer/Boards.move_child($HBoxContainer/Boards.get_child(idx - 1), idx - 2)
		$VBoxContainer.move_child(current_board, idx - 1)


func _on_MoveDown_pressed():
	var idx = current_board.get_index()
	if idx != $VBoxContainer.get_child_count() - 2:
		$HBoxContainer/Boards.move_child($HBoxContainer/Boards.get_child(idx - 1), idx)
		$VBoxContainer.move_child(current_board, idx + 1)


func _on_SaveBoard_pressed():
	$SaveBoard.popup_centered()


func _on_OpenBoard_pressed():
	$OpenBoard.popup_centered()



