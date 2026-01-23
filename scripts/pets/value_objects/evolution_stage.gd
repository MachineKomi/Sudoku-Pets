## EvolutionStage - Value object for pet evolution states
class_name EvolutionStage
extends RefCounted


enum Stage {
	BABY,    ## Level 1-9
	TEEN,    ## Level 10-24
	ADULT,   ## Level 25-49
	MYTHIC   ## Level 50+
}


var stage: Stage


func _init(evolution_stage: Stage = Stage.BABY) -> void:
	stage = evolution_stage


## Get stage from current level
static func from_level(level: int) -> EvolutionStage:
	if level >= 50:
		return EvolutionStage.new(Stage.MYTHIC)
	elif level >= 25:
		return EvolutionStage.new(Stage.ADULT)
	elif level >= 10:
		return EvolutionStage.new(Stage.TEEN)
	else:
		return EvolutionStage.new(Stage.BABY)


## Get display name
func get_name() -> String:
	match stage:
		Stage.BABY:
			return "Baby"
		Stage.TEEN:
			return "Teen"
		Stage.ADULT:
			return "Adult"
		Stage.MYTHIC:
			return "Mythic"
	return "Unknown"


## Get level required for next evolution, or -1 if max
func get_next_evolution_level() -> int:
	match stage:
		Stage.BABY:
			return 10
		Stage.TEEN:
			return 25
		Stage.ADULT:
			return 50
		Stage.MYTHIC:
			return -1
	return -1


## Check if at max evolution
func is_max_evolution() -> bool:
	return stage == Stage.MYTHIC
