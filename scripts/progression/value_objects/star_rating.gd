## StarRating - Value object for level completion quality (0-3 stars)
class_name StarRating
extends RefCounted


var stars: int


func _init(star_count: int = 0) -> void:
	stars = clampi(star_count, 0, 3)


## Calculate stars based on performance
static func calculate(mistakes: int, time_seconds: float, hints_used: int) -> StarRating:
	var rating := 0
	
	# Star 1: No mistakes
	if mistakes == 0:
		rating += 1
	
	# Star 2: Fast completion (under 2 minutes)
	if time_seconds < 120.0:
		rating += 1
	
	# Star 3: No hints used
	if hints_used == 0:
		rating += 1
	
	return StarRating.new(rating)


func is_perfect() -> bool:
	return stars == 3


func to_string() -> String:
	return "★".repeat(stars) + "☆".repeat(3 - stars)
