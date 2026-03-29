class_name Wrap
extends Node

signal wrapped

@export var wrap_margin: float = 0

func _process(_delta: float) -> void:
	var parent_node: Node2D = get_parent() as Node2D
	if parent_node == null:
		return
	var position: Vector2 = parent_node.global_position
	var did_wrap: bool = false

	# Horizontal wrap
	if position.x < -wrap_margin:
		position.x = Setup.screen_width + wrap_margin
		did_wrap = true
	elif position.x > Setup.screen_width + wrap_margin:
		position.x = -wrap_margin
		did_wrap = true

	# Vertical wrap
	if position.y < -wrap_margin:
		position.y = Setup.screen_height + wrap_margin
		did_wrap = true
	elif position.y > Setup.screen_height + wrap_margin:
		position.y = -wrap_margin
		did_wrap = true

	parent_node.global_position = position

	if did_wrap:
		wrapped.emit()
