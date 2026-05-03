class_name SettingsMenuState
extends BaseState

const MENU_CHANGE_FADE_DURATION = 0.15

@export var open_close_sfx: AudioStream

@onready var _settings_menu: SettingsMenu = %SettingsMenu

func _ready() -> void:
	_settings_menu.back_requested.connect(_on_settings_menu_back_requested)

func transition_to_main_menu() -> void:
	SfxManager.play(open_close_sfx, -4.0, 1.2)
	var tween = ControlFader.fade_out(_settings_menu)
	await tween.finished
	transition_to(MainMenuState)

func _on_settings_menu_back_requested() -> void:
	transition_to_main_menu()

# ---- State Machine Methods ----
func enter(_msg: Dictionary = {}):
	_settings_menu.visible = true
	var tween = ControlFader.fade_in(_settings_menu)
	await tween.finished

func exit() -> void:
	_settings_menu.visible = false

func unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		transition_to_main_menu()
