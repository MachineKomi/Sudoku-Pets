## RewardCalculator - Domain service for computing XP/Gold rewards
class_name RewardCalculator
extends RefCounted


## XP awarded per correct number placed
const XP_PER_NUMBER := 10

## Base gold rewards by difficulty
const BASE_GOLD := {
	"easy": 50,
	"medium": 100,
	"hard": 200
}

## Bonus multipliers
const NO_MISTAKE_BONUS := 1.5      ## +50% gold for 0 mistakes
const FAST_COMPLETION_BONUS := 1.25  ## +25% gold for under 2 minutes
const FAST_TIME_THRESHOLD := 120.0   ## 2 minutes in seconds


## Calculate rewards for completing a puzzle
func calculate_rewards(difficulty: String, mistakes: int, time_seconds: float, numbers_placed: int) -> Dictionary:
	# Base XP from placing numbers
	var xp := numbers_placed * XP_PER_NUMBER
	
	# Base gold from difficulty
	var base_gold: int = BASE_GOLD.get(difficulty.to_lower(), 50)
	var gold := float(base_gold)
	
	# Apply bonuses
	if mistakes == 0:
		gold *= NO_MISTAKE_BONUS
	
	if time_seconds < FAST_TIME_THRESHOLD:
		gold *= FAST_COMPLETION_BONUS
	
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
