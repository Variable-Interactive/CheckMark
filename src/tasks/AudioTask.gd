extends GraphNode


onready var audio_stream = $AudioStreamPlayer2D
onready var play_pause = $VBoxContainer/VBoxContainer/Play
onready var timeline = $VBoxContainer/VBoxContainer/HSlider
onready var audio_options = get_tree().current_scene.get_node("Dialogs/PathOptions")

var audio_path: String = "res://Tutorial/maldita.ogg"

func serialize() -> Dictionary:
	var information = {
		"type" : "audio_task",
		"audio" : audio_path,
		"position" : offset,
		"comment" : hint_tooltip
	}
	return information


func deserialize(information: Dictionary):
	# default values
	audio_stream.stream = path_to_stream(audio_path)
	offset = (
		(
			get_tree().current_scene.get_viewport().get_mouse_position()
			+ get_parent().scroll_offset
		) / get_parent().zoom
	)
	hint_tooltip = "Comment..."

	# overrides (information)
	if information.has("audio"):
		audio_path = information["audio"]
		audio_stream.stream = path_to_stream(audio_path)
	if information.has("position"):
		offset = information["position"]
	if information.has("comment"):
		hint_tooltip = information["comment"]

	if audio_stream.stream != null:
		timeline.editable = true
		play_pause.disabled = false
	else:
		timeline.editable = false
		play_pause.disabled = true


func _input(_event: InputEvent) -> void:
	if not audio_stream.stream_paused:
		timeline.value = audio_stream.get_playback_position()


func _on_AudioStreamPlayer2D_finished():
	play_pause.text = "Play"
	timeline.value = 0


func _on_HSlider_value_changed(value):
	if not audio_stream.playing:
		audio_stream.seek(value)


func _on_AudioTask_close_request():
	queue_free()


func _on_Play_pressed():
	if not audio_stream.playing:
		$VBoxContainer/TextureRect.texture = preload("res://assets/icons/music_2.png")
		audio_stream.play(timeline.value)
		timeline.editable = false
		play_pause.text = "Pause"
	elif audio_stream.stream_paused:
		$VBoxContainer/TextureRect.texture = preload("res://assets/icons/music_2.png")
		audio_stream.stream_paused = false
		audio_stream.play(timeline.value)
		timeline.editable = false
		play_pause.text = "Pause"
	elif not audio_stream.stream_paused:
		$VBoxContainer/TextureRect.texture = preload("res://assets/icons/music_1.png")
		timeline.editable = true
		audio_stream.stream_paused = true
		play_pause.text = "Play"


func _on_Options_pressed():
	audio_options.popup_centered()
	audio_options.get_node("VBoxContainer/LineEdit").text = audio_path
	audio_options.get_node("VBoxContainer/Comment").text = hint_tooltip

	# TODO have some method to auto connest signals to options
	audio_options.connect("popup_hide", self, "_On_Option_hide")
	audio_options.get_node("Load").connect("pressed", self, "_on_load_pressed")
	audio_options.get_node("VBoxContainer/Comment").connect("text_changed", self, "on_comment_changed")


func _on_load_pressed():
	var text :String = audio_options.get_node("VBoxContainer/LineEdit").text
	audio_stream.stream = path_to_stream(text)

	if audio_stream.stream == null:
		timeline.editable = false
		play_pause.disabled = true
	else:
		timeline.max_value = audio_stream.stream.get_length()
		timeline.value = 0
		timeline.editable = true
		play_pause.disabled = false


func on_comment_changed():
	hint_tooltip = audio_options.get_node("VBoxContainer/Comment").text


func _On_Option_hide():
	audio_options.disconnect("popup_hide", self, "_On_Option_hide")
	audio_options.get_node("Load").disconnect("pressed", self, "_on_load_pressed")
	audio_options.get_node("VBoxContainer/Comment").disconnect("text_changed", self, "on_comment_changed")


# Helper Function
func path_to_stream(path):
	var new_stream
	if path.to_lower().ends_with(".ogg"):
		new_stream = AudioStreamOGGVorbis.new()
		var file := File.new()
		var err = file.open(path, file.READ)
		if err == OK:
			var buffer = file.get_buffer(file.get_len())
			new_stream.data = buffer
		file.close()
		return new_stream

	elif path.to_lower().ends_with(".mp3"):
		new_stream = AudioStreamMP3.new()
		var file := File.new()
		var err = file.open(path, file.READ)
		if err == OK:
			var buffer = file.get_buffer(file.get_len())
			new_stream.data = buffer
		file.close()

		return new_stream

	elif path.to_lower().ends_with(".wav"):
		new_stream = AudioStreamSample.new()
		new_stream.format = AudioStreamSample.FORMAT_16_BITS
		var file := File.new()
		var err = file.open(path, file.READ)
		if err == OK:
			var buffer = file.get_buffer(file.get_len())
			new_stream.data = buffer
		file.close()

		return new_stream

	return null
