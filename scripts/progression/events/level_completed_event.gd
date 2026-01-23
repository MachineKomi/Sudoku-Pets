## LevelCompletedEvent - Emitted when a level is finished
class_name LevelCompletedEvent
extends DomainEvent


var level_id: int
var stars: int
var gold_earned: int
var xp_earned: int


func _init(lvl_id: int = 0, star_count: int = 0, gold: int = 0, xp: int = 0) -> void:
	super._init("LevelCompleted")
	level_id = lvl_id
	stars = star_count
	gold_earned = gold
	xp_earned = xp


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["level_id"] = level_id
	base["stars"] = stars
	base["gold_earned"] = gold_earned
	base["xp_earned"] = xp_earned
	return base
