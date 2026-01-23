## PetRarity - Value object for pet rarity tiers
class_name PetRarity
extends RefCounted


enum Tier {
	COMMON,     ## Brown/copper frame
	UNCOMMON,   ## Silver frame
	RARE,       ## Gold frame
	EPIC,       ## Purple frame
	LEGENDARY   ## Rainbow frame
}


var tier: Tier


func _init(rarity_tier: Tier = Tier.COMMON) -> void:
	tier = rarity_tier


## Get display name for UI
func get_name() -> String:
	match tier:
		Tier.COMMON:
			return "Common"
		Tier.UNCOMMON:
			return "Uncommon"
		Tier.RARE:
			return "Rare"
		Tier.EPIC:
			return "Epic"
		Tier.LEGENDARY:
			return "Legendary"
	return "Unknown"


## Get color for rarity frame
func get_color() -> Color:
	match tier:
		Tier.COMMON:
			return Color(0.6, 0.4, 0.2)      # Brown
		Tier.UNCOMMON:
			return Color(0.75, 0.75, 0.75)   # Silver
		Tier.RARE:
			return Color(1.0, 0.84, 0.0)     # Gold
		Tier.EPIC:
			return Color(0.6, 0.3, 0.9)      # Purple
		Tier.LEGENDARY:
			return Color(1.0, 0.5, 0.8)      # Rainbow-ish pink
	return Color.WHITE


## Get gacha pull rate (percentage)
static func get_pull_rate(rarity_tier: Tier) -> float:
	match rarity_tier:
		Tier.COMMON:
			return 50.0
		Tier.UNCOMMON:
			return 30.0
		Tier.RARE:
			return 15.0
		Tier.EPIC:
			return 4.0
		Tier.LEGENDARY:
			return 1.0
	return 0.0
