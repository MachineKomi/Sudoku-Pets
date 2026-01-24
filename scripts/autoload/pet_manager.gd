## PetManager - Stores persistent state for pets using PetCollection
extends Node

signal collection_updated
signal active_pet_changed(pet: Pet)
signal pet_leveled_up(pet: Pet)

var collection: PetCollection

func _ready() -> void:
	_load()

func _load() -> void:
	var data: Dictionary = SaveManager.get_value("pet_collection", {})
	if data.is_empty():
		collection = PetCollection.new()
		# Add a starter pet for new players
		var starter = Pet.new()
		starter.id = "starter_bunny"
		starter.species_id = "bunny"
		starter.nickname = "Fluffy"
		starter.rarity = PetRarity.Tier.COMMON
		starter.level = 1
		starter.current_xp = 0
		starter.happiness = 100
		collection.add_pet(starter)
		collection.set_active_pet(starter.id)
		save()
	else:
		collection = PetCollection.from_dict(data)


func save() -> void:
	SaveManager.set_value("pet_collection", collection.to_dict())
	SaveManager.save_game()

func get_active_pet() -> Pet:
	return collection.get_active_pet()

func set_active_pet(pet_id: String) -> void:
	if collection.set_active_pet(pet_id):
		save()
		active_pet_changed.emit(collection.get_active_pet())

## Delegate methods to collection
func add_pet(pet: Pet) -> void:
	collection.add_pet(pet)
	save()
	collection_updated.emit()

func add_shards(species: String, amount: int) -> void:
	collection.add_shards(species, amount)
	save()
	collection_updated.emit()

func get_shards(species: String) -> int:
	return collection.get_shards(species)

func spend_shards(species: String, amount: int) -> bool:
	if collection.spend_shards(species, amount):
		save()
		collection_updated.emit()
		return true
	return false

func get_all_pets() -> Array[Pet]:
	return collection.pets
