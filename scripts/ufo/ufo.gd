class_name UFO
extends CharacterBody2D

@export var projectile_damage: int = 20
@export var can_move: bool = true
@export var speed_range: Vector2 = Vector2(90.0, 130.0)
@export var turn_speed: float = 10.0
@export var impact_color: Color = Color("ffe140")

@onready var health: Health = $Health
@onready var body_collision: CollisionShape2D = $Body
@onready var dome_collision: CollisionShape2D = $Dome
@onready var _explosion_anim: AnimatedSprite2D = $ExplosionAnim
@onready var _explosion_sfx: AudioStreamPlayer2D = $ExplosionSFX
@onready var _ufo_sfx: AudioStreamPlayer2D = $UFOSFX

@onready var _shield: Shield = $Shield

var direction: Vector2 = Vector2.RIGHT
var speed: float
var target_direction: Vector2 = Vector2.RIGHT
var target_speed: float

var _scheduler := RandomEventScheduler.new()
var missile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")

func _ready() -> void:
	_scheduler.name = "UFORandomEventScheduler"
	add_child(_scheduler)

	# play ufo sfx
	_ufo_sfx.play()

	# setup movement timer
	_scheduler.add_event("movement timer", 2, 4, _on_ufo_movement_tick, true)
	# setup shooting timer
	_scheduler.add_event("shooting timer", 0.5, 1, _on_ufo_shooting_tick)
	# setup shield timer
	_scheduler.add_event("shield timer", 8, 10, _on_ufo_shield_tick, true)

	_explosion_anim.visible = false
	speed = speed_range.x
	target_speed = speed_range.x

	# helath callback
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

	# shield deactivated callback
	_shield.on_deactivated = _on_shield_deactivated

func _physics_process(delta: float) -> void:
	direction = direction.lerp(target_direction, 1.0 - exp(-turn_speed * delta)).normalized()
	speed = lerp(speed, target_speed, 1.0 - exp(-turn_speed * delta))

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

func set_shield_active_for(time: float) -> void:
	_shield.activate_for(time)
	disable_collisions(true)

func disable_collisions(value: bool):
	body_collision.disabled = value
	dome_collision.disabled = value

func _on_shield_deactivated() -> void:
	disable_collisions(false)

func _on_ufo_movement_tick() -> void:
	var random_angle: float = randf_range(45, 60)
	if randf() > 0.5:
		random_angle = -random_angle
	target_direction = direction.rotated(deg_to_rad(random_angle))
	target_speed = randf_range(speed_range.x, speed_range.y)

func _on_ufo_shooting_tick() -> void:
	pass

func _on_ufo_shield_tick() -> void:
	set_shield_active_for(randf_range(3, 5))

func _on_died():
	can_move = false
	disable_collisions(true)
	_shield.set_enabled(false)
	$Sprite2D.visible = false
	_explosion_anim.visible = true

	_ufo_sfx.stop()

	_explosion_anim.play("explode")
	_explosion_sfx.play()
	var anim_finished = _explosion_anim.animation_finished
	var sfx_finished = _explosion_sfx.finished
	anim_finished.connect(func(): _explosion_anim.visible = false)
	await anim_finished
	await sfx_finished
	queue_free()

func _on_health_changed(_current_hp, _max_hp):
	pass
