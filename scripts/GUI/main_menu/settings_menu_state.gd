class_name SettingsMenuState
extends BaseState

const MENU_CHANGE_FADE_DURATION = 0.15

@export var open_close_sfx: AudioStream

@onready var _fade_panel: FadePanel = %FadePanel
@onready var _settings_menu: SettingsMenu = %SettingsMenu

func _ready() -> void:
	_settings_menu.back_requested.connect(_on_settings_menu_back_requested)

func transition_to_main_menu() -> void:
	SfxManager.play(open_close_sfx, -4.0, 1.2)
	_fade_panel.fade_in(MENU_CHANGE_FADE_DURATION)
	await _fade_panel.fade_finished
	transition_to(MainMenuState)

func _on_settings_menu_back_requested() -> void:
	transition_to_main_menu()

# ---- State Machine Methods ----
func enter(_msg: Dictionary = {}):
	_fade_panel.fade_out(MENU_CHANGE_FADE_DURATION)
	_settings_menu.visible = true

func exit() -> void:
	_settings_menu.visible = false

func unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		transition_to_main_menu()
