extends CharacterBody2D

@export var speed := 900.0

func _process(delta):
    var direction := 0.0

    if Input.is_action_pressed("move_left"):
        direction -= 1.0

    if Input.is_action_pressed("move_right"):
        direction += 1.0

    position.x += direction * speed * delta

    var width := get_viewport_rect().size.x
    position.x = clamp(position.x, 100.0, width - 100.0)
