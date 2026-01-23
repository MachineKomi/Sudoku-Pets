## Pet - Aggregate root for an individual pet instance
## Pets level up, evolve, and are always happy! (never die or get sad)
class_name Pet
extends RefCounted


## Unique identifier
var id: String = ""

## Display name (player can rename)
var nickname: String = ""

## Species identifier (references PetData resource)
var species_id: String = ""

## Rarity tier
var rarity: PetRarity.Tier = PetRarity.Tier.COMMON

## Current level (1-99)
var level: int = 1

## XP toward next level
var current_xp: int = 0

## Happiness (50-100, never drops below 50!)
var happiness: int = 75

## Current evolution stage
var stage: EvolutionStage.Stage = EvolutionStage.Stage.BABY


## XP needed for next level
func xp_for_next_level() -> int:
	return level * 50


## Add XP and handle level ups, returns events
func add_xp(amount: int) -> Array[DomainEvent]:
	var events: Array[DomainEvent] = []
	current_xp += amount
	
	while current_xp >= xp_for_next_level():
		current_xp -= xp_for_next_level()
		level += 1
		
		# Check for evolution
		var new_stage := EvolutionStage.from_level(level)
		var evolved := new_stage.stage != stage
		if evolved:
			stage = new_stage.stage
		
		events.append(PetLeveledUpEvent.new(id, nickname, level, evolved))
	
	return events


## Feed the pet (increases happiness)
func feed() -> void:
	happiness = mini(happiness + 10, 100)


## Play with the pet (increases happiness)
func play() -> void:
	happiness = mini(happiness + 5, 100)


## Get evolution stage object
func get_evolution_stage() -> EvolutionStage:
	return EvolutionStage.new(stage)


## Get dialogue mood based on happiness
func get_mood() -> String:
	if happiness >= 90:
		return "ecstatic"
	elif happiness >= 70:
		return "happy"
	else:
		return "content"  # Never sad!


## Create a new pet
static func create(species: String, rarity_tier: PetRarity.Tier) -> Pet:
	var pet := Pet.new()
	pet.id = str(randi()) + "_" + str(Time.get_ticks_msec())
	pet.species_id = species
	pet.nickname = species.capitalize()  # Default name
	pet.rarity = rarity_tier
	pet.level = 1
	pet.current_xp = 0
	pet.happiness = 75
	pet.stage = EvolutionStage.Stage.BABY
	return pet


## Serialize for save
func to_dict() -> Dictionary:
	return {
		"id": id,
		"nickname": nickname,
		"species_id": species_id,
		"rarity": rarity,
		"level": level,
		"current_xp": current_xp,
		"happiness": happiness,
		"stage": stage
	}


## Deserialize from save
static func from_dict(data: Dictionary) -> Pet:
	var pet := Pet.new()
	pet.id = data.get("id", "")
	pet.nickname = data.get("nickname", "")
	pet.species_id = data.get("species_id", "")
	pet.rarity = data.get("rarity", PetRarity.Tier.COMMON)
	pet.level = data.get("level", 1)
	pet.current_xp = data.get("current_xp", 0)
	pet.happiness = data.get("happiness", 75)
	pet.stage = data.get("stage", EvolutionStage.Stage.BABY)
	return pet
