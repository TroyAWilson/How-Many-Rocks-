extends Control

const SUPABASE_URL := "https://pmcxidwsbqcviuirhkmk.supabase.co/"
const ANON_KEY := 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InBtY3hpZHdzYnFjdml1aXJoa21rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM4MzY1NDEsImV4cCI6MjA3OTQxMjU0MX0.zhWcgytKoYdt_MREYt7OjHGntz8SY-wIqQ49UCXYJcI' #maybe?
var leaderBoardUser = preload("res://scenes/leaderboard_user.tscn")
var default_headers := [
	"apikey: %s" % ANON_KEY,
	"Authorization: Bearer %s" % ANON_KEY,
	"Content-Type: application/json"
]
var lbu

@onready var leaderboard_container := $leaderBoardContainer

func _ready() -> void:
	var gsb = await get_scoreboard()
	write_scoreboard(gsb)
	
func _get_http_request() -> HTTPRequest:
	var http := HTTPRequest.new()
	add_child(http)
	http.accept_gzip = false
	return http

func write_scoreboard(gsb) -> void:
	for i in gsb:
		lbu = leaderBoardUser.instantiate()
		lbu.get_child(0).text = i.username
		lbu.get_child(1).text = str(i.score)
		leaderboard_container.add_child(lbu)

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
			return data.slice(0,25)
		else:
			push_error("Supabase: expected Array, got %s" % typeof(data))
			return []
	else:
		push_error("Supabase HTTP %s: %s" % [response_code, body_text])
		return []

func _on_go_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/opening_menu.tscn")
