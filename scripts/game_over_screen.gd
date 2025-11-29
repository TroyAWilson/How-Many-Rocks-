extends Control

'''
Quit doesn't make a lot of sense and errors out when played on web
Should maybe opt to remove the quit button.
'''

#HMR123!@#
const SUPABASE_URL := "https://pmcxidwsbqcviuirhkmk.supabase.co/"
const ANON_KEY := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtY3hpZHdzYnFjdml1aXJoa21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzY1NDEsImV4cCI6MjA3OTQxMjU0MX0.zhWcgytKoYdt_MREYt7OjHGntz8SY-wIqQ49UCXYJcI' #maybe?
var leaderBoardUser = preload("res://scenes/leaderboard_user.tscn")
var leaderBoardUpdated := false
var lbu

@onready var leaderboard_container := $LeaderBoardContainer
@onready var lineEdit := $LineEdit
@onready var submitButton := $LineEdit/submit
@onready var loadingLabel := $Loading
@onready var playerScoreLabel := $PlayerScore

var default_headers := [
	"apikey: %s" % ANON_KEY,
	"Authorization: Bearer %s" % ANON_KEY,
	"Content-Type: application/json"
]

func _ready():
	var gsb = await get_scoreboard()
	write_scoreboard(gsb)
	var playerScore = get_parent().get_node("Score")
	playerScoreLabel.text = "How many rocks? " + str(playerScore.text)
	
			
			
func refresh_leaderboard() -> void:
	#Maybe se loadingLabel to true here?
	loadingLabel.show()
	clear_scoreboard()
	var gsb := await get_scoreboard()	
	write_scoreboard(gsb)
	
	
func clear_scoreboard() -> void:
	for child in leaderboard_container.get_children():
		child.queue_free()
		
func write_scoreboard(gsb) -> void:
	for i in gsb:
		lbu = leaderBoardUser.instantiate()
		lbu.get_child(0).text = i.username
		lbu.get_child(1).text = str(i.score)
		leaderboard_container.add_child(lbu)
	
	loadingLabel.hide()
		
func _get_http_request() -> HTTPRequest:
	var http := HTTPRequest.new()
	add_child(http)
	http.accept_gzip = false
	return http

func get_scoreboard() -> Array:
	var http := _get_http_request()

	var url := "%s/rest/v1/ScoreBoard?select=username,score&order=score.desc" % SUPABASE_URL

	var err := http.request(url, default_headers, HTTPClient.METHOD_GET)
	if err != OK:
		push_error("Supabase request error: %s" % err)
		return []
		
	var result = await http.request_completed
	var response_code : int = result[1]
	var body_bytes : PackedByteArray = result[3]
	var body_text := body_bytes.get_string_from_utf8()
	
	if response_code >= 200 and response_code < 300:
		var data = JSON.parse_string(body_text)
		if typeof(data) == TYPE_ARRAY:
			#var top10 = data.slice(0,10)
			return data.slice(0,10)
		else:
			push_error("Supabase: expected Array, got %s" % typeof(data))
			return []
	else:
		push_error("Supabase HTTP %s: %s" % [response_code, body_text])
		return []

func _on_return_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opening_menu.tscn")

func _on_replay_pressed() -> void:
	get_tree().reload_current_scene()

func post_score(username:String, rocks:int) -> Dictionary:
	var http := _get_http_request()
	var url := "%s/rest/v1/ScoreBoard" % SUPABASE_URL
	
	var payload := {
		"username":username,
		"score":rocks
	}
	
	var json_body := JSON.stringify(payload)
	var headers := default_headers.duplicate()
	headers.append("Prefer:return=representation")
	
	var err := http.request(url, headers, HTTPClient.METHOD_POST, json_body)
	if err != OK:
		push_error("Supabase POST request error: %s" % err)
		return {}
	var results = await http.request_completed
	var response_code : int = results[1]
	var body_bytes : PackedByteArray = results[3]
	var body_text := body_bytes.get_string_from_utf8()
	
	if response_code >= 200 and response_code < 300:
		var data = JSON.parse_string(body_text)
		if typeof(data) == TYPE_ARRAY and data.size() > 0:
			return data[0]
		return {}
	else:
		push_error("Supabase POST HTTP %s" % [response_code, body_text])
		return {}

func _on_submit_pressed() -> void:
	var GAME = get_parent()
	var rocks = GAME.rocks
	var name:String = lineEdit.text.strip_edges()
	name = name.to_upper()
	
	#Ignore if blank
	if name == "":
		return
	
	#insert into table
	var inserted = await post_score(name, rocks)
	
	refresh_leaderboard()
	submitButton.disabled = true
