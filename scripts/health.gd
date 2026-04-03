class_name Health
extends Node

@export var current_health: int = 100
@export var max_health: int = 100

signal health_changed(current: int, max: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

func _ready() -> void:
	current_health = clamp(current_health, 0, max_health)
	_emit_health_changed()

func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if is_dead():
		return

	current_health -= amount
	current_health = max(current_health, 0)

	damaged.emit(amount)
	_emit_health_changed()

	if current_health == 0:
		died.emit()

func heal(amount: int) -> void:
	if amount <= 0:
		return
	if is_dead():
		return

	current_health += amount
	current_health = min(current_health, max_health)

	healed.emit(amount)
	_emit_health_changed()

func set_max_health(value: int) -> void:
	max_health = max(1, value)
	current_health = clamp(current_health, 0, max_health)
	_emit_health_changed()

func is_dead() -> bool:
	return current_health <= 0

func get_health_percent() -> float:
	return float(current_health) / float(max_health)

func _emit_health_changed() -> void:
	health_changed.emit(current_health, max_health)
