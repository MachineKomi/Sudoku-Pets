## PetScreen - Enhanced pet collection and gacha (Sprint 4)
## Features: Gacha with pity, pet leveling, feed/play interactions
extends Control


# =============================================================================
# CONSTANTS
# =============================================================================

const RARITY_COLORS: Dictionary = {
	PetRarity.Tier.COMMON: Color(0.7, 0.7, 0.7),
	PetRarity.Tier.UNCOMMON: Color(0.4, 0.8, 0.5), # Added Uncommon
	PetRarity.Tier.RARE: Color(0.3, 0.6, 1.0),
	PetRarity.Tier.EPIC: Color(0.8, 0.3, 0.9),
	PetRarity.Tier.LEGENDARY: Color(1.0, 0.8, 0.2)
}

# Pet Assets - Mapped from species_id
const PET_ASSETS: Dictionary = {
	"bunny": {"name": "Bunny", "sprite": "res://assets/sprites/pets/bunny.png"},
	"cat": {"name": "Cat", "sprite": "res://assets/sprites/pets/cat.png"},
	"owl": {"name": "Owl", "sprite": "res://assets/sprites/pets/owl.png"},
	"fox": {"name": "Fox", "sprite": "res://assets/sprites/pets/ninetailfoxkami.png"},
	"dragon": {"name": "Copper Dragon", "sprite": "res://assets/sprites/pets/babycopperdragon.png"},
	"panda": {"name": "Panda", "sprite": "res://assets/sprites/pets/panda.png"},
	"phoenix": {"name": "Phoenix Cat", "sprite": "res://assets/sprites/pets/phoenixcat.png"},
	"cosmic_owl": {"name": "Cosmic Owl", "sprite": "res://assets/sprites/pets/cosmicowl.png"},
	# Fallbacks
	"whisker_cat": {"name": "Whisker Cat", "sprite": "res://assets/sprites/pets/cat.png"},
	"hoot_owl": {"name": "Hoot Owl", "sprite": "res://assets/sprites/pets/owl.png"},
	"fluffy_bunny": {"name": "Fluffy Bunny", "sprite": "res://assets/sprites/pets/bunny.png"}
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

# Detail Popup
@onready var pet_detail_panel: PanelContainer = $PetDetailPopup
@onready var detail_name: Label = $PetDetailPopup/VBox/NameLabel
@onready var detail_sprite: TextureRect = $PetDetailPopup/VBox/SpriteRect
@onready var detail_level: Label = $PetDetailPopup/VBox/LevelLabel
@onready var detail_shards: Label = $PetDetailPopup/VBox/ShardLabel
@onready var detail_happiness: ProgressBar = $PetDetailPopup/VBox/HappinessBar
@onready var feed_button: Button = $PetDetailPopup/VBox/ButtonRow/FeedButton
@onready var train_button: Button = $PetDetailPopup/VBox/ButtonRow/TrainButton
@onready var play_button: Button = $PetDetailPopup/VBox/ButtonRow/PlayButton


# =============================================================================
# STATE
# =============================================================================

var _selected_pet_id: String = ""


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_update_ui()
	_refresh_collection()
	_hide_detail_popup()
	
	# Connect to PetManager updates
	PetManager.collection_updated.connect(_on_collection_updated)


func _on_collection_updated() -> void:
	_update_ui()
	_refresh_collection()
	if not _selected_pet_id.is_empty():
		_show_detail_popup() # Refresh detail view if open


# =============================================================================
# UI UPDATES
# =============================================================================

func _update_ui() -> void:
	# Gold from PlayerData logic (or SaveManager for now as UI only reads)
	var gold: int = SaveManager.get_value("player_gold", 100)
	
	if gold_label:
		gold_label.text = "🪙 %d" % gold
	
	if pull_button:
		pull_button.disabled = gold < GachaMachine.PULL_COST
		pull_button.text = "Pull! (%d 🪙)" % GachaMachine.PULL_COST
	
	# Pity info from GachaMachine helper? 
	# GachaMachine is a service, state is usually in it, but here we instantiate it per pull?
	# Wait, GachaMachine stores pity in itself? No, it's a domain service.
	# The pity_counter was in gacha_machine.gd as a member var.
	# We should really adhere to passing state. 
	# For now, let's assume we read pity from save or PetManager if tracked there.
	# The previous code stored it in 'gacha_pity_counter'.
	var pity = SaveManager.get_value("gacha_pity_counter", 0)
	
	if pity_progress:
		pity_progress.max_value = GachaMachine.PITY_THRESHOLD
		pity_progress.value = pity
	
	if pity_label:
		if pity >= GachaMachine.PITY_THRESHOLD:
			pity_label.text = "✨ Rare+ guaranteed!"
		else:
			pity_label.text = "Pity: %d/%d" % [pity, GachaMachine.PITY_THRESHOLD]


func _refresh_collection() -> void:
	if not pet_grid:
		return
	
	for child in pet_grid.get_children():
		child.queue_free()
	
	var pets: Array[Pet] = PetManager.get_all_pets()
	
	for pet in pets:
		_create_pet_card(pet)


func _create_pet_card(pet: Pet) -> void:
	var def = PET_ASSETS.get(pet.species_id, PET_ASSETS["bunny"])
	
	# Container
	var container := Button.new()
	container.flat = true
	container.custom_minimum_size = Vector2(90, 110)
	container.focus_mode = Control.FOCUS_NONE
	container.pressed.connect(_on_pet_card_pressed.bind(pet.id))
	
	# Background
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var style := StyleBoxFlat.new()
	style.bg_color = Color(1, 1, 1, 0.9) # White card
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = RARITY_COLORS.get(pet.rarity, Color.GRAY)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.shadow_size = 2
	panel.add_theme_stylebox_override("panel", style)
	container.add_child(panel)
	
	# Content
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	# Padding
	var margin_container = MarginContainer.new()
	margin_container.set_anchors_preset(Control.PRESET_FULL_RECT)
	margin_container.add_theme_constant_override("margin_left", 5)
	margin_container.add_theme_constant_override("margin_top", 5)
	margin_container.add_theme_constant_override("margin_right", 5)
	margin_container.add_theme_constant_override("margin_bottom", 5)
	margin_container.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	container.add_child(margin_container)
	margin_container.add_child(vbox)
	
	# Sprite
	var sprite := TextureRect.new()
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.custom_minimum_size = Vector2(60, 60)
	sprite.size_flags_vertical = Control.SIZE_EXPAND_FILL
	sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if ResourceLoader.exists(def.sprite):
		sprite.texture = load(def.sprite)
	vbox.add_child(sprite)
	
	# Level
	var level_lbl := Label.new()
	level_lbl.text = "Lv.%d" % pet.level
	level_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	level_lbl.add_theme_font_size_override("font_size", 12)
	level_lbl.add_theme_color_override("font_color", Color(0.3, 0.3, 0.4))
	vbox.add_child(level_lbl)
	
	pet_grid.add_child(container)


# =============================================================================
# GACHA ACTIONS
# =============================================================================

func _on_pull_pressed() -> void:
	# Load Domain Objects
	var player_progress = PlayerProgress.from_dict(SaveManager.get_value("player_progress", {}))
	var gacha = GachaMachine.new()
	
	# Sync pity counter into Gacha service if needed
	# (Assuming GachaMachine stores state? No, it's a service. It needs the counter passed or stored in Player?)
	# The gacha_machine.gd I read has a member 'pity_counter'. 
	# So we need to set it before pulling, and read it back.
	gacha.pity_counter = SaveManager.get_value("gacha_pity_counter", 0)
	
	var result = gacha.pull(player_progress, PetManager.collection)
	
	if not result.success:
		# Show error (not enough gold)
		result_label.text = "Need more Gold!"
		return
	
	# Save updated state
	SaveManager.set_value("player_progress", player_progress.to_dict())
	SaveManager.set_value("player_gold", player_progress.gold) # Legacy sync
	SaveManager.set_value("gacha_pity_counter", gacha.get_pity_progress())
	PetManager.save() # Saves collection
	
	# Animation
	result_label.text = "?"
	await _animate_gacha()
	
	var species = result.get("species", "bunny")
	var def = PET_ASSETS.get(species, PET_ASSETS["bunny"])
	var rarity = result.get("rarity", PetRarity.Tier.COMMON)
	
	if result.get("is_duplicate", false):
		var shards = result.get("shard_amount", 1)
		result_label.text = "Duplicate! +%d Shard" % shards
		result_label.add_theme_color_override("font_color", Color(0.3, 0.6, 0.8)) # Blue for shards
	else:
		result_label.text = "✨ " + def.name + " ✨"
		result_label.add_theme_color_override("font_color", RARITY_COLORS.get(rarity, Color.WHITE))
	
	_update_ui()
	_refresh_collection()


func _animate_gacha() -> void:
	var keys = PET_ASSETS.keys()
	for i in range(10):
		var k = keys[randi() % keys.size()]
		result_label.text = PET_ASSETS[k].name
		result_label.add_theme_color_override("font_color", Color.GRAY)
		await get_tree().create_timer(0.05 + i * 0.01).timeout


# =============================================================================
# PET DETAILS
# =============================================================================

func _on_pet_card_pressed(pet_id: String) -> void:
	_selected_pet_id = pet_id
	_show_detail_popup()


func _show_detail_popup() -> void:
	var pet = PetManager.collection.get_pet(_selected_pet_id)
	if not pet:
		_hide_detail_popup()
		return
	
	var def = PET_ASSETS.get(pet.species_id, PET_ASSETS["bunny"])
	
	if detail_name:
		detail_name.text = pet.nickname
		detail_name.add_theme_color_override("font_color", RARITY_COLORS.get(pet.rarity, Color.GRAY))
	
	if detail_sprite and ResourceLoader.exists(def.sprite):
		detail_sprite.texture = load(def.sprite)
	
	if detail_level:
		var xp_needed = pet.xp_for_next_level()
		detail_level.text = "Level %d (XP: %d/%d)" % [pet.level, pet.current_xp, xp_needed]
	
	if detail_shards:
		var count = PetManager.get_shards(pet.species_id)
		detail_shards.text = "Shards: %d" % count
	
	if detail_happiness:
		detail_happiness.value = pet.happiness
	
	if pet_detail_panel:
		pet_detail_panel.visible = true


func _hide_detail_popup() -> void:
	if pet_detail_panel:
		pet_detail_panel.visible = false
	_selected_pet_id = ""


func _on_feed_pressed() -> void:
	var pet = PetManager.collection.get_pet(_selected_pet_id)
	if pet:
		pet.feed()
		PetManager.save()
		_show_detail_popup()


func _on_play_pressed() -> void:
	var pet = PetManager.collection.get_pet(_selected_pet_id)
	if pet:
		pet.play()
		pet.add_xp(5) # Play gives small XP
		PetManager.save()
		_show_detail_popup()


func _on_train_pressed() -> void:
	var pet = PetManager.collection.get_pet(_selected_pet_id)
	if not pet:
		return
	
	# Cost: 1 Shard = 50 XP
	if PetManager.spend_shards(pet.species_id, 1):
		pet.add_xp(50)
		PetManager.save()
		_show_detail_popup()
	else:
		# Feedback (shake button?)
		if train_button:
			train_button.text = "No Shards!"
			await get_tree().create_timer(1.0).timeout
			if train_button: train_button.text = "⚔️ Train"


func _on_close_detail_pressed() -> void:
	_hide_detail_popup()


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
