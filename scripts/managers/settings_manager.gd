extends Node

const SETTINGS_FILE_PATH: String = "user://settings.cfg"

var sfx_index = AudioServer.get_bus_index("SFX")

var _sfx_enabled := true
var _sfx_volume := 100

var sfx_enabled: bool:
	get:
		return _sfx_enabled
	set(value):
		_sfx_enabled = value
		_apply_sfx_settings()

var sfx_volume: int:
	get:
		return _sfx_volume
	set(value):
		_sfx_volume = clamp(value, 0, 100)
		_apply_sfx_settings()

func _ready():
	load_config()

func _apply_sfx_settings():
	if sfx_index == -1:
		return

	AudioServer.set_bus_mute(sfx_index, not _sfx_enabled)

	# převod 0–100 → dB
	var linear = _sfx_volume / 100.0
	var db = linear_to_db(linear)
	AudioServer.set_bus_volume_db(sfx_index, db)

	save_config()

func load_config():
	var config = ConfigFile.new()
	var err = config.load(SETTINGS_FILE_PATH)

	if err != OK:
		sfx_enabled = true
		sfx_volume = 100
		save_config()
	else:
		sfx_enabled = config.get_value("audio", "sfx_enabled", true)
		sfx_volume = config.get_value("audio", "sfx_volume", 100)

func save_config():
	var config = ConfigFile.new()
	config.set_value("audio", "sfx_enabled", sfx_enabled)
	config.set_value("audio", "sfx_volume", sfx_volume)
	config.save(SETTINGS_FILE_PATH)
