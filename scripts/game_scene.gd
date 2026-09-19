extends Node2D

const SCREEN_SIZE := Vector2(1920, 1080)
const PLAYER_Y := 865.0
const PLAYER_SPEED := 1100.0

var player_x := 960.0
var score := 0
var lives := 3
var level := 1
var combo := 0
var spawn_timer := 0.0
var cans: Array[Dictionary] = []
var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    queue_redraw()

func _process(delta: float) -> void:
    _update_player(delta)
    _update_cans(delta)
    spawn_timer -= delta
    if spawn_timer <= 0.0:
        _spawn_can()
        spawn_timer = max(0.25, 0.85 - level * 0.045)
    $UI/Score.text = "СЧЁТ: %06d" % score
    $UI/Status.text = "УРОВЕНЬ: %d    %s" % [level, "❤️".repeat(lives)]
    queue_redraw()

func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch and event.pressed:
        player_x = clamp(event.position.x * 1920.0 / get_viewport_rect().size.x, 90.0, 1830.0)
    elif event is InputEventScreenDrag:
        player_x = clamp(event.position.x * 1920.0 / get_viewport_rect().size.x, 90.0, 1830.0)

func _update_player(delta: float) -> void:
    var axis := Input.get_axis("move_left", "move_right")
    player_x = clamp(player_x + axis * PLAYER_SPEED * delta, 90.0, 1830.0)

func _spawn_can() -> void:
    cans.append({
        "pos": Vector2(rng.randf_range(100.0, 1820.0), -60.0),
        "vel": Vector2(rng.randf_range(-80.0, 80.0), rng.randf_range(190.0, 300.0) + level * 18.0),
        "rot": rng.randf_range(-1.5, 1.5)
    })

func _update_cans(delta: float) -> void:
    for i in range(cans.size() - 1, -1, -1):
        cans[i].pos += cans[i].vel * delta
        cans[i].vel.y += 650.0 * delta
        if cans[i].pos.distance_to(Vector2(player_x, PLAYER_Y)) < 105.0:
            score += 10 + combo * 2
            combo += 1
            if combo % 10 == 0:
                level = min(level + 1, 10)
            cans.remove_at(i)
        elif cans[i].pos.y > 1140.0:
            lives -= 1
            combo = 0
            cans.remove_at(i)
            if lives <= 0:
                _restart()

func _restart() -> void:
    score = 0
    lives = 3
    level = 1
    combo = 0
    cans.clear()

func _draw() -> void:
    # Background layers: sky, buildings, ground and play area.
    draw_rect(Rect2(0, 0, SCREEN_SIZE.x, 1080), Color("#111417"))
    draw_rect(Rect2(0, 0, 1920, 760), Color("#20262b"))
    draw_rect(Rect2(0, 610, 1920, 150), Color("#292e32"))
    draw_rect(Rect2(0, 760, 1920, 320), Color("#343638"))

    # Original retro courtyard silhouettes.
    for x in range(0, 1920, 260):
        draw_rect(Rect2(x, 350, 210, 410), Color("#383b3d"))
        for wy in range(390, 690, 70):
            draw_rect(Rect2(x + 35, wy, 42, 30), Color("#62686b"))
            draw_rect(Rect2(x + 125, wy, 42, 30), Color("#62686b"))

    # Street lamps / poles.
    for x in [180.0, 1740.0]:
        draw_line(Vector2(x, 230), Vector2(x, 760), Color("#17191b"), 14.0)
        draw_circle(Vector2(x, 220), 22, Color("#d2b86c"))

    # Ground shadow under player.
    draw_ellipse(Vector2(player_x, 1005), Vector2(115, 24), Color(0,0,0,0.28))

    # Player placeholder, designed to be replaced by the final 3D/4K asset.
    draw_circle(Vector2(player_x, 820), 52, Color("#c9c9c9"))
    draw_rect(Rect2(player_x - 40, 865, 80, 120), Color("#45494d"))
    draw_circle(Vector2(player_x - 36, 1000), 20, Color("#16181a"))
    draw_circle(Vector2(player_x + 36, 1000), 20, Color("#16181a"))

    for can in cans:
        var p: Vector2 = can.pos
        draw_rect(Rect2(p.x - 18, p.y - 34, 36, 68), Color("#d8d8d8"))
        draw_rect(Rect2(p.x - 18, p.y - 4, 36, 18), Color("#d3a62b"))
        draw_circle(p + Vector2(0, -31), 17, Color("#eeeeee"))

func draw_ellipse(center: Vector2, radius: Vector2, color: Color) -> void:
    var points := PackedVector2Array()
    for i in range(32):
        var a := TAU * float(i) / 32.0
        points.append(center + Vector2(cos(a) * radius.x, sin(a) * radius.y))
    draw_colored_polygon(points, color)
