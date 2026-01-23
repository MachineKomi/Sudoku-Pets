## PuzzleSolvedEvent - Emitted when the puzzle is completed successfully
class_name PuzzleSolvedEvent
extends DomainEvent


## Level ID that was completed
var level_id: int

## Time taken to solve in seconds
var time_taken: float

## Number of mistakes made
var mistakes_made: int

## Difficulty of the puzzle
var difficulty: String


func _init(lvl_id: int = 0, time: float = 0.0, mistakes: int = 0, diff: String = "easy") -> void:
	super._init("PuzzleSolved")
	level_id = lvl_id
	time_taken = time
	mistakes_made = mistakes
	difficulty = diff


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["level_id"] = level_id
	base["time_taken"] = time_taken
	base["mistakes_made"] = mistakes_made
	base["difficulty"] = difficulty
	return base
