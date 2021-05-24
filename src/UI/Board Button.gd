extends Button


signal switch(idx)


func _on_Board_pressed():
	emit_signal("switch", get_index())
