class_name Projectile
extends CharacterBody2D

@export var speed: float = 600.0
@export var damage: int = 10
@export var raycast_length: float = 14.0

@onready var sprite: Sprite2D = $Sprite
@onready var _raycast: RayCast2D = $RayCast2D
@onready var shader: ShaderMaterial = $Sprite.material as ShaderMaterial
@onready var on_screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier

var hit_info: HitInfo = HitInfo.new()

func _ready() -> void:
	_raycast.collide_with_areas = true
	on_screen_notifier.visible = true

func _physics_process(delta):
	velocity = Vector2.UP.rotated(rotation) * speed

	# raycast
	_raycast.target_position = Vector2.UP * (raycast_length + speed * delta)
	_raycast.force_raycast_update()
	if _raycast.is_colliding():
		hit_info.delta = delta
		hit_info.position = _raycast.get_collision_point()
		hit_info.velocity = velocity
		hit_info.source = self
		var object = _raycast.get_collider()
		if object.has_method("hit"):
			object.hit(hit_info)
		queue_free()
		return

	# move and collide
	var collision = move_and_collide(velocity * delta)
	if collision:
		hit_info.angle = collision.get_angle()
		hit_info.position = collision.get_position()
		hit_info.velocity = velocity
		hit_info.source = self

		var object = collision.get_collider()
		if object.has_method("hit"):
			object.hit(hit_info)
		queue_free()
		return

func disable_layer(layer_index: int) -> void:
	set_collision_mask_value(layer_index, false)
	_raycast.set_collision_mask_value(layer_index, false)

func _on_screen_exited():
	queue_free()
