extends HTTPRequest


const URL: String = "https://dethcrvsh.com/goatman"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func get_scores(callback):
	request_completed.connect(callback)
	request(URL + "/get_scores")

func new_score(name: String, score: int, level: int, callback):
	request_completed.connect(callback)
	var headers = ["Content-Type: application/json"]

	# Create a dictionary with your POST data
	var post_data = {
		"name": name,
		"score": score,
		"level": level,
		"auth": "if you're a developer, ask dethcrvsh for this, otherwise, eat shit >:D"
	}

	# Convert the dictionary to a JSON string (optional, depends on your API)
	var post_data_json = JSON.stringify(post_data)
	request(URL + "/add_score", headers, HTTPClient.METHOD_POST, post_data_json)

func _on_request_completed(result, response_code, headers, body):
	var json = JSON.parse_string(body.get_string_from_utf8())
	
	
