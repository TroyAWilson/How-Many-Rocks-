extends Parallax2D

func _process(delta: float) -> void:
	autoscroll.x += 25
	print(autoscroll)
