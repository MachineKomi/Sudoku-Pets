## PetInstance - A player-owned instance of a pet
class_name PetInstance
extends Resource

@export var id: String = ""  # Unique instance ID
@export var base_data: PetData
@export var custom_name: String = ""  # Player-given name
@export var level: int = 1
@export var xp: int = 0
@export var happiness: int = 100
@export var obtained_date: String = ""


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
