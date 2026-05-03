# game_manager.gd
extends Node

const GAME_SCENE = "res://scenes/game_scene.tscn"
const MAIN_MENU_SCENE = "res://scenes/gui/main_menu.tscn"

var DEBUG: bool = true
var ship: Ship = null
var game_state: GameState = GameState.GAME

signal state_changed(new_state: GameState)
signal game_over

enum GameState {
	MAIN_MENU,
	GAME,
	GAME_OVER,
	PAUSED
}

func set_state(new_state : GameState):
	if game_state == new_state:
		return

	game_state = new_state
	match game_state:
		GameState.MAIN_MENU:
			enter_main_menu()
		GameState.GAME:
			enter_game()
		GameState.GAME_OVER:
			enter_game_over()
		GameState.PAUSED:
			enter_paused()

	state_changed.emit(game_state)
	# print("GameState: ", game_state)

func enter_main_menu():
	get_tree().paused = false

func enter_game():
	get_tree().paused = false

func enter_paused():
	get_tree().paused = true

func enter_game_over():
	game_over.emit()

func register_ship(_ship: Ship):
	if ship:
		ship.ship_destroyed.disconnect(_onship_destroyed)
	ship = _ship
	ship.ship_destroyed.connect(_onship_destroyed, CONNECT_ONE_SHOT)

func reset_game():
	get_tree().reload_current_scene()
	StatManager.reset_score()
	StatManager.reset_health()
	set_state(GameState.GAME)

func _onship_destroyed():
	ship = null
	set_state(GameState.GAME_OVER)

# ---- DEBUG ----
func _unhandled_input(event: InputEvent) -> void:
	if DEBUG and event is InputEventKey and event.pressed and not event.echo:
		# quit
		if event.keycode == KEY_Q:
			get_tree().quit()
		# reset scene
		if event.keycode == KEY_R:
			reset_game()
