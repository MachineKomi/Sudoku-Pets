## PlayerData - Resource storing player progression
class_name PlayerData
extends Resource

signal xp_changed(new_xp: int, new_level: int)
signal gold_changed(new_gold: int)
signal level_up(new_level: int)

@export var xp: int = 0
@export var gold: int = 100  # Start with enough for first gacha pull
@export var level: int = 1
@export var completed_levels: Array[String] = []  # Level IDs
@export var level_stars: Dictionary = {}  # level_id -> stars (1-3)


func add_xp(amount: int) -> void:
	xp += amount
	var xp_needed := xp_for_next_level()
	
	while xp >= xp_needed:
		xp -= xp_needed
		level += 1
		level_up.emit(level)
		xp_needed = xp_for_next_level()
	
	xp_changed.emit(xp, level)


func add_gold(amount: int) -> void:
	gold += amount
	gold_changed.emit(gold)


func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	gold_changed.emit(gold)
	return true


func xp_for_next_level() -> int:
	# 500 XP for level 2, scaling gently
	return int(500 * pow(1.1, level - 1))


func complete_level(level_id: String, stars: int) -> void:
	if level_id not in completed_levels:
		completed_levels.append(level_id)
	
	# Only update stars if better
	var current_stars: int = level_stars.get(level_id, 0)
	if stars > current_stars:
		level_stars[level_id] = stars


func get_level_stars(level_id: String) -> int:
	return level_stars.get(level_id, 0)


func is_level_completed(level_id: String) -> bool:
	return level_id in completed_levels
