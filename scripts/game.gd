extends Control

var rocks := 0
var osuSpawned := false
var OsuScene = preload("res://scenes/osu_point.tscn")
var rockScene = preload("res://scenes/rock.tscn")
var osuParticles = preload("res://scenes/osu_hit_particles.tscn")
var gameOverScene = preload("res://scenes/game_over_screen.tscn")
var rng = RandomNumberGenerator.new()
var gameOver := false
var combo := 1
@onready var scoreLabel := $Score
@onready var timeLabel := $Time
@onready var comboLabel := $Combo
@onready var timer := $Timer
@onready var audioPlayer := $AudioStreamPlayer
@onready var osuRockSound := $osuRockSound #https://pixabay.com/sound-effects/rock-destroy-6409/
@onready var fallingRockSound := $fallingRocks #https://pixabay.com/sound-effects/tumbling-rocks-97910/

func _ready() -> void:
	audioPlayer.play()

func _unhandled_input(event: InputEvent) -> void:
	if gameOver:
		return
	
	if event is InputEventMouseButton and event.is_pressed():
		rocks += 1
		combo = 1
		spawnRock()

func _process(delta: float) -> void:
	scoreLabel.text = str(rocks)	
	timeLabel.text = str(round(timer.time_left))
	comboLabel.text = str(combo)
	
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

func spawnRock( osu_position:Vector2 = Vector2(), count:int = 1) -> void:
	for i in count:
		var x_offset = rng.randf_range(-50,50)
		var y_offset = rng.randf_range(-50,50)
		var new_rock = rockScene.instantiate()
		
		#have them spawn facing left or right
		if rng.randi()%2 == 0:
			new_rock.get_node("Sprite2D").scale.x = -1
		
		if osu_position != Vector2():
			new_rock.global_position = Vector2(osu_position.x + x_offset, osu_position.y + y_offset)
		else:
			var x = rng.randf_range(100,700)
			var y = rng.randf_range(100,500)
			new_rock.global_position = Vector2(x,y)
		
		add_child(new_rock)

func _on_osu_point_pressed(osu_instance:Node) -> void:
	if gameOver:
		return
	rocks += 2 * combo
	spawnRock(osu_instance.global_position, 2*combo)
	combo += 1
	
	osuRockSound.play()
	spawnOsuHitParticles(osu_instance.global_position)
	
	osu_instance.queue_free()
	osuSpawned = false

func spawnOsuHitParticles(pos:Vector2) -> void:
	var p := osuParticles.instantiate()
	add_child(p)
	p.global_position = pos

func _on_timer_timeout() -> void:
	gameOver = true
	var GO_screen = gameOverScene.instantiate()
	GO_screen
	add_child(GO_screen)
