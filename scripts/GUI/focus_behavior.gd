class_name FocusBehavior
extends Control

@export var default_focus: Control
@export var force_default_focus: bool = false
@export var mute_focus_sfx_on_show : bool = true
@export var focus_sfx: AudioStream
@export var focus_sfx_volume_db: float = 0.0
@export var focus_sfx_pitch_scale: float = 1.0

var ignore_next_focus_sfx: bool = false

var _focusables: Array[Control]
var _using_mouse: bool = true
var _last_focus: Control = null

func _ready() -> void:
	_focusables = _get_all_focusables(self)
	for control in _focusables:
		control.mouse_entered.connect(_on_control_mouse_entered.bind(control))
		control.focus_entered.connect(_on_control_focus.bind(control))

	visibility_changed.connect(_on_visibility_changed)
	set_focus()

func set_focus() -> void:
	if mute_focus_sfx_on_show:
		ignore_next_focus_sfx = true

	if not is_visible_in_tree():
		return

	var target: Control = default_focus
	if not force_default_focus and is_instance_valid(_last_focus):
		target = _last_focus

	if is_instance_valid(target):
		target.grab_focus()

func _on_visibility_changed() -> void:
	if visible:
		set_focus()

func _on_control_mouse_entered(control: Control) -> void:
	control.grab_focus()

func _on_control_focus(control: Control) -> void:
	_last_focus = control
	if ignore_next_focus_sfx:
		ignore_next_focus_sfx = false
		return

	SfxManager.play(focus_sfx, focus_sfx_volume_db, focus_sfx_pitch_scale)

func _input(event: InputEvent) -> void:
	if not is_visible_in_tree():
		return

	if event is InputEventMouseMotion:
		_using_mouse = true
		_enable_mouse(true)
	elif event is InputEventKey or event is InputEventJoypadButton:
		_using_mouse = false
		_enable_mouse(false)

func _enable_mouse(enable: bool) -> void:
	var mode := Control.MOUSE_FILTER_STOP if enable else Control.MOUSE_FILTER_IGNORE
	for ctrl in _focusables:
		ctrl.mouse_filter = mode

func _get_all_focusables(node: Node) -> Array[Control]:
	var result: Array[Control] = []

	for child in node.get_children():
		if child is Button or child is Slider:
			result.append(child)
		result.append_array(_get_all_focusables(child))
	return result
