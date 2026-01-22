## SaveManager - Handles saving and loading player data
## NOTE: No class_name for autoloads - Godot registers them by their autoload name
extends Node

const SAVE_PATH := "user://save_data.json"

signal save_completed
signal load_completed(success: bool)

var _save_data: Dictionary = {}


func _ready() -> void:
	load_game()


func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(_save_data))
		file.close()
		save_completed.emit()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_save_data = _get_default_save()
		load_completed.emit(false)
		return
	
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file:
		var json := JSON.new()
		var result := json.parse(file.get_as_text())
		file.close()
		
		if result == OK:
			_save_data = json.data
			load_completed.emit(true)
		else:
			_save_data = _get_default_save()
			load_completed.emit(false)


func get_value(key: String, default_value: Variant = null) -> Variant:
	return _save_data.get(key, default_value)


func set_value(key: String, value: Variant) -> void:
	_save_data[key] = value


func _get_default_save() -> Dictionary:
	return {
		"player_xp": 0,
		"player_gold": 100,  # Start with some gold for first gacha pull!
		"player_level": 1,
		"completed_levels": [],
		"owned_pets": [],
		"active_pet_id": "",
		"settings": {
			"music_volume": 1.0,
			"sfx_volume": 1.0,
			"show_hints": true
		}
	}
