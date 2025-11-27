extends Node2D

@export var texture: Texture2D
@export var scroll_speed: float = 40.0  # pixels per second, positive = scroll left

var sprite1: Sprite2D
var sprite2: Sprite2D
var tex_width: float

func _ready() -> void:
	# Create two sprites using the same texture
	sprite1 = Sprite2D.new()
	sprite2 = Sprite2D.new()
	sprite1.texture = texture
	sprite2.texture = texture

	add_child(sprite1)
	add_child(sprite2)

	tex_width = texture.get_width()

	# Put them side by side
	sprite1.position = Vector2(0, 0)
	sprite2.position = Vector2(tex_width, 0)


func _process(delta: float) -> void:
	var move = scroll_speed * delta

	sprite1.position.x -= move
	sprite2.position.x -= move

	# When a sprite moves completely off the left side, wrap it to the right
	if sprite1.position.x <= -tex_width:
		sprite1.position.x += tex_width * 2.0

	if sprite2.position.x <= -tex_width:
		sprite2.position.x += tex_width * 2.0
