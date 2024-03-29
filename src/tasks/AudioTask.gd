extends BaseTask


onready var audio_stream = $AudioStreamPlayer2D
onready var play_pause = $VBoxContainer/VBoxContainer/Play
onready var timeline = $VBoxContainer/VBoxContainer/HSlider

var audio_path: String = "res://Tutorial/maldita.ogg"

var texture_play := preload("res://assets/graphics/misc/music_2.png")
var texture_pause := preload("res://assets/graphics/misc/music_1.png")

func serialize() -> Dictionary:
	var information := .serialize()
	information["audio"] = audio_path
	return information


func deserialize(information: Dictionary) -> void:
	# default values
	audio_stream.stream = path_to_stream(audio_path)

	# overrides (information)
	if information.has("audio"):
		audio_path = information["audio"]
		audio_stream.stream = path_to_stream(audio_path)

	if audio_stream.stream != null:
		timeline.editable = true
		play_pause.disabled = false
	else:
		timeline.editable = false
		play_pause.disabled = true
	.deserialize(information)


func show_options() -> void:
	Global.task_options.get_node("VBoxContainer/LineEdit").text = audio_path
	Global.task_options.get_node("VBoxContainer/Comment").text = hint_tooltip
	.show_options()


func load_options():
	var path :String = Global.task_options.get_node("VBoxContainer/LineEdit").text
	audio_stream.stream = path_to_stream(path)

	if audio_stream.stream == null:
		timeline.editable = false
		play_pause.disabled = true
	else:
		timeline.max_value = audio_stream.stream.get_length()
		timeline.value = 0
		timeline.editable = true
		play_pause.disabled = false


func get_type():
	return "audio_task"


# Audio Task methods
func _input(_event: InputEvent) -> void:
	if not audio_stream.stream_paused:
		timeline.value = audio_stream.get_playback_position()


func _on_AudioStreamPlayer2D_finished():
	play_pause.text = "Play"
	timeline.value = 0


func _on_HSlider_value_changed(value):
	if not audio_stream.playing:
		audio_stream.seek(value)


func _on_Play_pressed():
	if not audio_stream.playing:
		$VBoxContainer/TextureRect.texture = texture_pause
		audio_stream.play(timeline.value)
		timeline.editable = false
		play_pause.text = "Pause"
	elif audio_stream.stream_paused:
		$VBoxContainer/TextureRect.texture = texture_play
		audio_stream.stream_paused = false
		audio_stream.play(timeline.value)
		timeline.editable = false
		play_pause.text = "Pause"
	elif not audio_stream.stream_paused:
		$VBoxContainer/TextureRect.texture = texture_pause
		timeline.editable = true
		audio_stream.stream_paused = true
		play_pause.text = "Play"


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
