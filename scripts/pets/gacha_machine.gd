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
	
	# Handle duplicates - absorption mechanics
	var is_duplicate := collection.has_species(species)
	var events: Array[DomainEvent] = []
	
	if is_duplicate:
		# Get existing pet of this species
		var existing_pet: Pet = collection.get_pet_by_species(species)
		
		# Determine rewards based on duplicate rarity
		var shard_amount: int = 1
		var gold_refund: int = 25  # Base gold refund
		var xp_reward: int = 20    # Base XP reward
		
		# Scale rewards by rarity
		match rarity:
			PetRarity.Tier.UNCOMMON:
				gold_refund = 35
				xp_reward = 30
			PetRarity.Tier.RARE:
				shard_amount = 2
				gold_refund = 50
				xp_reward = 50
			PetRarity.Tier.EPIC:
				shard_amount = 3
				gold_refund = 75
				xp_reward = 80
			PetRarity.Tier.LEGENDARY:
				shard_amount = 5
				gold_refund = 100
				xp_reward = 120
		
		# Rarity upgrade: if duplicate is higher rarity, upgrade existing pet
		var rarity_upgraded: bool = false
		if existing_pet and rarity > existing_pet.rarity:
			existing_pet.rarity = rarity
			rarity_upgraded = true
		
		# Award rewards
		collection.add_shards(species, shard_amount)
		player_progress.add_gold(gold_refund)
		
		# Award XP to existing pet
		if existing_pet:
			existing_pet.add_xp(xp_reward)
		
		return {
			"success": true,
			"is_duplicate": true,
			"species": species,
			"rarity": rarity,
			"shard_amount": shard_amount,
			"gold_refund": gold_refund,
			"xp_reward": xp_reward,
			"rarity_upgraded": rarity_upgraded,
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
			"species": species,
			"rarity": rarity,
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
