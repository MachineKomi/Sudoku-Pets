## Currency - Value object representing in-game currencies
class_name Currency
extends RefCounted


enum Type {
	GOLD,  ## Used for gacha pulls
	XP,    ## Used for player/pet leveling
	GEMS   ## Premium currency (DLC rewards only, never paid)
}


var type: Type
var amount: int


func _init(currency_type: Type = Type.GOLD, currency_amount: int = 0) -> void:
	type = currency_type
	amount = currency_amount


## Create a copy with added amount
func add(value: int) -> Currency:
	return Currency.new(type, amount + value)


## Create a copy with subtracted amount (clamped to 0)
func subtract(value: int) -> Currency:
	return Currency.new(type, maxi(0, amount - value))


## Check if we have enough
func has_enough(required: int) -> bool:
	return amount >= required


func get_type_name() -> String:
	match type:
		Type.GOLD:
			return "Gold"
		Type.XP:
			return "XP"
		Type.GEMS:
			return "Gems"
	return "Unknown"


func to_dict() -> Dictionary:
	return {
		"type": get_type_name(),
		"amount": amount
	}
