## GameManager - Global game state and scene management
## NOTE: No class_name for autoloads - Godot registers them by their autoload name
extends Node

signal scene_changed(scene_name: String)
signal game_paused(is_paused: bool)

enum GameState { MENU, PLAYING, PAUSED, PET_SCREEN, WORLD_MAP }

var current_state: GameState = GameState.MENU
var _is_paused: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS


func change_scene(scene_path: String) -> void:
	get_tree().change_scene_to_file(scene_path)
	scene_changed.emit(scene_path.get_file())


func pause_game() -> void:
	_is_paused = true
	get_tree().paused = true
	game_paused.emit(true)


func resume_game() -> void:
	_is_paused = false
	get_tree().paused = false
	game_paused.emit(false)


func is_paused() -> bool:
	return _is_paused
