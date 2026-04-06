class_name Health
extends Node

@export var current_health: int = 100
@export var max_health: int = 100

signal health_changed(current: int)
signal damaged(amount: int)
signal healed(amount: int)
signal died

func _ready() -> void:
	current_health = clamp(current_health, 0, max_health)
	_emit_health_changed()

## Applies damage to the entity. Ignores non-positive values and dead entities.
func take_damage(amount: int) -> void:
	if amount <= 0:
		return
	if is_dead():
		return
	current_health = max(current_health - amount, 0)
	damaged.emit(amount)
	_emit_health_changed()
	if current_health == 0:
		died.emit()

## Heals the entity, capped at max_health. Ignores non-positive values and dead entities.
func heal(amount: int) -> void:
	if amount <= 0:
		return
	if is_dead():
		return
	current_health = min(current_health + amount, max_health)
	healed.emit(amount)
	_emit_health_changed()

## Sets a new max_health. Clamps current_health to the new maximum.
## Emits died if current_health drops to 0 as a result.
func set_max_health(value: int) -> void:
	max_health = max(1, value)
	current_health = clamp(current_health, 0, max_health)
	_emit_health_changed()
	if current_health == 0:
		died.emit()

## Returns true if the entity has no remaining health.
func is_dead() -> bool:
	return current_health <= 0

## Returns health as a normalized value between 0.0 and 1.0.
func get_health_ratio() -> float:
	return float(current_health) / float(max_health)

## Returns health as a percentage value between 0 and 100.
func get_health_percentage() -> int:
	return int(get_health_ratio() * 100)

func _emit_health_changed() -> void:
	health_changed.emit(current_health)
