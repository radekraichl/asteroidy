# pause_menu.gd
class_name PauseMenu
extends CanvasLayer

@onready var resume_button := %ResumeButton
@onready var focus_sound: AudioStreamPlayer = $FocusSFX
@onready var open_close_sfx: AudioStreamPlayer = $OpenCloseSFX
@onready var menu_root : Control = $MenuRoot
@onready var settings_root : SettingsMenu = $SettingsMenu
@onready var fade_panel : FadePanel = $FadePanel
@onready var _exit_dialog: ExitDialog = %ExitDialog

enum Screen {
	NONE,
	PAUSED,
	SETTINGS
}

var current_screen : Screen

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	settings_root.back_requested.connect(_on_settings_menu_back_requested)
	fade_panel.set_clear()

func set_screen(screen : Screen):
	current_screen = screen
	match screen:
		Screen.NONE:
			GameManager.set_state(GameManager.GameState.GAME)
			open_close_sfx.play()
			menu_root.hide()
			fade_panel.fade_out()
			await fade_panel.fade_finished
			hide()
			settings_root.hide()
		Screen.PAUSED:
			GameManager.set_state(GameManager.GameState.PAUSED)
			open_close_sfx.play()
			show()
			menu_root.show()
			settings_root.hide()
			if fade_panel.get_state() == fade_panel.FadeState.CLEAR:
				fade_panel.fade_in()
		Screen.SETTINGS:
			menu_root.hide()
			settings_root.show()
			open_close_sfx.play()

func _unhandled_input(event):
	if GameManager.game_state == GameManager.GameState.GAME_OVER:
		return
	if fade_panel.get_state() == fade_panel.FadeState.FADING:
		return
	if not event.is_action_pressed("ui_cancel"):
		return

	# enter pause menu or back one level when pressing ESC key
	match current_screen:
		Screen.NONE:
			set_screen(Screen.PAUSED)
		Screen.PAUSED:
			set_screen(Screen.NONE)
		Screen.SETTINGS:
			set_screen(Screen.PAUSED)

	get_viewport().set_input_as_handled()

func _on_resume_button_pressed():
	set_screen(Screen.NONE)

func _on_settings_button_pressed():
	set_screen(Screen.SETTINGS)

func _on_quit_button_pressed():
	get_tree().quit()

func _on_main_menu_button_pressed() -> void:
	open_close_sfx.play()
	menu_root.hide()
	_exit_dialog.show()
	_exit_dialog.confirmed.connect(func():
		_exit_dialog.hide_on_confirm = false
		SceneManager.change_scene(GameManager.MAIN_MENU_SCENE)
		GameManager.set_state(GameManager.GameState.MAIN_MENU))

	_exit_dialog.canceled.connect(func():
		open_close_sfx.play()
		menu_root.show())

# Handle back action from settings menu
func _on_settings_menu_back_requested() -> void:
	set_screen(Screen.PAUSED)
