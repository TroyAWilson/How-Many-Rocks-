extends TextureButton

var float_amplitude := 5.0  # how far it moves up/down (pixels)
var float_speed := 2.0      # how fast it bobs
var _t := 0.0
var _base_position: Vector2

func _ready() -> void:
	_base_position = position  # starting position after spawn

func _process(delta: float) -> void:
	_t += delta
	var offset_y := sin(_t * float_speed) * float_amplitude
	position.y = _base_position.y + offset_y
