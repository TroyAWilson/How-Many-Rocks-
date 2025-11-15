extends GPUParticles2D

func _ready() -> void:
	emitting = true

func _process(delta: float) -> void:
	# When one_shot finishes, emitting becomes false
	if one_shot and !emitting:
		queue_free()
