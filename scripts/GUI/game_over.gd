extends CanvasLayer

func _ready():
	GameManager.game_over.connect(_on_game_over)

func _on_game_over():
	await get_tree().create_timer(0.1).timeout
	show()

func _input(event: InputEvent) -> void:
	if visible:
		if ((event is InputEventKey or event is InputEventJoypadButton)
			and event.pressed
			and not event.is_echo()):
			get_viewport().set_input_as_handled()
			GameManager.reset_game()
