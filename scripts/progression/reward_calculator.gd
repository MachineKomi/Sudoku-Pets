## RewardCalculator - Domain service for computing XP/Gold rewards
## US-D.4: Updated with level-based scaling for board completion rewards
class_name RewardCalculator
extends RefCounted


## XP awarded per correct number placed
const XP_PER_NUMBER := 10

## Base gold rewards by difficulty
const BASE_GOLD := {
	"breezy": 30,   # US-E.1: Breezy mode gives less gold
	"easy": 50,
	"normal": 75,   # Added normal difficulty
	"medium": 100,
	"hard": 200
}

## Base XP rewards by difficulty
const BASE_XP := {
	"breezy": 50,
	"easy": 75,
	"normal": 100,
	"medium": 125,
	"hard": 175
}

## Bonus multipliers
const NO_MISTAKE_BONUS := 1.5      ## +50% gold for 0 mistakes
const FAST_COMPLETION_BONUS := 1.25  ## +25% gold for under 2 minutes
const FAST_TIME_THRESHOLD := 120.0   ## 2 minutes in seconds

## US-D.4: Level scaling constants
const LEVEL_GOLD_BONUS_PER_10 := 0.1  ## +10% gold per 10 levels
const LEVEL_XP_BONUS_PER_10 := 0.05   ## +5% XP per 10 levels (slower leveling at higher levels)


## Calculate rewards for completing a puzzle
## US-D.4: Now includes level_id for level-based scaling
func calculate_rewards(difficulty: String, mistakes: int, time_seconds: float, numbers_placed: int, level_id: int = 1) -> Dictionary:
	# Base XP from placing numbers + difficulty bonus
	var base_xp: int = BASE_XP.get(difficulty.to_lower(), 75)
	var xp := numbers_placed * XP_PER_NUMBER + base_xp
	
	# Base gold from difficulty
	var base_gold: int = BASE_GOLD.get(difficulty.to_lower(), 50)
	var gold := float(base_gold)
	
	# Apply bonuses
	if mistakes == 0:
		gold *= NO_MISTAKE_BONUS
		xp = int(xp * 1.25)  # +25% XP for no mistakes
	
	if time_seconds < FAST_TIME_THRESHOLD:
		gold *= FAST_COMPLETION_BONUS
	
	# US-D.4: Apply level-based scaling
	# Higher levels = more rewards but slower leveling
	var level_multiplier: float = 1.0 + (level_id / 10.0) * LEVEL_GOLD_BONUS_PER_10
	gold *= level_multiplier
	
	var xp_multiplier: float = 1.0 + (level_id / 10.0) * LEVEL_XP_BONUS_PER_10
	xp = int(xp * xp_multiplier)
	
	return {
		"xp": xp,
		"gold": int(gold),
		"stars": _calculate_stars(mistakes, time_seconds)
	}


## Calculate star rating
func _calculate_stars(mistakes: int, time_seconds: float) -> int:
	var stars := 1  # Minimum 1 star for completion
	
	if mistakes == 0:
		stars += 1
	
	if time_seconds < FAST_TIME_THRESHOLD:
		stars += 1
	
	return mini(stars, 3)


## Calculate XP needed for next player level
static func xp_for_level(level: int) -> int:
	return level * 100
