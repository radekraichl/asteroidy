class_name Shield
extends AnimatedSprite2D

@export var score_on_hit : int = 5
@export var shield_color: Color = Color("0f73d2ff")
@export var impact_color: Color = Color("1c8ffdff")
@export var particles_color: Color = Color("41a2ffff")

@onready var collision_shape: CollisionShape2D = %CollisionShape
@onready var _shield_sfx: AudioStreamPlayer2D = $ShieldSFX
@onready var _collision_area: Area2D = $ShieldCollisionArea

var is_active: bool = false
var on_deactivated : Callable

var missile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")
var _shield_timer: Timer

func _ready() -> void:
	_collision_area.area_entered.connect(_on_area_entered)
	self_modulate = shield_color
	set_enabled(false)

	# timer setup
	_shield_timer = Timer.new()
	_shield_timer.one_shot = true
	_shield_timer.timeout.connect(_on_shield_timeout)
	add_child(_shield_timer)

func activate_for(time: float) -> void:
	# zero time protection
	if time <= 0.0:
		_shield_timer.stop()
		set_enabled(false)
		return

	# start timer and shield activation
	_shield_timer.start(time)
	set_enabled(true)

	# play SFX
	_shield_sfx.play()

func _on_shield_timeout() -> void:
	set_enabled(false)
	if on_deactivated:
		on_deactivated.call()

	# disable SFX
	_shield_sfx.stop()

func set_enabled(value: bool):
	is_active = value
	visible = value
	collision_shape.set_deferred("disabled", not value)

func hit(hit_info: HitInfo):
	var impact := missile_impact.instantiate()
	impact.color = impact_color
	impact.particles_color = particles_color
	var estimated_delta = hit_info.delta
	var compensated_pos = to_local(hit_info.position + get_parent().velocity * estimated_delta)
	impact.position = compensated_pos
	add_child(impact)

	# set score
	StatManager.add_points(score_on_hit)

func _on_area_entered(area: Area2D):
	if area.get_collision_layer_value(LayerManager.Layer.PLAYER):
		StatManager.set_health(0)
