extends Node
class_name ProjectileImpact

@onready var animation: AnimatedSprite2D = $Impact
@onready var particles: CPUParticles2D = $Particles

var color: Color = Color("eba54cff")
var particles_color: Color = Color("ffb600")

func _ready():
	animation.modulate = color
	particles.color = particles_color
	animation.play("impact")
	await animation.animation_finished
	queue_free()
