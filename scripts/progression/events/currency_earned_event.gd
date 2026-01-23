## CurrencyEarnedEvent - Emitted when player earns any currency
class_name CurrencyEarnedEvent
extends DomainEvent


## Type of currency earned
var currency_type: Currency.Type

## Amount earned
var amount: int

## Source of the currency (e.g., "puzzle_complete", "correct_number")
var source: String


func _init(cur_type: Currency.Type = Currency.Type.GOLD, amt: int = 0, src: String = "") -> void:
	super._init("CurrencyEarned")
	currency_type = cur_type
	amount = amt
	source = src


func get_currency_name() -> String:
	match currency_type:
		Currency.Type.GOLD:
			return "Gold"
		Currency.Type.XP:
			return "XP"
		Currency.Type.GEMS:
			return "Gems"
	return "Unknown"


func to_dict() -> Dictionary:
	var base := super.to_dict()
	base["currency_type"] = get_currency_name()
	base["amount"] = amount
	base["source"] = source
	return base
