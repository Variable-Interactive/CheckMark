extends GraphNode


onready var audio_stream = $AudioStreamPlayer2D
onready var play_pause = $VBoxContainer/VBoxContainer/Play
onready var timeline = $VBoxContainer/VBoxContainer/HSlider
onready var audio_options = get_tree().current_scene.get_node("Dialogs/PathOptions")
var opened

var information = {
	"type" : "audio_task",
	"audio" : "res://Tutorial/maldita.ogg",
	"position" : offset,
	"comment" : "Comment..."
}

# Called when the node enters the scene tree for the first time.
func _ready():
	if not opened:
		information.position = (get_tree().current_scene.get_viewport().get_mouse_position() + get_parent().scroll_offset) / get_parent().zoom
		start(information)


func start(info):
	hint_tooltip = info.comment

	audio_stream.stream = path_to_stream(info.audio)

	offset = info.position
	if audio_stream.stream != null:
		timeline.editable = true
		play_pause.disabled = false
	else:
		timeline.editable = false
		play_pause.disabled = true
	information = info
	opened = true


func _on_AudioTask_dragged(_from, to):
	information.position = to


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
	audio_options.get_node("VBoxContainer/LineEdit").text = information.audio
	audio_options.get_node("VBoxContainer/Comment").text = information.comment

	audio_options.connect("popup_hide", self, "_On_Option_hide")
	audio_options.get_node("Load").connect("pressed", self, "_on_load_pressed")
	audio_options.get_node("VBoxContainer/Comment").connect("text_changed", self, "on_comment_changed")


func on_comment_changed():
	information.comment = audio_options.get_node("VBoxContainer/Comment").text


func _On_Option_hide():
	audio_options.disconnect("popup_hide", self, "_On_Option_hide")
	audio_options.get_node("Load").disconnect("pressed", self, "_on_load_pressed")
	audio_options.get_node("VBoxContainer/Comment").disconnect("text_changed", self, "on_comment_changed")

	hint_tooltip = information.comment


func _on_load_pressed():
	var text :String = audio_options.get_node("VBoxContainer/LineEdit").text
	audio_stream.stream = path_to_stream(text)
	information.audio = text

	print(audio_stream.stream)

	if audio_stream.stream == null:
		timeline.editable = false
		play_pause.disabled = true
	else:
		timeline.max_value = audio_stream.stream.get_length()
		timeline.value = 0
		timeline.editable = true
		play_pause.disabled = false


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
