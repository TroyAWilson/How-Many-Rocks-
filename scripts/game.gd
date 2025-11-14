extends Control

var rocks := 0
var osuSpawned := false
var OsuScene = preload("res://scenes/osu_point.tscn")
var rockScene = preload("res://scenes/rock.tscn")
var osuParticles = preload("res://scenes/osu_hit_particles.tscn")
var rng = RandomNumberGenerator.new()
var gameOver := false
var combo := 1
@onready var scoreLabel := $Score
@onready var timeLabel := $Time
@onready var comboLabel := $Combo
@onready var timer := $Timer

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		rocks += 1
		combo = 1
		spawnRock()

func _process(delta: float) -> void:
	if gameOver:
		return
	
	scoreLabel.text = str(rocks)	
	timeLabel.text = str(round(timer.time_left))
	comboLabel.text = "Combo Multiplier: " + str(combo)
	
	if osuSpawned == false:
		spawnOsu()
	
func spawnOsu():
	var x = rng.randf_range(100,700)
	var y = rng.randf_range(100,500)
	var new_osu = OsuScene.instantiate()
	new_osu.global_position = Vector2(x,y)
	add_child(new_osu)
	new_osu.pressed.connect(_on_osu_point_pressed.bind(new_osu))
	osuSpawned = true

func spawnRock(count:int = 1) -> void:
	for i in count:
		var x = rng.randf_range(100,700)
		var y = rng.randf_range(100,200)
		var new_rock = rockScene.instantiate()
		new_rock.global_position = Vector2(x,y)
		add_child(new_rock)

func _on_osu_point_pressed(osu_instance:Node) -> void:
	rocks += 2 * combo
	spawnRock(2*combo)
	combo += 1
	
	spawnOsuHitParticles(osu_instance.global_position)
	
	osu_instance.queue_free()
	osuSpawned = false

func spawnOsuHitParticles(pos:Vector2) -> void:
	var p := osuParticles.instantiate()
	add_child(p)
	p.global_position = pos

func _on_timer_timeout() -> void:
	print('game over')
	gameOver = true
	get_tree().paused = true


func _on_area_2d_area_entered(area: Area2D) -> void:
	print('area entered')
	print(area)
