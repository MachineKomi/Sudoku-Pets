## GachaMachine - Domain service for ethical, kid-friendly gacha pulls
## Uses ONLY earned in-game currency (Gold), never real money!
class_name GachaMachine
extends RefCounted


## Cost per single pull
const PULL_COST := 100  # Gold

## Available species per rarity (simplified, would be loaded from data)
const SPECIES_BY_RARITY := {
	PetRarity.Tier.COMMON: ["whisker_cat", "hoot_owl", "fluffy_bunny"],
	PetRarity.Tier.UNCOMMON: ["gobbo", "sparkle_fish", "moon_moth"],
	PetRarity.Tier.RARE: ["sparkle_fox", "crystal_deer", "rainbow_bird"],
	PetRarity.Tier.EPIC: ["fluffdragon", "thunder_lion", "ice_phoenix"],
	PetRarity.Tier.LEGENDARY: ["starlight_kirin", "galaxy_whale", "dream_phoenix"]
}

## Pity counter (guaranteed Rare+ after X pulls without one)
var pity_counter: int = 0
const PITY_THRESHOLD := 10


## Perform a gacha pull
## Returns the Pet and any events, or null if not enough gold
func pull(player_progress: PlayerProgress, collection: PetCollection) -> Dictionary:
	if not player_progress.spend_gold(PULL_COST):
		return {"success": false, "reason": "not_enough_gold"}
	
	# Determine rarity
	var rarity := _roll_rarity()
	
	# Select species
	var species := _select_species(rarity)
	
	# Create pet
	var pet := Pet.create(species, rarity)
	
	# Handle duplicates (bonus XP instead of new pet)
	var is_duplicate := collection.has_species(species)
	var events: Array[DomainEvent] = []
	
	if is_duplicate:
		# Find existing pet and give bonus XP
		for existing_pet in collection.pets:
			if existing_pet.species_id == species:
				var level_events := existing_pet.add_xp(50 * (rarity + 1))
				events.append_array(level_events)
				break
		
		return {
			"success": true,
			"is_duplicate": true,
			"species": species,
			"rarity": rarity,
			"bonus_xp": 50 * (rarity + 1),
			"events": events
		}
	else:
		# Add new pet
		collection.add_pet(pet)
		events.append(PetAcquiredEvent.new(pet.id, species, rarity, "gacha"))
		
		return {
			"success": true,
			"is_duplicate": false,
			"pet": pet,
			"events": events
		}


## Roll for rarity with pity system
func _roll_rarity() -> PetRarity.Tier:
	pity_counter += 1
	
	# Pity system: guaranteed Rare+ after threshold
	if pity_counter >= PITY_THRESHOLD:
		pity_counter = 0
		# Roll between Rare, Epic, Legendary
		var pity_roll := randf() * 100.0
		if pity_roll < 70.0:
			return PetRarity.Tier.RARE
		elif pity_roll < 95.0:
			return PetRarity.Tier.EPIC
		else:
			return PetRarity.Tier.LEGENDARY
	
	# Normal roll
	var roll := randf() * 100.0
	
	if roll < 50.0:
		return PetRarity.Tier.COMMON
	elif roll < 80.0:
		return PetRarity.Tier.UNCOMMON
	elif roll < 95.0:
		pity_counter = 0  # Reset pity on Rare+
		return PetRarity.Tier.RARE
	elif roll < 99.0:
		pity_counter = 0
		return PetRarity.Tier.EPIC
	else:
		pity_counter = 0
		return PetRarity.Tier.LEGENDARY


## Select a random species of the given rarity
func _select_species(rarity: PetRarity.Tier) -> String:
	var species_list: Array = SPECIES_BY_RARITY.get(rarity, ["unknown"])
	return species_list[randi() % species_list.size()]


## Get current pity progress (for UI)
func get_pity_progress() -> int:
	return pity_counter
