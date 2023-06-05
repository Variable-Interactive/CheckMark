extends BaseTask

onready var image_container: TextureRect = $VBoxContainer/Image

var image_path = "res://assets/icons/icon.png"


func serialize() -> Dictionary:
	var information = .serialize()
	information["image_data"] = image_container.texture.get_data().data
	information["path"] = image_path
	return information


func deserialize(information) -> void:
	# overrides (information)
	if information.has("image_data"):
		var image_data = information["image_data"]
		if image_data != null:
			var image := Image.new()
			image.data = image_data
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			image_container.texture = texture
	if information.has("path"):
		image_path = information["path"]
	.deserialize(information)


func get_type():
	return "image_task"


func show_options():
	Global.task_options.get_node("VBoxContainer/LineEdit").text = image_path
	Global.task_options.get_node("VBoxContainer/Comment").text = hint_tooltip
	.show_options()


func load_options():
	image_path = Global.task_options.get_node("VBoxContainer/LineEdit").text
	if image_path.begins_with("https://"):
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, "_http_request_completed", [http_request])
		var error = http_request.request(image_path)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	else:
		var image := Image.new()
		var err = image.load(image_path)
		if err == OK:
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			image_container.texture = texture


func _http_request_completed(_result, _response_code, _headers, body, http_node: HTTPRequest):
	http_node.queue_free()
	var image = Image.new()
	# Http images are notorious for having the wrong image extensions
	var error_png = image.load_png_from_buffer(body)
	if error_png != OK:
		var error_jpg = image.load_jpg_from_buffer(body)
		if error_jpg != OK:
			var error_tga = image.load_tga_from_buffer(body)
			if error_tga != OK:
				var error_webp = image.load_webp_from_buffer(body)
				if error_webp != OK:
					var error_bmp = image.load_bmp_from_buffer(body)
					if error_bmp != OK:
						push_error("Couldn't load the image.")

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	# Display the image in a TextureRect node.
	image_container.texture = texture
