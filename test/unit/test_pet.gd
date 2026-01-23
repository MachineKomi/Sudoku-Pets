## Tests for Pet and PetCollection
extends GutTest


var _pet: Pet
var _collection: PetCollection


func before_each() -> void:
	_pet = Pet.create("test_cat", PetRarity.Tier.COMMON)
	_collection = PetCollection.new()


func test_pet_creation() -> void:
	assert_eq(_pet.species_id, "test_cat")
	assert_eq(_pet.rarity, PetRarity.Tier.COMMON)
	assert_eq(_pet.level, 1)
	assert_eq(_pet.stage, EvolutionStage.Stage.BABY)
	assert_true(_pet.id.length() > 0, "Should have an ID")


func test_pet_xp_and_level_up() -> void:
	# Level 1 needs 50 XP
	var events := _pet.add_xp(50)
	
	assert_eq(_pet.level, 2, "Should level up to 2")
	assert_eq(events.size(), 1, "Should emit 1 level up event")


func test_pet_evolution_at_level_10() -> void:
	# Add enough XP to reach level 10
	# Level 1->2: 50, 2->3: 100, ... 9->10: 450 = sum(50*n for n in 1..9) = 2250
	var events := _pet.add_xp(2250)
	
	assert_true(_pet.level >= 10, "Should be at least level 10")
	assert_eq(_pet.stage, EvolutionStage.Stage.TEEN, "Should evolve to TEEN")
	
	# Check that one of the events has evolved=true
	var evolved_event_found := false
	for event in events:
		var ev: PetLeveledUpEvent = event
		if ev.evolved:
			evolved_event_found = true
			break
	
	assert_true(evolved_event_found, "Should have evolution event")


func test_pet_happiness_bounds() -> void:
	# Feed should increase happiness
	_pet.happiness = 75
	_pet.feed()
	assert_eq(_pet.happiness, 85, "Feed should add 10")
	
	# Should cap at 100
	_pet.happiness = 95
	_pet.feed()
	assert_eq(_pet.happiness, 100, "Should cap at 100")


func test_pet_never_sad() -> void:
	# Happiness should never go below 50 in our design
	# (Currently no mechanics to decrease it)
	assert_true(_pet.happiness >= 50, "Pet should never be sad")


func test_collection_add_and_get() -> void:
	_collection.add_pet(_pet)
	
	assert_eq(_collection.count(), 1)
	assert_eq(_collection.get_pet(_pet.id), _pet)


func test_collection_first_pet_is_active() -> void:
	_collection.add_pet(_pet)
	
	assert_eq(_collection.active_pet_id, _pet.id, "First pet should be active")
	assert_eq(_collection.get_active_pet(), _pet)


func test_collection_serialization() -> void:
	_collection.add_pet(_pet)
	
	var data := _collection.to_dict()
	var restored := PetCollection.from_dict(data)
	
	assert_eq(restored.count(), 1)
	assert_eq(restored.active_pet_id, _pet.id)
	assert_eq(restored.pets[0].species_id, "test_cat")
