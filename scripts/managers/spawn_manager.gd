extends Node

@export var spawn : bool = false
@export var min_speed : float = 80.0
@export var max_speed : float = 180.0
@export var asteroid_scene : PackedScene

@onready var spawn_timer = Timer.new()
@onready var asteroid_container : Node2D = %AsteroidContainer

func _ready():
	if (!spawn) : return

	spawn_asteroid()
	spawn_timer.wait_time = 10
	spawn_timer.autostart = true
	spawn_timer.timeout.connect(_on_spawn_timeout)
	add_child(spawn_timer)

func spawn_asteroid():
	# Choose a random screen edge
	var side := randi() % 4
	var position := Vector2.ZERO
	var direction := Vector2.ZERO

	var asteroid := asteroid_scene.instantiate()
	var spawn_margin = asteroid.sprite_size

	match side:
		0: # top
			position.x = randf_range(0, Setup.screen_width)
			position.y = -spawn_margin
			direction = Vector2(randf_range(-0.5, 0.5), 1)

		1: # bottom
			position.x = randf_range(0, Setup.screen_width)
			position.y = Setup.screen_height + spawn_margin
			direction = Vector2(randf_range(-0.5, 0.5), -1)

		2: # left
			position.x = -spawn_margin
			position.y = randf_range(0, Setup.screen_height)
			direction = Vector2(1, randf_range(-0.5, 0.5))

		3: # right
			position.x = Setup.screen_width + spawn_margin
			position.y = randf_range(0, Setup.screen_height)
			direction = Vector2(-1, randf_range(-0.5, 0.5))

	asteroid.position = position
	asteroid.movement_direction = direction.normalized()

	# store container reference for spawning new asteroids on break-up
	asteroid.asteroid_container = asteroid_container

	asteroid_container.add_child(asteroid)

func _on_spawn_timeout():
	spawn_asteroid()
