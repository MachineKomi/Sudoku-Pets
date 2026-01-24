## PetInstance - A player-owned instance of a pet
## US-G.1: Added XP and leveling system
class_name PetInstance
extends Resource

@export var id: String = ""  # Unique instance ID
@export var base_data: PetData
@export var custom_name: String = ""  # Player-given name
@export var level: int = 1
@export var xp: int = 0
@export var happiness: int = 100
@export var obtained_date: String = ""

## US-G.1: XP scaling constants
const BASE_XP_PER_LEVEL: int = 100
const XP_SCALING_FACTOR: float = 1.15


func get_display_name() -> String:
	if custom_name.is_empty():
		return base_data.display_name if base_data else "Unknown Pet"
	return custom_name


func can_evolve() -> bool:
	if base_data == null:
		return false
	if base_data.evolves_at_level <= 0:
		return false
	return level >= base_data.evolves_at_level and base_data.evolves_into != null


## US-G.1: Add XP to the pet and check for level up
## Returns true if the pet leveled up
func add_xp(amount: int) -> bool:
	xp += amount
	var xp_needed: int = get_xp_for_next_level()
	
	if xp >= xp_needed:
		xp -= xp_needed
		level += 1
		return true  # Leveled up!
	return false


## US-G.1: Get XP required to reach the next level
func get_xp_for_next_level() -> int:
	return int(BASE_XP_PER_LEVEL * pow(XP_SCALING_FACTOR, level - 1))


## US-G.1: Get current XP progress as a percentage (0.0 to 1.0)
func get_xp_progress() -> float:
	var xp_needed: int = get_xp_for_next_level()
	if xp_needed <= 0:
		return 1.0
	return float(xp) / float(xp_needed)


## US-G.1: Serialize pet instance to dictionary for saving
func to_dict() -> Dictionary:
	return {
		"id": id,
		"base_data_id": base_data.id if base_data else "",
		"custom_name": custom_name,
		"level": level,
		"xp": xp,
		"happiness": happiness,
		"obtained_date": obtained_date
	}


## US-G.1: Create pet instance from dictionary (for loading)
static func from_dict(data: Dictionary, pet_registry: Dictionary = {}) -> PetInstance:
	var instance := PetInstance.new()
	instance.id = data.get("id", "")
	instance.custom_name = data.get("custom_name", "")
	instance.level = data.get("level", 1)
	instance.xp = data.get("xp", 0)
	instance.happiness = data.get("happiness", 100)
	instance.obtained_date = data.get("obtained_date", "")
	
	# Try to load base_data from registry if provided
	var base_id: String = data.get("base_data_id", "")
	if not base_id.is_empty() and pet_registry.has(base_id):
		instance.base_data = pet_registry[base_id]
	
	return instance
