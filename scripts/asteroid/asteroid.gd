extends CharacterBody2D
class_name Asteroid

@export var child_asteroid_scene : PackedScene
@export var contact_damage : int
@export var child_count: int
@export var sprite_size : int
@export var speed_range : Vector2
@export var rotation_speed_range : Vector2

@onready var sprite: Sprite2D = $Sprite
@onready var collision : CollisionShape2D = $Collision
@onready var explosion : AnimatedSprite2D = $Explosion
@onready var explosion_sfx : AudioStreamPlayer2D = $ExplosionSFX
@onready var _health: Health = $Health

# score
@export var score_on_hit : int
@export var max_extra_bonus : int

var speed : float
var movement_direction : Vector2
var rotation_speed : float
var dir_multiplier : int

var asteroid_container : Node2D
var has_entered_screen : bool

var missile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")

func _ready():
	if asteroid_container == null:
		asteroid_container = %AsteroidContainer

	# pick a random sprite
	var total_frames = sprite.hframes * sprite.vframes
	sprite.frame = randi() % total_frames
	# pick a random speed
	speed = randf_range(speed_range.x, speed_range.y)
	# pick a random rotation direction
	dir_multiplier = 1 if randi() % 2 == 0 else -1
	# pick a random rotation speed (can rotate clockwise or counter-clockwise)
	rotation_speed = randf_range(rotation_speed_range.x, rotation_speed_range.y) * dir_multiplier

func _physics_process(delta):
	# rotate the asteroid
	rotation += rotation_speed * delta
	# movement
	velocity = movement_direction * speed
	move_and_collide(velocity * delta)

	update_entered_screen()
	if has_entered_screen:
		wrap_position()

func hit(hit_info : HitInfo):
	# pick an extra bonus
	var extra_bonus := randi_range(0, max_extra_bonus)

	if hit_info.source is Ship:
		destroy_asteroid()
		StatManager.add_points((int)(score_on_hit / 4.0 + extra_bonus / 4.0))
		return

	StatManager.add_points(score_on_hit + extra_bonus)

	# impact
	var impact := missile_impact.instantiate()
	impact.position = to_local(hit_info.position)
	add_child(impact)

	# health
	_health.take_damage(hit_info.damage)
	if _health.current_health > 0:
		return

	var spread := deg_to_rad(randf_range(90.0, 100.0))
	var base_angle := hit_info.velocity.angle() + deg_to_rad(randf_range(70.0, 80.0))

	if child_count == 2:
		spread = deg_to_rad(randf_range(80.0, 140.0))
		base_angle = hit_info.velocity.angle() + spread

	for i in child_count:
		if (child_asteroid_scene == null):
			break
		var asteroid := child_asteroid_scene.instantiate()
		var angle := base_angle + spread * i

		asteroid.global_position = global_position
		asteroid.asteroid_container = asteroid_container
		asteroid.movement_direction = Vector2.LEFT.rotated(angle)
		asteroid_container.add_child(asteroid)

	destroy_asteroid()

func destroy_asteroid():
	speed = 0
	rotation_speed = 0
	rotation = 0
	sprite.visible = false
	collision.set_deferred("disabled", true)
	explosion.visible = true
	explosion.play("explode")
	explosion_sfx.play()
	await explosion.animation_finished
	explosion.visible = false
	await explosion_sfx.finished
	queue_free()

func wrap_position():
	if position.x < 0:
		position.x = Setup.screen_width
	elif position.x > Setup.screen_width:
		position.x = 0

	if position.y < 0:
		position.y = Setup.screen_height
	elif position.y > Setup.screen_height:
		position.y = 0

func update_entered_screen():
	if has_entered_screen:
		return

	if position.x > 0 \
	and position.x < Setup.screen_width - 0 \
	and position.y > 0 \
	and position.y < Setup.screen_height - 0:
		has_entered_screen = true
