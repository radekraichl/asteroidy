# fade_panel.gd
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

func set_faded() -> void:
	_kill_tween()
	self_modulate.a = 1.0
	visible = true
	_state = FadeState.FADED

func set_clear() -> void:
	_kill_tween()
	self_modulate.a = 0.0
	visible = false
	_state = FadeState.CLEAR

func fade_in(duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = fade_duration
	_kill_tween()
	_state = FadeState.FADING
	visible = true
	_tween = create_tween()
	_tween.tween_property(self, "self_modulate:a", 1.0, duration)
	_tween.finished.connect(func():
		_state = FadeState.FADED
		fade_finished.emit()
	)

func fade_out(duration: float = -1.0) -> void:
	if duration <= 0.0:
		duration = fade_duration
	_kill_tween()
	_state = FadeState.FADING
	_tween = create_tween()
	_tween.tween_property(self, "self_modulate:a", 0.0, duration)
	_tween.finished.connect(func():
		visible = false
		_state = FadeState.CLEAR
		fade_finished.emit()
	)

func _kill_tween() -> void:
	if _tween and _tween.is_running():
		_tween.kill()
	_tween = null
