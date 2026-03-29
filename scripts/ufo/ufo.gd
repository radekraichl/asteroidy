class_name UFO
extends CharacterBody2D

const SHIELD_TIMER_NAME = "shield_timer"
const SHOOTING_TIMER_NAME = "shooting_timer"

@export var projectile_damage: int = 20
@export var contact_damage: int  = 50
@export var can_move: bool = true
@export var can_shoot: bool = true
@export var speed_range: Vector2 = Vector2(90.0, 130.0)
@export var turn_speed: float = 10.0
@export var impact_color: Color = Color("ffe140")

# score
@export var score_on_hit : int = 450
@export var max_extra_bonus : int = 90
var destroy_extra_bonus : int

@onready var _ship: Ship = %Ship
@onready var health: Health = $Health
@onready var body_collision: CollisionShape2D = $Body
@onready var dome_collision: CollisionShape2D = $Dome
@onready var _explosion_anim: AnimatedSprite2D = $ExplosionAnim
@onready var _shield: Shield = $Shield
@onready var _wrap: Wrap = $Wrap

# SFX
@onready var _explosion_sfx: AudioStreamPlayer2D = $ExplosionSFX
@onready var _ufo_sfx: AudioStreamPlayer2D = $UFOSFX
@onready var _projectile_sfx: AudioStreamPlayer2D = $ProjectileSFX

var direction: Vector2 = Vector2.RIGHT
var speed: float
var target_direction: Vector2 = Vector2.RIGHT
var target_speed: float

var _scheduler := RandomEventScheduler.new()
var _projectile_scene: PackedScene = preload("res://scenes/projectile/ufo_projectile.tscn")
var missile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")

func _ready() -> void:
	# play ufo sfx
	_ufo_sfx.play()

	# scheduler
	_scheduler.name = "UFORandomEventScheduler"
	add_child(_scheduler)
	# setup movement timer
	_scheduler.add_event("movement timer", _on_ufo_movement_tick, 3, 6, true)
	# setup shooting timer
	_scheduler.add_event(SHOOTING_TIMER_NAME, _on_ufo_shooting_tick, 2, 3, true)
	# setup shield timer
	_scheduler.add_event(SHIELD_TIMER_NAME, _on_ufo_shield_tick, 8, 10)

	# pick an extra bonus
	destroy_extra_bonus = randi_range(0, max_extra_bonus)

	_explosion_anim.visible = false
	speed = speed_range.x
	target_speed = speed_range.x

	# helath callback
	health.died.connect(_on_died)
	health.health_changed.connect(_on_health_changed)

	# shield deactivated callback
	_shield.on_deactivated = _on_shield_deactivated

	_wrap.wrapped.connect(_on_ufo_wrapped)

func _physics_process(delta: float) -> void:
	direction = direction.lerp(target_direction, 1.0 - exp(-turn_speed * delta)).normalized()
	speed = lerp(speed, target_speed, 1.0 - exp(-turn_speed * delta))

	if can_move:
		velocity = direction * speed
		move_and_collide(velocity * delta)

func hit(hit_info: HitInfo) -> void:
	# projectile
	if hit_info.source is Projectile:
		# health
		health.take_damage(projectile_damage)
		# score
		StatManager.add_points(score_on_hit + destroy_extra_bonus)
		# impact
		var impact := missile_impact.instantiate()
		impact.color = impact_color
		impact.position = to_local(hit_info.position)
		add_child(impact)

	# ship
	if hit_info.source is Ship:
		health.take_damage(health.max_health)

func set_shield_active_for(time: float) -> void:
	_shield.activate_for(time)
	disable_collisions(true)

## Disables UFO collisions
func disable_collisions(value: bool):
	body_collision.set_deferred("disabled", value)
	dome_collision.set_deferred("disabled", value)

func _on_shield_deactivated() -> void:
	disable_collisions(false)

func _on_ufo_movement_tick() -> void:
	var random_angle: float = randf_range(60, 120)
	if randf() > 0.5:
		random_angle = -random_angle
	target_direction = direction.rotated(deg_to_rad(random_angle))
	target_speed = randf_range(speed_range.x, speed_range.y)

func _on_ufo_shooting_tick() -> void:
	var min_time := 0.15
	var max_time := 0.25

	if !_scheduler.has_event("shoot"):
		_scheduler.add_event("shoot", _on_ufo_shoot, min_time, max_time, false, 3)

	_scheduler.set_interval("shoot", min_time, max_time, false, randi_range(2, 4))

func _on_ufo_shoot() -> void:
	if StatManager.health <= 0 || not can_shoot:
		return
	if _shield.is_active:
		_scheduler.set_enabled("shoot", false)
		return

	var projectile = _projectile_scene.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = global_position + velocity * get_physics_process_delta_time()
	projectile.speed += velocity.length()
	var dir = (_ship.global_position - global_position).normalized()
	projectile.rotation = Vector2.UP.angle_to(dir)
	projectile.disable_layer(LayerManager.Layer.UFO)
	_projectile_sfx.play()

func _on_ufo_wrapped() -> void:
	# prevents the UFO from continuing to shoot after wrapping
	if _scheduler.has_event("shoot"):
		_scheduler.set_enabled("shoot", false)

func _on_ufo_shield_tick() -> void:
	set_shield_active_for(randf_range(3, 5))

func _on_died() -> void:
	_ufo_sfx.stop()
	_scheduler.remove_event(SHIELD_TIMER_NAME)
	_scheduler.remove_event(SHOOTING_TIMER_NAME)
	can_move = false
	disable_collisions(true)
	_shield.set_enabled(false)
	$Sprite2D.visible = false
	_explosion_anim.visible = true

	_explosion_anim.play("explode")
	_explosion_sfx.play()
	var anim_finished = _explosion_anim.animation_finished
	var sfx_finished = _explosion_sfx.finished
	anim_finished.connect(func(): _explosion_anim.visible = false)
	await anim_finished
	await sfx_finished
	queue_free()

func _on_health_changed(_current_hp, _max_hp) -> void:
	pass
