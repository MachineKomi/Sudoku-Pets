## PetScreen - Enhanced pet collection and gacha (Sprint 4)
## Features: Gacha with pity, pet leveling, feed/play interactions
extends Control


# =============================================================================
# CONSTANTS
# =============================================================================

const RARITY_COLORS: Dictionary = {
	"Common": Color(0.7, 0.7, 0.7),
	"Rare": Color(0.3, 0.6, 1.0),
	"Epic": Color(0.8, 0.3, 0.9),
	"Legendary": Color(1.0, 0.8, 0.2)
}

const PULL_COST := 100
const PITY_THRESHOLD := 10  ## Guaranteed Rare+ after 10 pulls

# Pet Definitions - Mapped to assets/sprites/pets/
const PET_DB: Dictionary = {
	"bunny": {
		"name": "Bunny",
		"rarity": "Common",
		"sprite_path": "res://assets/sprites/pets/bunny.png",
		"emoji": "🐰"
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
		"name": "Fox",
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


# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var gold_label: Label = $CenterContainer/MainVBox/TopBar/GoldLabel
@onready var pull_button: Button = $CenterContainer/MainVBox/ContentHBox/GachaPanel/GachaVBox/PullButton
@onready var result_label: Label = $CenterContainer/MainVBox/ContentHBox/GachaPanel/GachaVBox/ResultLabel
@onready var pity_progress: ProgressBar = $CenterContainer/MainVBox/ContentHBox/GachaPanel/GachaVBox/PityProgress
@onready var pity_label: Label = $CenterContainer/MainVBox/ContentHBox/GachaPanel/GachaVBox/PityLabel
@onready var pet_grid: GridContainer = $CenterContainer/MainVBox/ContentHBox/CollectionPanel/CollectionVBox/ScrollContainer/PetGrid
@onready var pet_detail_panel: PanelContainer = $PetDetailPopup
@onready var detail_name: Label = $PetDetailPopup/VBox/NameLabel
@onready var detail_sprite: TextureRect = $PetDetailPopup/VBox/SpriteRect
@onready var detail_level: Label = $PetDetailPopup/VBox/LevelLabel
@onready var detail_happiness: ProgressBar = $PetDetailPopup/VBox/HappinessBar
@onready var feed_button: Button = $PetDetailPopup/VBox/ButtonRow/FeedButton
@onready var play_button: Button = $PetDetailPopup/VBox/ButtonRow/PlayButton


# =============================================================================
# STATE
# =============================================================================

var _owned_pets: Array = []  # Untyped to handle JSON deserialization
var _pity_counter: int = 0
var _selected_pet_index: int = -1


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_load_data()
	_update_ui()
	_refresh_collection()
	_hide_detail_popup()


func _load_data() -> void:
	# Get saved data - may be untyped Array from JSON
	var saved_pets: Variant = SaveManager.get_value("owned_pets", [])
	if saved_pets is Array:
		_owned_pets = saved_pets
	else:
		_owned_pets = []
	
	var saved_pity: Variant = SaveManager.get_value("gacha_pity_counter", 0)
	if saved_pity is int:
		_pity_counter = saved_pity
	elif saved_pity is float:
		_pity_counter = int(saved_pity)
	else:
		_pity_counter = 0


func _save_data() -> void:
	SaveManager.set_value("owned_pets", _owned_pets)
	SaveManager.set_value("gacha_pity_counter", _pity_counter)
	SaveManager.save_game()


# =============================================================================
# UI UPDATES
# =============================================================================

func _update_ui() -> void:
	var gold: int = SaveManager.get_value("player_gold", 100)
	
	if gold_label:
		gold_label.text = "🪙 %d" % gold
	
	if pull_button:
		pull_button.disabled = gold < PULL_COST
	
	# Update pity progress (Story 4.1)
	if pity_progress:
		pity_progress.max_value = PITY_THRESHOLD
		pity_progress.value = _pity_counter
	
	if pity_label:
		if _pity_counter >= PITY_THRESHOLD - 1:
			pity_label.text = "✨ Rare+ guaranteed next pull!"
		else:
			pity_label.text = "Pity: %d/%d" % [_pity_counter, PITY_THRESHOLD]


func _refresh_collection() -> void:
	"""Rebuild pet collection grid with levels and happiness (Story 4.2)"""
	if not pet_grid:
		push_warning("PetScreen: pet_grid node not found")
		return
	
	for child in pet_grid.get_children():
		child.queue_free()
	
	for i in range(_owned_pets.size()):
		var pet_entry: Variant = _owned_pets[i]
		if not pet_entry is Dictionary:
			continue
		
		var pet_dict: Dictionary = pet_entry as Dictionary
		var pet_id: String = pet_dict.get("id", "bunny")
		var def: Dictionary = PET_DB.get(pet_id, PET_DB["bunny"])
		var level: int = int(pet_dict.get("level", 1))
		var happiness: int = int(pet_dict.get("happiness", 75))
		
		# Container with click detection
		var container := Button.new()
		container.flat = true
		container.custom_minimum_size = Vector2(90, 110)
		container.focus_mode = Control.FOCUS_NONE
		container.pressed.connect(_on_pet_card_pressed.bind(i))
		
		# Background panel
		var panel := Panel.new()
		panel.set_anchors_preset(Control.PRESET_FULL_RECT)
		panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var style := StyleBoxFlat.new()
		style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = RARITY_COLORS.get(def.rarity, Color.WHITE)
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_right = 10
		style.corner_radius_bottom_left = 10
		panel.add_theme_stylebox_override("panel", style)
		container.add_child(panel)
		
		# VBox for content
		var vbox := VBoxContainer.new()
		vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
		vbox.offset_left = 5
		vbox.offset_top = 5
		vbox.offset_right = -5
		vbox.offset_bottom = -5
		vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Sprite
		var sprite := TextureRect.new()
		sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		sprite.custom_minimum_size = Vector2(60, 60)
		sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		if ResourceLoader.exists(def.sprite_path):
			sprite.texture = load(def.sprite_path)
		vbox.add_child(sprite)
		
		# Level label
		var level_lbl := Label.new()
		level_lbl.text = "Lv.%d" % level
		level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		level_lbl.add_theme_font_size_override("font_size", 12)
		level_lbl.add_theme_color_override("font_color", Color("#FFD700"))
		level_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(level_lbl)
		
		# Happiness indicator
		var happy_lbl := Label.new()
		if happiness >= 80:
			happy_lbl.text = "😊"
		elif happiness >= 50:
			happy_lbl.text = "🙂"
		else:
			happy_lbl.text = "😐"
		happy_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		happy_lbl.add_theme_font_size_override("font_size", 14)
		happy_lbl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		vbox.add_child(happy_lbl)
		
		container.add_child(vbox)
		pet_grid.add_child(container)


# =============================================================================
# GACHA SYSTEM (Story 4.1)
# =============================================================================

func _on_pull_pressed() -> void:
	var gold: int = SaveManager.get_value("player_gold", 0)
	if gold < PULL_COST:
		return
	
	SaveManager.set_value("player_gold", gold - PULL_COST)
	
	# Increment pity counter
	_pity_counter += 1
	
	# Gacha roll with pity system
	var roll := randf()
	var target_rarity: String
	
	# Check pity - guaranteed Rare+ at threshold
	if _pity_counter >= PITY_THRESHOLD:
		# Guaranteed at least Rare
		if roll < 0.10:
			target_rarity = "Legendary"
		elif roll < 0.40:
			target_rarity = "Epic"
		else:
			target_rarity = "Rare"
		_pity_counter = 0  # Reset pity
	else:
		# Normal rates
		if roll < 0.05:
			target_rarity = "Legendary"
			_pity_counter = 0  # Reset pity on Rare+
		elif roll < 0.15:
			target_rarity = "Epic"
			_pity_counter = 0
		elif roll < 0.35:
			target_rarity = "Rare"
			_pity_counter = 0
		else:
			target_rarity = "Common"
	
	# Filter pets by rarity
	var pool: Array[String] = []
	for id in PET_DB:
		if PET_DB[id].rarity == target_rarity:
			pool.append(id)
	
	if pool.is_empty():
		pool = PET_DB.keys()
	
	var pet_id: String = pool[randi() % pool.size()]
	var def: Dictionary = PET_DB[pet_id]
	
	# Animate result
	result_label.text = "?"
	await _animate_gacha()
	
	# Show result
	result_label.text = "✨ " + def.name + " ✨"
	result_label.add_theme_color_override("font_color", RARITY_COLORS[def.rarity])
	
	# Add to collection with initial stats
	_owned_pets.append({
		"id": pet_id,
		"level": 1,
		"xp": 0,
		"happiness": 75,
		"acquired_at": Time.get_unix_time_from_system()
	})
	
	_save_data()
	_update_ui()
	_refresh_collection()


func _animate_gacha() -> void:
	"""Slot machine style animation"""
	var keys: Array = PET_DB.keys()
	for i in range(15):  # More spins for excitement
		var random_id: String = keys[randi() % keys.size()]
		var def: Dictionary = PET_DB[random_id]
		result_label.text = def.name
		result_label.add_theme_color_override("font_color", RARITY_COLORS[def.rarity])
		# Slow down near the end
		var delay: float = 0.05 + (i * 0.02)
		await get_tree().create_timer(delay).timeout


# =============================================================================
# PET DETAIL & INTERACTION (Stories 4.3, 4.4)
# =============================================================================

func _on_pet_card_pressed(index: int) -> void:
	_selected_pet_index = index
	_show_detail_popup()


func _show_detail_popup() -> void:
	if _selected_pet_index < 0 or _selected_pet_index >= _owned_pets.size():
		return
	
	var pet: Dictionary = _owned_pets[_selected_pet_index]
	var pet_id: String = pet.get("id", "bunny")
	var def: Dictionary = PET_DB.get(pet_id, PET_DB["bunny"])
	
	if detail_name:
		detail_name.text = def.name
		detail_name.add_theme_color_override("font_color", RARITY_COLORS.get(def.rarity, Color.WHITE))
	
	if detail_sprite and ResourceLoader.exists(def.sprite_path):
		detail_sprite.texture = load(def.sprite_path)
	
	if detail_level:
		var level: int = pet.get("level", 1)
		var xp: int = pet.get("xp", 0)
		var xp_needed: int = level * 50
		detail_level.text = "Level %d (XP: %d/%d)" % [level, xp, xp_needed]
	
	if detail_happiness:
		var happiness: int = pet.get("happiness", 75)
		detail_happiness.value = happiness
	
	if pet_detail_panel:
		pet_detail_panel.visible = true


func _hide_detail_popup() -> void:
	if pet_detail_panel:
		pet_detail_panel.visible = false
	_selected_pet_index = -1


func _on_feed_pressed() -> void:
	"""Feed pet to increase happiness (Story 4.4)"""
	if _selected_pet_index < 0:
		return
	
	var pet: Dictionary = _owned_pets[_selected_pet_index]
	var happiness: int = pet.get("happiness", 75)
	happiness = mini(happiness + 15, 100)
	pet["happiness"] = happiness
	
	_save_data()
	_show_detail_popup()  # Refresh display
	_refresh_collection()


func _on_play_pressed() -> void:
	"""Play with pet to increase happiness and XP (Story 4.4)"""
	if _selected_pet_index < 0:
		return
	
	var pet: Dictionary = _owned_pets[_selected_pet_index]
	var happiness: int = pet.get("happiness", 75)
	var xp: int = pet.get("xp", 0)
	var level: int = pet.get("level", 1)
	
	happiness = mini(happiness + 10, 100)
	xp += 5
	
	# Check for level up
	var xp_needed: int = level * 50
	if xp >= xp_needed:
		xp -= xp_needed
		level += 1
		# Celebration message could be added here
	
	pet["happiness"] = happiness
	pet["xp"] = xp
	pet["level"] = level
	
	_save_data()
	_show_detail_popup()
	_refresh_collection()


func _on_close_detail_pressed() -> void:
	_hide_detail_popup()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
