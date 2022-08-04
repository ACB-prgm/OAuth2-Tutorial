extends Control



onready var google_button = $VBoxContainer/GoogleButton


func _ready():
	OAuth2.connect("token_recieved", self, "_on_OAuth2_token_recieved")


func _on_GoogleButton_pressed():
	OAuth2.authorize()


func _on_GoogleButton_mouse_entered():
	google_button.modulate.a = .5

func _on_GoogleButton_mouse_exited():
	google_button.modulate.a = 1.0

func _on_OAuth2_token_recieved():
	google_button.hide()
	
	var channel_info = yield(YouTubeData.get_channel_info(OAuth2.token), "completed").get("items")[0].get("snippet")
	
	var username = channel_info.get("title")
	$VBoxContainer/Label.set_text("Welcome, %s!" % username)
	
	var img_url = channel_info.get("thumbnails").get("medium").get("url")
	$VBoxContainer/TextureRect.set_texture(yield(download_texture(img_url), "completed"))
	$VBoxContainer/TextureRect.rect_size = Vector2(250, 250)


func download_texture(url):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var error = http_request.request(url)
	if error != OK:
		push_error("An error occurred while downloading Image: %s" % error)
	
	var response = yield(http_request, "request_completed")
	
	var image = Image.new()
	error = image.load_jpg_from_buffer(response[3])
	if error != OK:
		push_error("Couldn't load the image: %s" % error)

	var texture = ImageTexture.new()
	texture.create_from_image(image)
	
	return texture
