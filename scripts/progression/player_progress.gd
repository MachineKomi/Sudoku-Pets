## PlayerProgress - Aggregate root tracking player journey
class_name PlayerProgress
extends RefCounted


## Player's current level
var player_level: int = 1

## Current XP (resets on level up)
var current_xp: int = 0

## Total XP earned all-time
var total_xp: int = 0

## Available gold for gacha
var gold: int = 0

## Premium gems (DLC rewards only)
var gems: int = 0

## Highest level unlocked on world map
var highest_unlocked_level: int = 1

## Best star ratings per level (level_id -> stars)
var level_stars: Dictionary = {}


## Add XP and handle level ups, returns true if leveled up
func add_xp(amount: int) -> bool:
	current_xp += amount
	total_xp += amount
	
	var xp_needed := _xp_for_next_level()
	var leveled_up := false
	
	while current_xp >= xp_needed:
		current_xp -= xp_needed
		player_level += 1
		leveled_up = true
		xp_needed = _xp_for_next_level()
	
	return leveled_up


## Add gold
func add_gold(amount: int) -> void:
	gold += amount


## Spend gold, returns true if successful
func spend_gold(amount: int) -> bool:
	if gold >= amount:
		gold -= amount
		return true
	return false


## Add gems
func add_gems(amount: int) -> void:
	gems += amount


## Record level completion
func complete_level(level_id: int, stars: int) -> void:
	# Update best stars
	var current_best: int = level_stars.get(level_id, 0)
	if stars > current_best:
		level_stars[level_id] = stars
	
	# Unlock next level if this was the highest
	if level_id >= highest_unlocked_level:
		highest_unlocked_level = level_id + 1


## Get total stars earned
func get_total_stars() -> int:
	var total := 0
	for stars in level_stars.values():
		total += stars
	return total


## XP needed for next level
func _xp_for_next_level() -> int:
	return player_level * 100


## Serialize for save
func to_dict() -> Dictionary:
	return {
		"player_level": player_level,
		"current_xp": current_xp,
		"total_xp": total_xp,
		"gold": gold,
		"gems": gems,
		"highest_unlocked_level": highest_unlocked_level,
		"level_stars": level_stars
	}


## Deserialize from save
static func from_dict(data: Dictionary) -> PlayerProgress:
	var progress := PlayerProgress.new()
	progress.player_level = data.get("player_level", 1)
	progress.current_xp = data.get("current_xp", 0)
	progress.total_xp = data.get("total_xp", 0)
	progress.gold = data.get("gold", 0)
	progress.gems = data.get("gems", 0)
	progress.highest_unlocked_level = data.get("highest_unlocked_level", 1)
	progress.level_stars = data.get("level_stars", {})
	return progress
