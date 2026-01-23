## Domain Demo - Demonstrates the DDD event-driven architecture
## Run this scene to see the domain models in action!
extends Node


var _progress: PlayerProgress
var _collection: PetCollection
var _reward_calc: RewardCalculator
var _gacha: GachaMachine
var _dialogue: CompanionDialogueService
var _event_bus: Node


func _ready() -> void:
	# Get EventBus (autoload would be used in real game)
	_event_bus = get_node_or_null("/root/EventBus")
	
	# Initialize domain objects
	_progress = PlayerProgress.new()
	_progress.add_gold(500)  # Give starting gold
	
	_collection = PetCollection.new()
	_reward_calc = RewardCalculator.new()
	_gacha = GachaMachine.new()
	_dialogue = CompanionDialogueService.new()
	
	print("=" * 60)
	print("🎮 SUDOKU PETS - Domain Demo")
	print("=" * 60)
	
	# Run demo scenarios
	_demo_puzzle_completion()
	_demo_gacha_pulls()
	_demo_pet_leveling()
	_demo_companion_dialogue()
	
	print("\n" + "=" * 60)
	print("✅ Demo Complete!")
	print("=" * 60)


func _demo_puzzle_completion() -> void:
	print("\n📊 DEMO 1: Puzzle Completion & Rewards")
	print("-" * 40)
	
	# Simulate completing a puzzle
	var time_taken := 90.0  # 1.5 minutes
	var mistakes := 0
	var numbers_placed := 45  # Half a 9x9 board
	
	# Calculate rewards
	var rewards := _reward_calc.calculate_rewards("medium", mistakes, time_taken, numbers_placed)
	
	print("  Difficulty: Medium")
	print("  Time: %.1f seconds" % time_taken)
	print("  Mistakes: %d" % mistakes)
	print("  Numbers placed: %d" % numbers_placed)
	print("")
	print("  📦 Rewards:")
	print("    XP: +%d" % rewards.xp)
	print("    Gold: +%d" % rewards.gold)
	print("    Stars: %s" % "★".repeat(rewards.stars))
	
	# Apply rewards
	var leveled_up := _progress.add_xp(rewards.xp)
	_progress.add_gold(rewards.gold)
	_progress.complete_level(1, rewards.stars)
	
	print("")
	print("  📈 Player Status:")
	print("    Level: %d (XP: %d/%d)" % [_progress.player_level, _progress.current_xp, _progress.player_level * 100])
	print("    Gold: %d" % _progress.gold)
	if leveled_up:
		print("    🎉 LEVEL UP!")


func _demo_gacha_pulls() -> void:
	print("\n🎰 DEMO 2: Gacha Pulls")
	print("-" * 40)
	print("  Starting Gold: %d" % _progress.gold)
	print("")
	
	# Do 3 pulls
	for i in range(3):
		print("  Pull %d:" % (i + 1))
		var result := _gacha.pull(_progress, _collection)
		
		if result.success:
			if result.is_duplicate:
				print("    📦 Duplicate! +%d XP to existing pet" % result.bonus_xp)
			else:
				var pet: Pet = result.pet
				var rarity_obj := PetRarity.new(pet.rarity)
				print("    🆕 NEW PET: %s (%s)" % [pet.nickname, rarity_obj.get_name()])
		else:
			print("    ❌ Not enough gold!")
		
		print("    Gold remaining: %d" % _progress.gold)
	
	print("")
	print("  🐾 Collection: %d pets" % _collection.count())
	for pet in _collection.pets:
		var rarity_obj := PetRarity.new(pet.rarity)
		print("    - %s (%s, Lv.%d)" % [pet.nickname, rarity_obj.get_name(), pet.level])


func _demo_pet_leveling() -> void:
	print("\n⬆️ DEMO 3: Pet Leveling & Evolution")
	print("-" * 40)
	
	if _collection.count() == 0:
		print("  No pets to level up!")
		return
	
	var pet := _collection.pets[0]
	print("  Pet: %s (Lv.%d)" % [pet.nickname, pet.level])
	
	# Add a bunch of XP
	var xp_to_add := 600
	print("  Adding %d XP..." % xp_to_add)
	
	var events := pet.add_xp(xp_to_add)
	
	print("  New Level: %d" % pet.level)
	print("  Evolution Stage: %s" % EvolutionStage.new(pet.stage).get_name())
	
	if events.size() > 0:
		print("  🎉 Level up events:")
		for event in events:
			var ev: PetLeveledUpEvent = event
			if ev.evolved:
				print("    - Evolved at level %d!" % ev.new_level)
			else:
				print("    - Reached level %d" % ev.new_level)


func _demo_companion_dialogue() -> void:
	print("\n💬 DEMO 4: Companion Dialogue")
	print("-" * 40)
	
	var events_to_test := ["number_placed_correct", "mistake_made", "puzzle_solved", "idle", "pet_acquired"]
	
	for event_type in events_to_test:
		var dialogue := _dialogue.get_dialogue(event_type)
		print("  [%s] %s" % [event_type, dialogue.text])
