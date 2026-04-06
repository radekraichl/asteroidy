extends Node2D
class_name HealthBonus

@export var heal_bonus: int = 70
@export var impact_color: Color
@export var heal_sfx: AudioStream
@export var explosion_sfx: AudioStream

@onready var _particles: CPUParticles2D = $Particles
@onready var _health: Health = $Health
@onready var _collision: CollisionShape2D = $CollisionArea/CollisionShape
@onready var _sprite: Sprite2D = $BonusSprite
@onready var _sprite_anim: AnimatedSprite2D = $BonusSpriteAnim
@onready var _explosion_anim: AnimatedSprite2D = $ExplosionAnim

var projectile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")

func hit(hit_info: HitInfo) -> void:
	_health.take_damage(hit_info.damage)

	# impact
	var impact: ProjectileImpact = projectile_impact.instantiate()
	impact.color = impact_color
	impact.particles_color = impact_color
	impact.position = to_local(hit_info.position)
	add_child(impact)

func disable() -> void:
	_collision.set_deferred("disabled", true)
	_sprite.visible = false
	_sprite_anim.visible = false

func _ready() -> void:
	_sprite.visible = true
	_particles.one_shot = true
	_particles.emitting = false

	_health.died.connect(_on_died)
	_health.health_changed.connect(_on_health_changed)

func _on_health_changed(new_health: int):
	var damaged: bool = _health.get_health_percentage() <= 50
	_sprite.frame = 1 if damaged else 0

func _on_area_2d_area_entered(area: Area2D) -> void:
	if area.get_collision_layer_value(LayerManager.Layer.SHIP):
		disable()
		var ship: Ship = area.get_parent()
		ship.health.heal(heal_bonus)
		SfxManager.play_2d(heal_sfx, global_position, 3)
		_particles.emitting = true
		await _particles.finished
		queue_free()

func _on_died() -> void:
	disable()
	SfxManager.play_2d(explosion_sfx, global_position, 14)
	_explosion_anim.play()
	await _explosion_anim.animation_finished
	queue_free()
