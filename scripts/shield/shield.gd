class_name Shield
extends AnimatedSprite2D

@export var shield_color: Color = Color("0f73d2ff")
@export var impact_color: Color = Color("1c8ffdff")
@export var particles_color: Color = Color("41a2ffff")

@onready var collision_shape: CollisionShape2D = %CollisionShape
@onready var _shield_sfx: AudioStreamPlayer2D = $ShieldSFX
@onready var _collision_area: Area2D = $ShieldCollisionArea

var on_deactivated : Callable

var missile_impact: PackedScene = preload("res://scenes/projectile/projectile_impact.tscn")
var _shield_timer: Timer

func _ready() -> void:
	_collision_area.area_entered.connect(_on_area_entered)
	self_modulate = shield_color
	active(false)

	# timer setup
	_shield_timer = Timer.new()
	_shield_timer.one_shot = true
	_shield_timer.timeout.connect(_on_shield_timeout)
	add_child(_shield_timer)

func set_active(time: float) -> void:
	# zero time protection
	if time <= 0.0:
		_shield_timer.stop()
		active(false)
		return

	# start timer and shield activation
	_shield_timer.start(time)
	active(true)

	# play SFX
	_shield_sfx.play()

func _on_shield_timeout() -> void:
	active(false)
	if on_deactivated:
		on_deactivated.call()

	# disable SFX
	_shield_sfx.stop()

func active(value: bool):
	visible = value
	collision_shape.disabled = not value

func hit(hit_info: HitInfo):
	# impact
	var impact := missile_impact.instantiate()
	impact.color = impact_color
	impact.particles_color = particles_color

	impact.position = to_local(hit_info.position)
	add_child(impact)

func _on_area_entered(area: Area2D):
	if area.get_collision_layer_value(LayerManager.Layer.PLAYER):
		StatManager.set_health(0)
