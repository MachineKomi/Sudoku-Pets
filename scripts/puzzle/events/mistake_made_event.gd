## MistakeMadeEvent - Emitted when player makes an error
class_name MistakeMadeEvent
extends DomainEvent


## Grid position where mistake was made
var position: Vector2i

## The incorrect number that was placed
var value: int

## Kid-friendly explanation of why it's wrong
var conflict_reason: String


func _init(pos: Vector2i = Vector2i.ZERO, val: int = 0, reason: String = "") -> void:
	super._init("MistakeMade")
	position = pos
	value = val
	conflict_reason = reason


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["position"] = {"x": position.x, "y": position.y}
	base["value"] = value
	base["conflict_reason"] = conflict_reason
	return base
