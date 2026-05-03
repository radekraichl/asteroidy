class_name ExitDialog
extends CanvasLayer

signal confirmed
signal canceled

@export var hide_on_confirm: bool = true
@export var hide_on_cancel: bool = true

@onready var ok_button: Button = %OKButton
@onready var cancel_button: Button = %CancelButton


func _ready() -> void:
	hide()
	ok_button.pressed.connect(_on_ok_button_pressed)
	cancel_button.pressed.connect(_on_cancel_button_pressed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_close_dialog"):
		_on_cancel_button_pressed()
		get_viewport().set_input_as_handled()

func _on_ok_button_pressed() -> void:
	confirmed.emit()
	if hide_on_confirm:
		hide()

func _on_cancel_button_pressed() -> void:
	canceled.emit()
	if hide_on_cancel:
		hide()
