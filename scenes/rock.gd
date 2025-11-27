extends RigidBody2D

'''

'''
const ROCK_SOUNDS := [
	preload("res://assets/rocks1.mp3"),
	preload("res://assets/rocks2.mp3"),
	preload("res://assets/rocks3.mp3"),
]
var rng := RandomNumberGenerator.new()

var madeSound = false
@onready var audio := $AudioStreamPlayer

func _ready() -> void:
	rng.randomize()
	
	contact_monitor = true
	max_contacts_reported = 4

func _on_body_entered(body: Node) -> void:
	var chosenSound := rng.randi_range(0, ROCK_SOUNDS.size() - 1)
	if not madeSound:
		print(body)
		madeSound = true
		audio.stream = ROCK_SOUNDS[chosenSound]
		audio.play()
