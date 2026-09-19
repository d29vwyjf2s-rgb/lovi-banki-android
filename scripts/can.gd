extends Area2D

@export var fall_speed := 350.0

func _process(delta):
	position.y += fall_speed * delta

	if position.y > get_viewport_rect().size.y + 100:
		queue_free()
