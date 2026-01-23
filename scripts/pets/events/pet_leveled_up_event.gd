## PetLeveledUpEvent - Emitted when a pet gains a level
class_name PetLeveledUpEvent
extends DomainEvent


var pet_id: String
var pet_name: String
var new_level: int
var evolved: bool  ## True if this level up triggered evolution


func _init(id: String = "", name: String = "", level: int = 1, did_evolve: bool = false) -> void:
	super._init("PetLeveledUp")
	pet_id = id
	pet_name = name
	new_level = level
	evolved = did_evolve


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["pet_id"] = pet_id
	base["pet_name"] = pet_name
	base["new_level"] = new_level
	base["evolved"] = evolved
	return base
