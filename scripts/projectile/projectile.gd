class_name Projectile
extends CharacterBody2D

@export var speed: float = 600.0
@export var bonus_speed: float = 0.0
@export var color: Color = Color("ffffff")
@export var raycast_length: float = 14.0

@onready var sprite: Sprite2D = $Sprite
@onready var _raycast: RayCast2D = $RayCast2D
@onready var shader: ShaderMaterial = $Sprite.material as ShaderMaterial
@onready var on_screen_notifier : VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier

var hit_info: HitInfo = HitInfo.new()

func _ready() -> void:
	on_screen_notifier.visible = true
	sprite.modulate = color
	shader.set_shader_parameter("glow_color", color)

func _physics_process(delta):
	velocity = Vector2.UP.rotated(rotation) * speed

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

	_raycast.target_position = Vector2.UP * (raycast_length + speed * delta)
	if _raycast.is_colliding():
		hit_info.position = _raycast.get_collision_point()
		var object = _raycast.get_collider()
		if object.has_method("hit"):
			object.hit(hit_info)
		queue_free()

func disable_layer(layer_index: int) -> void:
	set_collision_mask_value(layer_index, false)
	_raycast.set_collision_mask_value(layer_index, false)

func _on_screen_exited():
	queue_free()
