## MainMenu - Entry point and main navigation
extends Control

@onready var gold_label: Label = $CenterContainer/ContentPanel/VBox/PlayerInfo/GoldLabel
@onready var level_label: Label = $CenterContainer/ContentPanel/VBox/PlayerInfo/LevelLabel


func _ready() -> void:
	_update_player_info()


func _update_player_info() -> void:
	var gold: int = SaveManager.get_value("player_gold", 100)
	var level: int = SaveManager.get_value("player_level", 1)
	gold_label.text = "🪙 %d" % gold
	level_label.text = "⭐ Level %d" % level


func _on_play_pressed() -> void:
	print("Play button pressed - navigating to World Map")
	get_tree().change_scene_to_file("res://scenes/world_map/world_map_screen.tscn")


func _on_pets_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/pets/pet_screen.tscn")


func _on_settings_pressed() -> void:
	var settings_scene := preload("res://scenes/main/settings_screen.tscn").instantiate()
	add_child(settings_scene)
