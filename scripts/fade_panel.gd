class_name FadePanel
extends ColorRect

@export var fade_duration: float = 0.25

enum FadeState { CLEAR, FADING, FADED }
signal fade_finished

var _tween: Tween
var _state: FadeState = FadeState.CLEAR

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func get_state() -> FadeState:
	return _state

func fade_in(duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = fade_duration

	_kill_tween()
	_state = FadeState.FADING
	visible = true
	modulate.a = 0.0

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, duration)
	_tween.finished.connect(func():
		fade_finished.emit()
		_state = FadeState.FADED
	)

func fade_out(duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = fade_duration

	_kill_tween()
	_state = FadeState.FADING

	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, duration)
	_tween.finished.connect(func():
		visible = false
		fade_finished.emit()
		_state = FadeState.CLEAR
	)

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
