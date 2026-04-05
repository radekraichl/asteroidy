class_name Ship
extends CharacterBody2D

signal ship_destroyed

# movement
@export var max_speed: float = 300
@export var center_screen_position: bool = true
var acceleration := 400
var friction := 100
var is_thrusting : bool
var was_thrusting : bool
var turn_input : float

# rotation
@export var rotation_accel: float = 14.0
@export var rotation_decel: float = 14.0
@export var max_rotation_speed: float = 6.0
var angular_velocity: float = 0.0

# plumes
@onready var plumes : AnimatedSprite2D = $Plumes

# explosion
@onready var explosion : AnimatedSprite2D = $Explosion
@onready var explosion_sfx: AudioStreamPlayer2D = $ExplosionSFX

# projectile
@export var projectile_scene : PackedScene
@export var projectile_sfx : AudioStream

# health
@onready var health: Health = $Health

var hit_info : HitInfo = HitInfo.new()

func _ready():
	GameManager.register_ship(self)
	if center_screen_position:
		position = Vector2(Setup.screen_width / 2, Setup.screen_height / 2)

	health.died.connect(destroy)
	health.health_changed.connect(_on_health_changed)
	_on_health_changed(health.current_health)

func _physics_process(delta: float) -> void:
	if health.is_dead():
		return

	# input
	turn_input = 0.0
	if Input.is_action_pressed("ui_left"):
		turn_input -= 1.0
	if Input.is_action_pressed("ui_right"):
		turn_input += 1.0
	is_thrusting = Input.is_action_pressed("ui_up")

	# angular acceleration
	angular_velocity += turn_input * rotation_accel * delta

	# natural damping
	if turn_input == 0.0:
		angular_velocity = move_toward(
			angular_velocity,
			0.0,
			rotation_decel * delta
		)

	# hard cap
	angular_velocity = clamp(
		angular_velocity,
		-max_rotation_speed,
		max_rotation_speed
	)

	# Apply rotation
	rotation += angular_velocity * delta

	# movement forward based on current rotation
	var direction := Vector2.ZERO
	if is_thrusting:
		direction = Vector2.UP.rotated(rotation)

	# apply acceleration
	velocity += direction * acceleration * delta

	# apply friction when not pressing forward
	if direction == Vector2.ZERO:
		var friction_delta = friction * delta
		if velocity.length() < friction_delta:
			velocity = Vector2.ZERO
		else:
			velocity -= velocity.normalized() * friction_delta

	# maximum speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	move_and_collide(velocity * delta)

	# shoot input
	if Input.is_action_just_pressed("shoot"):
		_shoot()

	# thrusting animation
	if is_thrusting != was_thrusting:
		if is_thrusting:
			plumes.play("thrust")
		else:
			plumes.play("idle")
	was_thrusting = is_thrusting

func _shoot() -> void:
	var projectile = projectile_scene.instantiate()
	projectile.global_position = global_position + velocity * get_physics_process_delta_time()
	projectile.speed += velocity.length()
	projectile.global_rotation = global_rotation
	get_parent().add_child(projectile)
	projectile.disable_layer(LayerManager.Layer.SHIP)
	SfxManager.play_2d(projectile_sfx, global_position)

func _on_area_2d_body_entered(body) -> void:
	_handle_contact(body)
	if body.has_method("hit"):
		hit_info.source = self
		body.hit(hit_info)

func _on_area_2d_area_entered(area: Area2D) -> void:
	_handle_contact(area)

func _handle_contact(object) -> void:
	if "contact_damage" in object:
		health.take_damage(object.contact_damage)

func _on_health_changed(_current_hp):
	StatManager.set_health(_current_hp)

func destroy():
	var sprite = $Sprite
	velocity = Vector2.ZERO
	rotation = 0
	sprite.visible = false
	plumes.visible = false
	explosion.visible = true

	$Area2D/CollisionPolygon2D.set_deferred("disabled", true)
	$CollisionPolygon2D.set_deferred("disabled", true)

	explosion.play("explosion")
	explosion_sfx.play()
	var anim_finished = explosion.animation_finished
	anim_finished.connect(func(): explosion.visible = false)
	var sfx_finished = explosion_sfx.finished
	await anim_finished
	await sfx_finished
	ship_destroyed.emit()
	queue_free()
