## PetAcquiredEvent - Emitted when a new pet is obtained
class_name PetAcquiredEvent
extends DomainEvent


## Unique ID of the new pet
var pet_id: String

## Species of the pet
var species_name: String

## Rarity tier
var rarity: PetRarity.Tier

## How the pet was obtained
var source: String  ## "gacha", "reward", "starter"


func _init(id: String = "", species: String = "", rare: PetRarity.Tier = PetRarity.Tier.COMMON, src: String = "gacha") -> void:
	super._init("PetAcquired")
	pet_id = id
	species_name = species
	rarity = rare
	source = src


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["pet_id"] = pet_id
	base["species_name"] = species_name
	base["rarity"] = rarity
	base["source"] = source
	return base
