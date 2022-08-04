extends Node

var channel_id : String
var channel_info : Dictionary


func _ready():
	yield(OAuth2, "token_recieved")
	get_channel_info(OAuth2.token)


func get_channel_info(token):
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	var request_url := "https://youtube.googleapis.com/youtube/v3/channels?part=snippet&mine=true"
	var headers := [
		"Authorization: Bearer %s" % token,
		"Accept: application/json"
	]
	
	var error = http_request.request(request_url, PoolStringArray(headers))
	if error != OK:
		push_error("ERROR OCCURED @ FUNC get_LiveBroadcastResource() : %s" % error)
		http_request.queue_free()
	
	var response = yield(http_request, "request_completed")
	var response_body = parse_json(response[3].get_string_from_utf8())
	
	return response_body
