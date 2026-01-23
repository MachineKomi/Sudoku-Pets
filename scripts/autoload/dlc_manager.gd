## DLCManager - Stub for future paid level packs (Story 6.2)
## Deliberately minimal - prepared for future expansion
## NO REAL-MONEY MICROTRANSACTIONS - paid DLC only!
extends Node


## DLC Pack definitions (stub for future implementation)
const DLC_PACKS: Dictionary = {
	"world_pack_1": {
		"name": "Ocean Adventure Pack",
		"description": "20 new ocean-themed levels with underwater pets!",
		"levels": 20,
		"pets": 3,
		"price_usd": 2.99,
		"released": false
	},
	"world_pack_2": {
		"name": "Sky Kingdom Pack",
		"description": "20 cloud castle levels with flying pets!",
		"levels": 20,
		"pets": 3,
		"price_usd": 2.99,
		"released": false
	}
}


## Get list of available DLC packs
func get_available_packs() -> Array[Dictionary]:
	var packs: Array[Dictionary] = []
	for pack_id in DLC_PACKS:
		var pack: Dictionary = DLC_PACKS[pack_id].duplicate()
		pack["id"] = pack_id
		pack["owned"] = _is_pack_owned(pack_id)
		packs.append(pack)
	return packs


## Check if a DLC pack is owned
func _is_pack_owned(pack_id: String) -> bool:
	var owned_packs: Array = SaveManager.get_value("owned_dlc_packs", [])
	return pack_id in owned_packs


## Stub for future purchase integration
## Will connect to platform store (Steam, Google Play, etc.)
func purchase_pack(pack_id: String) -> bool:
	# STUB: In production, this would:
	# 1. Open platform store overlay
	# 2. Wait for purchase confirmation
	# 3. Unlock content if successful
	push_warning("DLCManager.purchase_pack() is a stub - implement with platform SDK")
	return false


## Unlock a pack (called after successful purchase verification)
func unlock_pack(pack_id: String) -> void:
	var owned_packs: Array = SaveManager.get_value("owned_dlc_packs", [])
	if pack_id not in owned_packs:
		owned_packs.append(pack_id)
		SaveManager.set_value("owned_dlc_packs", owned_packs)
		SaveManager.save_game()
