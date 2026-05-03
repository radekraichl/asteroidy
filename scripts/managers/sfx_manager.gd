# SfxManager.gd
# Add to Project > Project Settings > Autoload as "SfxManager"

extends Node

# --- Configuration ---
const MAX_PLAYERS := 24       # Maximum number of simultaneously playing sounds
const DEFAULT_BUS := "SFX"    # Audio bus name (must exist in Audio > Buses, or use "Master")

# ---------------------------------------------
#  Public API
# ---------------------------------------------

## Plays a sound without a world position (UI clicks, global effects, etc.)
func play(stream: AudioStream, volume_db := 0.0, pitch := 1.0) -> AudioStreamPlayer:
	if stream == null:
		push_warning("SfxManager.play: stream is null, skipping playback")
		return null

	var player := _get_player()
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()
	return player

## Plays a positional 2D sound at a given world position
func play_2d(stream: AudioStream, position: Vector2, volume_db := 0.0, pitch := 1.0) -> AudioStreamPlayer2D:
	if stream == null:
		push_warning("SfxManager.play_2d: stream is null, skipping playback")
		return null

	var player := _get_player_2d()
	player.stream = stream
	player.global_position = position
	player.volume_db = volume_db
	player.pitch_scale = pitch
	player.play()
	return player

## Plays a 2D sound with randomized pitch — prevents repetitive sounds from feeling robotic
func play_varied_2d(stream: AudioStream, position: Vector2,
		pitch_min := 0.9, pitch_max := 1.1, volume_db := 0.0) -> AudioStreamPlayer2D:
	if stream == null:
		push_warning("SfxManager.play_varied: stream is null, skipping playback")
		return null

	var pitch := randf_range(pitch_min, pitch_max)
	return play_2d(stream, position, volume_db, pitch)

## Stops all currently playing sounds immediately
func stop_all() -> void:
	for p in get_children():
		if p is AudioStreamPlayer or p is AudioStreamPlayer2D:
			p.stop()

# ---------------------------------------------
#  Internal helpers
# ---------------------------------------------

func _get_player() -> AudioStreamPlayer:
	for p in get_children():
		if p is AudioStreamPlayer and not p.playing:
			return p

	if _count_players() < MAX_PLAYERS:
		return _create_player()

	push_warning("SfxManager: channel pool is full (%d/%d), recycling oldest player" % [_count_players(), MAX_PLAYERS])
	return _recycle_oldest()

func _get_player_2d() -> AudioStreamPlayer2D:
	for p in get_children():
		if p is AudioStreamPlayer2D and not p.playing:
			return p

	if _count_players() < MAX_PLAYERS:
		return _create_player_2d()

	push_warning("SfxManager: 2D channel pool is full (%d/%d), recycling oldest player" % [_count_players(), MAX_PLAYERS])
	return _recycle_oldest_2d()

func _create_player() -> AudioStreamPlayer:
	var p := AudioStreamPlayer.new()
	p.bus = DEFAULT_BUS
	add_child(p)
	return p

func _create_player_2d() -> AudioStreamPlayer2D:
	var p := AudioStreamPlayer2D.new()
	p.bus = DEFAULT_BUS
	add_child(p)
	return p

func _count_players() -> int:
	return get_child_count()

func _recycle_oldest() -> AudioStreamPlayer:
	for p in get_children():
		if p is AudioStreamPlayer:
			p.stop()
			return p
	push_warning("SfxManager: no AudioStreamPlayer found to recycle, creating a new one")
	return _create_player()

func _recycle_oldest_2d() -> AudioStreamPlayer2D:
	for p in get_children():
		if p is AudioStreamPlayer2D:
			p.stop()
			return p
	push_warning("SfxManager: no AudioStreamPlayer2D found to recycle, creating a new one")
	return _create_player_2d()
