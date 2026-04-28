class_name FocusBehavior
extends Control

@export var focus_sfx: AudioStream

var ignore_next_focus_sfx: bool = false

var _buttons: Array
var _using_mouse: bool = true

func _ready() -> void:
	_buttons = _get_all_buttons(self)

	for btn: Button in _buttons:
		btn.mouse_entered.connect(_on_button_mouse_entered.bind(btn))
		btn.focus_entered.connect(_on_button_focus)

func _on_button_mouse_entered(btn: Button) -> void:
	btn.grab_focus()

func _on_button_focus() -> void:
	if ignore_next_focus_sfx:
		ignore_next_focus_sfx = false
		return
	SfxManager.play(focus_sfx, 0.0, 1.45)

func _input(event: InputEvent):
	if event is InputEventMouseMotion:
		_using_mouse = true
		_enable_mouse(true)

	elif event is InputEventKey or event is InputEventJoypadButton:
		_using_mouse = false
		_enable_mouse(false)

func _enable_mouse(enable: bool) -> void:
	var mode := Control.MOUSE_FILTER_STOP if enable else Control.MOUSE_FILTER_IGNORE
	for btn in _buttons:
		btn.mouse_filter = mode

func _get_all_buttons(node: Node) -> Array:
	var result = []
	for child in node.get_children():
		if child is Button:
			result.append(child)
		result += _get_all_buttons(child)
	return result
