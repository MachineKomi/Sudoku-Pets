## PetCollection - Aggregate managing all owned pets
class_name PetCollection
extends RefCounted


## All owned pets
var pets: Array[Pet] = []

## Currently active companion pet ID
var active_pet_id: String = ""

## Shard inventory: species_id -> count
var shards: Dictionary = {}


## Add a pet to the collection
func add_pet(pet: Pet) -> void:
	pets.append(pet)
	# If first pet, make it active
	if pets.size() == 1:
		active_pet_id = pet.id


## Get pet by ID
func get_pet(pet_id: String) -> Pet:
	for pet in pets:
		if pet.id == pet_id:
			return pet
	return null


## Get the active pet
func get_active_pet() -> Pet:
	return get_pet(active_pet_id)


## Set active pet
func set_active_pet(pet_id: String) -> bool:
	if get_pet(pet_id) != null:
		active_pet_id = pet_id
		return true
	return false


## Get all pets of a specific rarity
func get_pets_by_rarity(rarity: PetRarity.Tier) -> Array[Pet]:
	var result: Array[Pet] = []
	for pet in pets:
		if pet.rarity == rarity:
			result.append(pet)
	return result


## Check if species is already owned
func has_species(species_id: String) -> bool:
	for pet in pets:
		if pet.species_id == species_id:
			return true
	return false


## Get pet by species ID (first owned of that species)
func get_pet_by_species(species_id: String) -> Pet:
	for pet in pets:
		if pet.species_id == species_id:
			return pet
	return null



## Get pet count
func count() -> int:
	return pets.size()


## Add shards for a species
func add_shards(species_id: String, amount: int) -> void:
	shards[species_id] = shards.get(species_id, 0) + amount


## Get shard count for a species
func get_shards(species_id: String) -> int:
	return shards.get(species_id, 0)


## Spend shards
func spend_shards(species_id: String, amount: int) -> bool:
	var current = get_shards(species_id)
	if current >= amount:
		shards[species_id] = current - amount
		return true
	return false


## Serialize for save
func to_dict() -> Dictionary:
	var pet_dicts: Array = []
	for pet in pets:
		pet_dicts.append(pet.to_dict())
	
	return {
		"pets": pet_dicts,
		"active_pet_id": active_pet_id,
		"shards": shards
	}


## Deserialize from save
static func from_dict(data: Dictionary) -> PetCollection:
	var collection := PetCollection.new()
	collection.active_pet_id = data.get("active_pet_id", "")
	collection.shards = data.get("shards", {})
	
	var pet_dicts: Array = data.get("pets", [])
	for pet_dict in pet_dicts:
		collection.pets.append(Pet.from_dict(pet_dict))
	
	return collection
