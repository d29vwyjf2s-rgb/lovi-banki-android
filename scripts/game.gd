extends Node2D

var score: int = 0
var lives: int = 3
var level: int = 1
var combo: int = 0

var player_x: float = 960.0
var spawn_timer: float = 0.0

var cans: Array = []

var rng := RandomNumberGenerator.new()

func _ready() -> void:
    rng.randomize()
    queue_redraw()


func _process(delta: float) -> void:
    handle_input(delta)
    update_cans(delta)
    spawn_timer -= delta

    if spawn_timer <= 0:
        spawn_can()
        spawn_timer = max(0.3, 0.9 - level * 0.05)

    queue_redraw()


func handle_input(delta: float) -> void:
    var direction := Input.get_axis(
        "move_left",
        "move_right"
    )

    player_x += direction * 850.0 * delta
    player_x = clamp(
        player_x,
        100.0,
        1820.0
    )


func spawn_can() -> void:
    var can := {
        "position": Vector2(
            rng.randf_range(100.0, 1820.0),
            -50.0
        ),
        "velocity": Vector2(
            rng.randf_range(-60.0, 60.0),
            rng.randf_range(180.0, 260.0)
            + level * 20.0
        )
    }

    cans.append(can)


func update_cans(delta: float) -> void:

    for i in range(cans.size() - 1, -1, -1):

        cans[i].position += \
            cans[i].velocity * delta

        cans[i].velocity.y += \
            700.0 * delta

        var distance := cans[i].position.distance_to(
            Vector2(player_x, 870.0)
        )

        if distance < 100.0:
            catch_can(i)

        elif cans[i].position.y > 1150.0:
            miss_can(i)


func catch_can(index: int) -> void:

    score += 10 + combo * 2
    combo += 1

    if combo % 10 == 0:
        level = min(level + 1, 10)

    cans.remove_at(index)


func miss_can(index: int) -> void:

    lives -= 1
    combo = 0

    cans.remove_at(index)

    if lives <= 0:
        game_over()


func game_over() -> void:

    score = 0
    lives = 3
    level = 1
    combo = 0
    cans.clear()


func _draw() -> void:

    # Фон
    draw_rect(
        Rect2(0, 0, 1920, 1080),
        Color("#101214")
    )

    # Земля
    draw_rect(
        Rect2(0, 760, 1920, 320),
        Color("#25272A")
    )

    # Атмосферное освещение
    draw_circle(
        Vector2(960, 240),
        260,
        Color(0.18, 0.20, 0.23, 0.25)
    )

    # Персонаж-заглушка
    draw_circle(
        Vector2(player_x, 850),
        50,
        Color("#C6C6C6")
    )

    draw_rect(
        Rect2(
            player_x - 35,
            900,
            70,
            105
        ),
        Color("#45484C")
    )

    # Ноги
    draw_circle(
        Vector2(player_x - 35, 1005),
        18,
        Color("#18191B")
    )

    draw_circle(
        Vector2(player_x + 35, 1005),
        18,
        Color("#18191B")
    )

    # Банки
    for can in cans:

        var position: Vector2 = can.position

        draw_rect(
            Rect2(
                position.x - 18,
                position.y - 34,
                36,
                68
            ),
            Color("#D9D9D9")
        )

        draw_rect(
            Rect2(
                position.x - 18,
                position.y - 5,
                36,
                18
            ),
            Color("#D7A928")
        )

        draw_circle(
            position + Vector2(0, -31),
            18,
            Color("#EEEEEE")
        )

    # Интерфейс
    draw_string(
        ThemeDB.fallback_font,
        Vector2(50, 70),
        "СЧЁТ: %06d" % score,
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        36,
        Color.WHITE
    )

    draw_string(
        ThemeDB.fallback_font,
        Vector2(50, 115),
        "УРОВЕНЬ: %d   ЖИЗНИ: %d   КОМБО: x%d"
        % [level, lives, combo],
        HORIZONTAL_ALIGNMENT_LEFT,
        -1,
        25,
        Color("#DDDDDD")
    )
func _get_player_position() -> Vector2:
    return Vector2(player_x, 850.0)
