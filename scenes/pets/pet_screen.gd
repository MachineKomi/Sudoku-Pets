## PetScreen - Pet collection and gacha
extends Control

# NOTE: Explicit typing required for Godot 4.5.1 strict inference
const RARITY_COLORS: Dictionary = {
	"Common": Color(0.7, 0.7, 0.7),
	"Rare": Color(0.3, 0.6, 1.0),
	"Epic": Color(0.8, 0.3, 0.9),
	"Legendary": Color(1.0, 0.8, 0.2)
}
const PULL_COST := 100

# Pet Definitions - Mapped to assets/sprites/pets/
# Keys are internal IDs
const PET_DB: Dictionary = {
	"bunny": {
		"name": "Bunny",
		"rarity": "Common",
		"sprite_path": "res://assets/sprites/pets/bunny.png",
		"emoji": "🐰" # Fallback
	},
	"cat": {
		"name": "Cat",
		"rarity": "Common",
		"sprite_path": "res://assets/sprites/pets/cat.png",
		"emoji": "🐱"
	},
	"owl": {
		"name": "Owl",
		"rarity": "Common",
		"sprite_path": "res://assets/sprites/pets/owl.png",
		"emoji": "🦉"
	},
	"fox": {
		"name": "Fox", # The 9-tailed fox kami is "Rare"
		"rarity": "Rare",
		"sprite_path": "res://assets/sprites/pets/ninetailfoxkami.png",
		"emoji": "🦊"
	},
	"dragon": {
		"name": "Copper Dragon",
		"rarity": "Epic",
		"sprite_path": "res://assets/sprites/pets/babycopperdragon.png",
		"emoji": "🐲"
	},
	"panda": {
		"name": "Panda",
		"rarity": "Epic",
		"sprite_path": "res://assets/sprites/pets/panda.png",
		"emoji": "🐼"
	},
	"phoenix": {
		"name": "Phoenix Cat",
		"rarity": "Legendary",
		"sprite_path": "res://assets/sprites/pets/phoenixcat.png",
		"emoji": "🔥"
	},
	"cosmic_owl": {
		"name": "Cosmic Owl",
		"rarity": "Legendary",
		"sprite_path": "res://assets/sprites/pets/cosmicowl.png",
		"emoji": "✨"
	}
}

@onready var gold_label: Label = $CenterContainer/MainVBox/TopBar/GoldLabel
@onready var pull_button: Button = $CenterContainer/MainVBox/ContentHBox/GachaPanel/GachaVBox/PullButton
@onready var result_label: Label = $CenterContainer/MainVBox/ContentHBox/GachaPanel/GachaVBox/ResultLabel
@onready var pet_grid: GridContainer = $CenterContainer/MainVBox/ContentHBox/CollectionPanel/CollectionVBox/PetGrid

var _owned_pets: Array[Dictionary] = []


func _ready() -> void:
	_load_pets()
	_update_ui()
	_refresh_collection()


func _load_pets() -> void:
	_owned_pets = SaveManager.get_value("owned_pets", [])


func _save_pets() -> void:
	SaveManager.set_value("owned_pets", _owned_pets)
	SaveManager.save_game()


func _update_ui() -> void:
	var gold: int = SaveManager.get_value("player_gold", 100)
	gold_label.text = "🪙 %d" % gold
	pull_button.disabled = gold < PULL_COST


func _refresh_collection() -> void:
	for child in pet_grid.get_children():
		child.queue_free()
	
	for pet_entry in _owned_pets:
		var pet_id: String = pet_entry.get("id", "bunny") # Default to bunny if key missing
		var def: Dictionary = PET_DB.get(pet_id, PET_DB["bunny"])
		
		# Container for sprite + border
		var container := PanelContainer.new()
		container.custom_minimum_size = Vector2(80, 80)
		
		# Rarity border style
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0, 0, 0, 0.5)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = RARITY_COLORS.get(def.rarity, Color.WHITE)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		container.add_theme_stylebox_override("panel", style)
		
		# Sprite
		var texture_rect := TextureRect.new()
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		texture_rect.custom_minimum_size = Vector2(70, 70)
		
		# Load texture
		if ResourceLoader.exists(def.sprite_path):
			texture_rect.texture = load(def.sprite_path)
		
		container.add_child(texture_rect)
		pet_grid.add_child(container)


func _on_pull_pressed() -> void:
	var gold: int = SaveManager.get_value("player_gold", 0)
	if gold < PULL_COST:
		return
	
	SaveManager.set_value("player_gold", gold - PULL_COST)
	
	# Gacha roll - Weighted Rarity
	var roll := randf()
	var target_rarity: String
	if roll < 0.05:
		target_rarity = "Legendary"
	elif roll < 0.20:
		target_rarity = "Epic"
	elif roll < 0.50:
		target_rarity = "Rare"
	else:
		target_rarity = "Common"
	
	# Filter pets by rarity
	var pool: Array[String] = []
	for id in PET_DB:
		if PET_DB[id].rarity == target_rarity:
			pool.append(id)
			
	# Fallback if pool is empty (e.g. if we messed up rarity keys)
	if pool.is_empty():
		pool = PET_DB.keys()
	
	var pet_id: String = pool[randi() % pool.size()]
	var def: Dictionary = PET_DB[pet_id]
	
	# Animate result
	result_label.text = "?"
	await _animate_gacha()
	
	# Show result (Text for now, maybe show Sprite in a popup later)
	result_label.text = def.name
	result_label.add_theme_color_override("font_color", RARITY_COLORS[def.rarity])
	
	# Add to collection
	_owned_pets.append({
		"id": pet_id, # Store ID reference
		"acquired_at": Time.get_unix_time_from_system()
	})
	_save_pets()
	_update_ui()
	_refresh_collection()


func _animate_gacha() -> void:
	var keys: Array = PET_DB.keys()
	for i in range(10):
		var random_id: String = keys[randi() % keys.size()]
		result_label.text = PET_DB[random_id].name
		await get_tree().create_timer(0.1).timeout


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
