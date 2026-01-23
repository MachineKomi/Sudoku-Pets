## Tests for RewardCalculator
extends GutTest


var _calc: RewardCalculator


func before_each() -> void:
	_calc = RewardCalculator.new()


func test_base_xp_per_number() -> void:
	var rewards := _calc.calculate_rewards("easy", 0, 60.0, 10)
	
	# 10 numbers * 10 XP each = 100 XP
	assert_eq(rewards.xp, 100, "Should award 10 XP per number placed")


func test_base_gold_by_difficulty() -> void:
	var easy := _calc.calculate_rewards("easy", 1, 60.0, 1)
	var medium := _calc.calculate_rewards("medium", 1, 60.0, 1)
	var hard := _calc.calculate_rewards("hard", 1, 60.0, 1)
	
	# With 1 mistake, no bonus multipliers
	assert_eq(easy.gold, 50, "Easy should give 50 base gold")
	assert_eq(medium.gold, 100, "Medium should give 100 base gold")
	assert_eq(hard.gold, 200, "Hard should give 200 base gold")


func test_no_mistake_bonus() -> void:
	var with_mistakes := _calc.calculate_rewards("easy", 1, 200.0, 1)
	var no_mistakes := _calc.calculate_rewards("easy", 0, 200.0, 1)
	
	# No mistakes should give +50% gold
	assert_eq(with_mistakes.gold, 50, "With mistakes: base gold")
	assert_eq(no_mistakes.gold, 75, "No mistakes: +50% bonus")


func test_fast_completion_bonus() -> void:
	var slow := _calc.calculate_rewards("easy", 1, 200.0, 1)  # Over 2 minutes
	var fast := _calc.calculate_rewards("easy", 1, 90.0, 1)   # Under 2 minutes
	
	# Fast should give +25% gold
	assert_eq(slow.gold, 50, "Slow: base gold")
	assert_eq(fast.gold, 62, "Fast: +25% bonus (truncated)")


func test_combined_bonuses() -> void:
	# No mistakes + fast = 1.5 * 1.25 = 1.875x
	var perfect := _calc.calculate_rewards("easy", 0, 60.0, 1)
	
	# 50 * 1.5 * 1.25 = 93.75 -> 93 (int)
	assert_eq(perfect.gold, 93, "Perfect run: combined bonuses")


func test_star_calculation() -> void:
	# Minimum 1 star for completion
	var slow_mistakes := _calc.calculate_rewards("easy", 3, 300.0, 1)
	assert_eq(slow_mistakes.stars, 1, "At least 1 star for completion")
	
	# 2 stars: no mistakes OR fast
	var no_mistakes := _calc.calculate_rewards("easy", 0, 300.0, 1)
	assert_eq(no_mistakes.stars, 2, "No mistakes: 2 stars")
	
	# 3 stars: no mistakes AND fast
	var perfect := _calc.calculate_rewards("easy", 0, 60.0, 1)
	assert_eq(perfect.stars, 3, "Perfect run: 3 stars")


func test_xp_for_level() -> void:
	assert_eq(RewardCalculator.xp_for_level(1), 100, "Level 1 needs 100 XP")
	assert_eq(RewardCalculator.xp_for_level(5), 500, "Level 5 needs 500 XP")
	assert_eq(RewardCalculator.xp_for_level(10), 1000, "Level 10 needs 1000 XP")
