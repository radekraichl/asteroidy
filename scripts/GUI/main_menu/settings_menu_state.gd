class_name SettingsMenuState
extends BaseState

const MENU_CHANGE_FADE_DURATION = 0.15

@onready var _fade_panel: FadePanel = %FadePanel
@onready var _settings_menu: Control = %SettingsMenuControl

# buttons
@onready var _sfx_button: Button = %SFXButton
@onready var _back_button: Button = %BackButton

@onready var _last_focused: Control

func _ready() -> void:
	_back_button.pressed.connect(_on_back_button_pressed)
	_last_focused = _sfx_button

func _on_back_button_pressed() -> void:
	_fade_panel.fade_in(MENU_CHANGE_FADE_DURATION)
	await _fade_panel.fade_finished
	transition_to(MainMenuState)

# State Machine Methods
func enter(_msg: Dictionary = {}):
	_fade_panel.fade_out(MENU_CHANGE_FADE_DURATION)
	_settings_menu.visible = true
	_last_focused.grab_focus()

func exit() -> void:
	_settings_menu.visible = false

func unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		_fade_panel.fade_in(MENU_CHANGE_FADE_DURATION)
		await _fade_panel.fade_finished
		transition_to(MainMenuState)
