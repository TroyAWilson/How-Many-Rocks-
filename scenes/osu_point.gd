extends TextureButton

@export var spritesheet: Texture2D
@export var frame_size := Vector2i(16, 16)
@export var normal_frame_index: int = 0
@export var hover_frame_index: int = 1
@export var pressed_frame_index: int = 2
@export var disabled_frame_index: int = 3

var float_amplitude := 5.0  # how far it moves up/down (pixels)
var float_speed := 2.0      # how fast it bobs
var _t := 0.0
var _base_position: Vector2

func _ready() -> void:
	texture_normal   = make_frame(normal_frame_index)
	texture_hover    = make_frame(hover_frame_index)
	texture_pressed  = make_frame(pressed_frame_index)
	texture_disabled = make_frame(disabled_frame_index)
	_base_position = position  # starting position after spawn

func _process(delta: float) -> void:
	_t += delta
	var offset_y := sin(_t * float_speed) * float_amplitude
	position.y = _base_position.y + offset_y

func make_frame(index: int) -> AtlasTexture:
	var atlas := AtlasTexture.new()
	atlas.atlas = spritesheet

	var cols := spritesheet.get_width() / frame_size.x
	var x := (index % cols) * frame_size.x
	var y := (index / cols) * frame_size.y
	
	atlas.region = Rect2i(x, y, frame_size.x, frame_size.y)
	return atlas
