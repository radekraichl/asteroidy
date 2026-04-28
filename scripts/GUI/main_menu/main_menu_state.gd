class_name MainMenuState
extends BaseState

const MENU_ENTER_FADE_DURATION = 0.8
const MENU_EXIT_FADE_DURATION = 0.2
const MENU_CHANGE_FADE_DURATION = 0.15

@onready var _fade_panel: FadePanel = %FadePanel

@onready var _main_menu: Control = %MainMenuControl
@onready var _settings_menu: Control = %SettingsMenuControl

@onready var _new_game_button: Button = %NewGameButton
@onready var _settings_menu_button: Button = %SettingsMenuButton
@onready var _exit_button: Button = %ExitButton

@onready var _last_focused: Control

func _ready() -> void:
	_fade_panel.set_faded()
	_fade_panel.fade_out(MENU_ENTER_FADE_DURATION)
	_exit_button.pressed.connect(_on_exit_button_pressed)
	_settings_menu_button.pressed.connect(_on_settings_button_pressed)
	_last_focused = _new_game_button

func _on_exit_button_pressed() -> void:
	_fade_panel.fade_in(MENU_EXIT_FADE_DURATION)
	await _fade_panel.fade_finished
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	_fade_panel.fade_in(MENU_CHANGE_FADE_DURATION)
	await _fade_panel.fade_finished
	transition_to(SettingsMenuState)

# State Machine Methods
func enter(_msg: Dictionary = {}):
	if _fade_panel.get_state() == _fade_panel.FadeState.FADED:
		_fade_panel.fade_out(MENU_CHANGE_FADE_DURATION)
	_last_focused.grab_focus()
	_main_menu.visible = true
	_settings_menu.visible = false

func exit() -> void:
	_main_menu.visible = false
