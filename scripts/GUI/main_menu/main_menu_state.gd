class_name MainMenuState
extends BaseState

const MENU_EXIT_FADE_DURATION = 0.2
const MENU_CHANGE_FADE_DURATION = 0.15

@export var open_close_sfx: AudioStream

@onready var _main_menu: Control = %MainMenuControl
@onready var _settings_menu: Control = %SettingsMenu
@onready var _fade_panel: FadePanel = %FadePanel

# buttons
@onready var _new_game_button: Button = %NewGameButton
@onready var _settings_menu_button: Button = %SettingsMenuButton
@onready var _exit_button: Button = %ExitButton

func _ready() -> void:
	GameManager.set_state(GameManager.GameState.MAIN_MENU)
	_new_game_button.pressed.connect(_on_new_game_button_pressed)
	_settings_menu_button.pressed.connect(_on_settings_button_pressed)
	_exit_button.pressed.connect(_on_exit_button_pressed)

func _on_new_game_button_pressed() -> void:
	SceneManager.change_scene_packed(GameManager.GAME_SCENE)
	GameManager.set_state(GameManager.GameState.GAME)

func _on_exit_button_pressed() -> void:
	_fade_panel.fade_in(MENU_EXIT_FADE_DURATION)
	await _fade_panel.fade_finished
	get_tree().quit()

func _on_settings_button_pressed() -> void:
	SfxManager.play(open_close_sfx, -4.0, 1.2)
	var tween = ControlFader.fade_out(_main_menu)
	await tween.finished
	transition_to(SettingsMenuState)

# State Machine Methods
func enter(_msg: Dictionary = {}):
	_fade_panel.fade_out(MENU_CHANGE_FADE_DURATION)
	_main_menu.visible = true
	_settings_menu.visible = false
	var tween = ControlFader.fade_in(_main_menu)
	await tween.finished

func exit() -> void:
	_main_menu.visible = false
