extends CanvasLayer

@onready var fade_panel: FadePanel = $FadePanel

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	fade_panel.set_faded()
	fade_panel.fade_out()

func change_scene(scene_path: String, fade_duration: float = -1.0) -> void:
	fade_panel.fade_in(fade_duration)
	await fade_panel.fade_finished

	var error := get_tree().change_scene_to_file(scene_path)
	if error != OK:
		push_error("Failed to change scene to: %s (error %d)" % [scene_path, error])
		fade_panel.fade_out(fade_duration)
		return

	fade_panel.fade_out(fade_duration)
