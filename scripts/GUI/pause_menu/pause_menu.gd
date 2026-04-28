extends CanvasLayer
class_name PauseMenu

@onready var resume_button := %ResumeButton
@onready var focus_sound: AudioStreamPlayer = $FocusSFX
@onready var open_close_sfx: AudioStreamPlayer = $OpenCloseSFX
@onready var menu_root : Control = $MenuRoot
@onready var settings_root : Control = $SettingsRoot
@onready var fade_panel : FadePanel = $FadePanel

enum Screen {
	NONE,
	PAUSED,
	SETTINGS
}

var current_screen : Screen
var last_focused : Control

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS

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

			if fade_panel.get_state() == fade_panel.FadeState.CLEAR:
				fade_panel.fade_in()

			menu_root.show()
			settings_root.hide()
			resume_button.grab_focus()
			last_focused = resume_button
		Screen.SETTINGS:
			menu_root.hide()
			settings_root.show()
			settings_root.sfx_button.grab_focus()
			last_focused = settings_root.sfx_button
			open_close_sfx.play()

func _unhandled_input(event):
	var focused := get_viewport().gui_get_focus_owner()
	if focused != last_focused and focused is Button:
		last_focused = focused
		focus_sound.play()

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
