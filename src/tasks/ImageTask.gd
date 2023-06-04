extends GraphNode

onready var image_container = $VBoxContainer/Image
onready var image_options = get_tree().current_scene.get_node("Dialogs/PathOptions")
var opened = false

var information = {
	"type" : "image_task",
	"image_data" : null,
	"position" : offset,
	"size" : rect_size,
	"path" : "",
	"comment" : "Comment..."
}

func start(info):
	var texture = ImageTexture.new()
	if info.image_data != null:
		var image := Image.new()
		image.data = info.image_data
		texture.create_from_image(image)
		image_container.texture = texture

	hint_tooltip = info.comment
	offset = info.position
	_on_ImageTask_resize_request(info.size)
	update_image_size()
	information = info
	opened = true


# Called when the node enters the scene tree for the first time.
func _ready():
	if not opened:
		information.position = (get_tree().current_scene.get_viewport().get_mouse_position() + get_parent().scroll_offset) / get_parent().zoom
		start(information)


func _on_ImageTask_resize_request(new_minsize):
	image_container.rect_min_size.y = 0
	rect_size = new_minsize
	update_image_size()
	information.size = rect_size


func _on_ImageTask_dragged(_from, to):
	information.position = to


func update_image_size():
	image_container.rect_min_size.y = rect_size.y - $VBoxContainer/Options.rect_size.y


func _on_Options_pressed():
	image_options.popup_centered()
	image_options.get_node("VBoxContainer/LineEdit").text = information.path
	image_options.get_node("VBoxContainer/Comment").text = information.comment
	image_options.connect("popup_hide", self, "_On_Option_hide")
	image_options.get_node("Load").connect("pressed", self, "_on_load_pressed")
	image_options.get_node("VBoxContainer/Comment").connect("text_changed", self, "on_comment_changed")


func on_comment_changed():
	information.comment = image_options.get_node("VBoxContainer/Comment").text


func _On_Option_hide():
	image_options.disconnect("popup_hide", self, "_On_Option_hide")
	image_options.get_node("Load").disconnect("pressed", self, "_on_load_pressed")
	image_options.get_node("VBoxContainer/Comment").disconnect("text_changed", self, "on_comment_changed")

	hint_tooltip = information.comment



func _on_load_pressed():
	var text = image_options.get_node("VBoxContainer/LineEdit").text
	information.path = text
	if text.begins_with("https://"):
		var http_request = HTTPRequest.new()
		add_child(http_request)
		http_request.connect("request_completed", self, "_http_request_completed")

		var error = http_request.request(text)
		if error != OK:
			push_error("An error occurred in the HTTP request.")
	else:
		var image := Image.new()
		var err = image.load(text)
		if err == OK:
			information.image_data = image.data
			var texture = ImageTexture.new()
			texture.create_from_image(image)
			image_container.texture = texture


func _http_request_completed(_result, _response_code, _headers, body):
	var image = Image.new()
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

	information.image_data = image.data
	var texture = ImageTexture.new()
	texture.create_from_image(image)

	# Display the image in a TextureRect node.
	image_container.texture = texture


func _on_ImageTask_close_request():
	queue_free()

