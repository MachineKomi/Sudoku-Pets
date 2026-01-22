## AudioManager - Handles music and sound effects
## NOTE: No class_name for autoloads - Godot registers them by their autoload name
extends Node

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []

var music_volume: float = 1.0:
	set(value):
		music_volume = clampf(value, 0.0, 1.0)
		if _music_player:
			_music_player.volume_db = linear_to_db(music_volume)

var sfx_volume: float = 1.0:
	set(value):
		sfx_volume = clampf(value, 0.0, 1.0)


func _ready() -> void:
	_setup_audio_players()


func _setup_audio_players() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)
	
	# Pool of SFX players for overlapping sounds
	for i in range(8):
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func play_music(stream: AudioStream, fade_in: float = 0.5) -> void:
	_music_player.stream = stream
	_music_player.volume_db = linear_to_db(music_volume)
	_music_player.play()


func stop_music(fade_out: float = 0.5) -> void:
	_music_player.stop()


func play_sfx(stream: AudioStream) -> void:
	for player in _sfx_players:
		if not player.playing:
			player.stream = stream
			player.volume_db = linear_to_db(sfx_volume)
			player.play()
			return
	
	# All players busy, use first one
	_sfx_players[0].stream = stream
	_sfx_players[0].play()
