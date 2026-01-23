## NumberPlacedEvent - Emitted when player places a number on the board
class_name NumberPlacedEvent
extends DomainEvent


## Grid position where number was placed
var position: Vector2i

## The number that was placed (1-9)
var value: int

## Whether this was the correct answer
var is_correct: bool


func _init(pos: Vector2i = Vector2i.ZERO, val: int = 0, correct: bool = false) -> void:
	super._init("NumberPlaced")
	position = pos
	value = val
	is_correct = correct


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["position"] = {"x": position.x, "y": position.y}
	base["value"] = value
	base["is_correct"] = is_correct
	return base
