class_name UFO
extends CharacterBody2D

@export var projectile_damage: int = 20
@export var can_move: bool = true
@export var speed_range: Vector2 = Vector2(90.0, 130.0)
@export var turn_speed: float = 10.0
@export var impact_color: Color = Color("ffe140")

@onready var health: Health = $Health
@onready var explosion: AnimatedSprite2D = $Explosion
@onready var body_collision: CollisionShape2D = $Body
@onready var dome_collision: CollisionShape2D = $Dome
@onready var explosion_sfx : AudioStreamPlayer2D = $ExplosionSFX

@onready var _shield: Shield = $Shield

var direction: Vector2 = Vector2.RIGHT
var speed: float
var target_direction: Vector2 = Vector2.RIGHT
var target_speed: float

var missile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")

var _movement_timer: Timer = Timer.new()
var _shooting_timer: Timer = Timer.new()
var _start_movement_timer = _start_random_timer.bind(_movement_timer, 2, 4)
var _start_shooting_timer = _start_random_timer.bind(_shooting_timer, 1, 1)

func _ready() -> void:
	explosion.visible = false
	speed = speed_range.x
	target_speed = speed_range.x

	# setup movement timer
	_movement_timer.one_shot = true
	_movement_timer.timeout.connect(_on_ufo_movement_tick)
	add_child(_movement_timer)
	_start_movement_timer.call()

	# setup shooting timer
	_shooting_timer.one_shot = true
	_shooting_timer.timeout.connect(_on_ufo_shooting_tick)
	add_child(_shooting_timer)
	_start_shooting_timer.call()

	# helath callback
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

	# shield deactivated callback
	_shield.on_deactivated = _on_shield_deactivated

	set_shield_active(10)

func _physics_process(delta: float) -> void:
	direction = direction.lerp(target_direction, turn_speed * delta).normalized()
	speed = lerp(speed, target_speed, turn_speed * delta)

	if can_move:
		velocity = direction * speed
		move_and_collide(velocity * delta)

func hit(hit_info: HitInfo) -> void:
	# health
	if hit_info.source is Projectile:
		health.take_damage(projectile_damage)

	# impact
	var impact := missile_impact.instantiate()
	impact.color = impact_color
	impact.position = to_local(hit_info.position)
	add_child(impact)

func set_shield_active(time: float) -> void:
	_shield.set_active(time)
	disable_collisions(true)

func disable_collisions(value: bool):
	body_collision.disabled = value
	dome_collision.disabled = value

func _start_random_timer(timer: Timer, min_t, max_t) -> void:
	timer.wait_time = randf_range(min_t, max_t)
	timer.start()

func _on_ufo_movement_tick() -> void:
	var random_angle: float = randf_range(45, 60)
	if randf() > 0.5:
		random_angle = -random_angle
	target_direction = direction.rotated(deg_to_rad(random_angle))
	target_speed = randf_range(speed_range.x, speed_range.y)
	_start_movement_timer.call()

func _on_ufo_shooting_tick() -> void:
	_start_shooting_timer.call()

func _on_died():
	can_move = false
	disable_collisions(true)
	$Sprite2D.visible = false
	explosion.visible = true
	explosion.play("explode")
	explosion_sfx.play()

	remove_child(explosion_sfx)
	get_tree().root.add_child(explosion_sfx)
	explosion_sfx.finished.connect(explosion_sfx.queue_free)

	await explosion.animation_finished
	queue_free()

func _on_shield_deactivated() -> void:
	disable_collisions(false)

func _on_health_changed(_current_hp, _max_hp):
	pass
