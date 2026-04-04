extends Node

signal score_changed(new_score: int)
signal health_changed(new_health: int)

var score: int = 0:
	set(value):
		score = value
		score_changed.emit(score)

var health: int = 100:
	set(value):
		health = clamp(value, 0, 100)
		health_changed.emit(health)

func add_points(points: int):
	score += points

func reset_score():
	score = 0

func set_health(new_health : int):
	health = new_health

func reset_health():
	health = 100
