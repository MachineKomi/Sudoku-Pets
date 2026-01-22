## PetManager - Manages pet collection and active companion
## NOTE: No class_name for autoloads - Godot registers them by their autoload name
extends Node

signal pet_obtained(pet_data: PetData)
signal pet_leveled_up(pet_data: PetData, new_level: int)
signal active_pet_changed(pet_data: PetData)

var owned_pets: Array[PetInstance] = []
var active_pet: PetInstance = null


func _ready() -> void:
	pass  # Will load from SaveManager


func add_pet(pet_data: PetData) -> PetInstance:
	var instance := PetInstance.new()
	instance.base_data = pet_data
	instance.level = 1
	instance.xp = 0
	instance.id = _generate_pet_id()
	
	owned_pets.append(instance)
	pet_obtained.emit(pet_data)
	
	# If no active pet, make this one active
	if active_pet == null:
		set_active_pet(instance)
	
	return instance


func set_active_pet(pet: PetInstance) -> void:
	active_pet = pet
	active_pet_changed.emit(pet.base_data if pet else null)


func add_xp_to_active_pet(amount: int) -> void:
	if active_pet == null:
		return
	
	active_pet.xp += amount
	var xp_needed := _xp_for_level(active_pet.level + 1)
	
	while active_pet.xp >= xp_needed:
		active_pet.xp -= xp_needed
		active_pet.level += 1
		pet_leveled_up.emit(active_pet.base_data, active_pet.level)
		xp_needed = _xp_for_level(active_pet.level + 1)


func _xp_for_level(level: int) -> int:
	# Simple curve: 100 XP for level 2, scaling up
	return int(100 * pow(1.2, level - 1))


func _generate_pet_id() -> String:
	return str(Time.get_unix_time_from_system()) + "_" + str(randi())
