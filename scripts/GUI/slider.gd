extends HSlider

@export var value_label: Label
@export var slider_move_sfx: AudioStream
@export var sfx_volume_db: float = 0.0
@export var sfx_pitch_scale: float = 1.0

func _ready() -> void:
	value_changed.connect(_on_value_changed)
	_update_label()

func _on_value_changed(_value: float) -> void:
	_update_label()
	if is_visible_in_tree():
		SfxManager.play(slider_move_sfx, sfx_volume_db, sfx_pitch_scale)

func _update_label() -> void:
	if value_label:
		value_label.text = str(int(value))
