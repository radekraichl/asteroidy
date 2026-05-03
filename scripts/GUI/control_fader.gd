class_name ControlFader
extends RefCounted

static func fade_in(control: Control, duration: float = 0.2) -> Tween:
	control.modulate.a = 0.0
	control.show()
	var tween = control.create_tween()
	tween.tween_property(control, "modulate:a", 1.0, duration)
	return tween

static func fade_out(control: Control, duration: float = 0.2) -> Tween:
	var tween = control.create_tween()
	tween.tween_property(control, "modulate:a", 0.0, duration)
	return tween
