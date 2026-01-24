## PuzzleScreen - Main gameplay screen
##
## IMPORTANT FOR AI AGENTS:
## - Node paths in @onready MUST match the .tscn file structure exactly
## - If you modify the scene tree, update these paths!
## - Reference: puzzle_screen.tscn for actual node hierarchy
##
extends Control

signal number_selected(num: int)

# =============================================================================
# CONSTANTS - UI-SPEC colors for number buttons
# =============================================================================

const NUMBER_COLORS: Array[Color] = [
	Color("#E63946"), # 1 - Ruby Red
	Color("#F4A261"), # 2 - Amber Orange  
	Color("#F9C74F"), # 3 - Topaz Yellow
	Color("#2A9D8F"), # 4 - Emerald Green
	Color("#00B4D8"), # 5 - Aquamarine Cyan
	Color("#4361EE"), # 6 - Sapphire Blue
	Color("#7209B7"), # 7 - Amethyst Purple
	Color("#F72585"), # 8 - Rose Pink
	Color("#E0E0E0"), # 9 - Diamond White
]

# =============================================================================
# NODE REFERENCES - Must match puzzle_screen.tscn structure
# =============================================================================

@onready var board: Control = $RootCenter/MainVBox/GameArea/BoardContainer/SudokuBoard
@onready var number_pad: HBoxContainer = $RootCenter/MainVBox/BottomBar/NumberPad
@onready var pencil_button: Button = $RootCenter/MainVBox/BottomBar/PencilButton

# Top Bar Nodes - UI-SPEC 1.2: Currency Display
@onready var gems_label: Label = $RootCenter/MainVBox/TopBar/HBox/CurrencyBox/GemsLabel
@onready var coins_label: Label = $RootCenter/MainVBox/TopBar/HBox/CurrencyBox/CoinsLabel
@onready var timer_label: Label = $RootCenter/MainVBox/TopBar/HBox/TimerLabel
@onready var heart_container: HBoxContainer = $RootCenter/MainVBox/TopBar/HBox/HeartContainer

# US-C.4: Pet companion panel - larger and next to board
@onready var pet_sprite: TextureRect = $RootCenter/MainVBox/GameArea/PetPanel/OverlayMargin/PetVBox/PetSpriteContainer/PetSprite
@onready var pet_speech: PanelContainer = $RootCenter/MainVBox/GameArea/PetPanel/OverlayMargin/PetVBox/SpeechBubble
@onready var speech_text: Label = $RootCenter/MainVBox/GameArea/PetPanel/OverlayMargin/PetVBox/SpeechBubble/MarginContainer/SpeechText


# Available pet sprites for companion
const PET_SPRITES: Array[String] = [
	"res://assets/sprites/pets/cat.png",
	"res://assets/sprites/pets/bunny.png",
	"res://assets/sprites/pets/owl.png",
	"res://assets/sprites/pets/panda.png",
]

# Win/Lose popup
@onready var win_popup: ColorRect = $WinPopup
@onready var rewards_label: Label = $WinPopup/WinPanel/VBox/RewardsLabel
@onready var stars_label: Label = $WinPopup/WinPanel/VBox/StarsLabel

# =============================================================================
# STATE VARIABLES
# =============================================================================

var _session_xp: int = 0
var _session_gold: int = 0
var _mistakes: int = 0
var _lives: int = 3
var _breezy_mode: bool = false  # US-E.1: Unlimited mistakes mode
var _timer_active: bool = true
var _time_elapsed: float = 0.0
var _pencil_mode: bool = false
var _number_buttons: Array[Button] = []

# REMOVED: _selected_number - numbers are no longer "selected", they are actions

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_setup_difficulty_mode()  # US-E.1: Configure based on selected difficulty
	_setup_number_pad()
	_setup_pet_companion()
	_update_ui()
	_update_lives_ui()
	
	if pencil_button:
		pencil_button.toggled.connect(_on_pencil_toggled)
		_style_pencil_button()
	
	# Connect board signals
	board.cell_filled_correct.connect(_on_cell_correct)
	board.cell_filled_wrong.connect(_on_cell_wrong)
	board.puzzle_completed.connect(_on_puzzle_completed)
	board.gold_earned.connect(_on_gold_earned)  # US-D.3: Gold conversion animation
	
	_show_pet_message("Let's solve this puzzle!")


func _setup_difficulty_mode() -> void:
	"""US-E.1: Configure lives based on selected difficulty"""
	var difficulty: String = SaveManager.get_value("current_difficulty", "normal")
	
	match difficulty:
		"breezy":
			_breezy_mode = true
			_lives = 999  # Effectively unlimited
		"normal":
			_breezy_mode = false
			_lives = 5
		"hard":
			_breezy_mode = false
			_lives = 3
		_:
			_breezy_mode = false
			_lives = 5


func _setup_pet_companion() -> void:
	"""Load a random pet sprite for the companion"""
	if pet_sprite and not PET_SPRITES.is_empty():
		var random_path: String = PET_SPRITES[randi() % PET_SPRITES.size()]
		if ResourceLoader.exists(random_path):
			pet_sprite.texture = load(random_path)


func _process(delta: float) -> void:
	if _timer_active and not win_popup.visible:
		_time_elapsed += delta
		var minutes: int = int(_time_elapsed / 60)
		var seconds: int = int(_time_elapsed) % 60
		if timer_label:
			timer_label.text = "%02d:%02d" % [minutes, seconds]

# =============================================================================
# NUMBER PAD SETUP - UI-SPEC 3.1: Number Pad Layout
# =============================================================================

func _setup_number_pad() -> void:
	"""US-B.3: Number pad with gem sprites instead of plain numbers"""
	var board_size: int = board.get_board_size()
	
	for i in range(1, board_size + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(60, 60)
		btn.focus_mode = Control.FOCUS_NONE
		btn.name = "NumBtn_%d" % i
		
		# Style the button background
		_style_number_button(btn, i)
		
		# Add gem sprite inside button
		var gem_sprite := TextureRect.new()
		gem_sprite.name = "GemSprite"
		gem_sprite.set_anchors_preset(Control.PRESET_FULL_RECT)
		gem_sprite.offset_left = 8
		gem_sprite.offset_top = 8
		gem_sprite.offset_right = -8
		gem_sprite.offset_bottom = -8
		gem_sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		gem_sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		gem_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		# Load gem texture
		var gem_path: String = "res://assets/sprites/gems/gem_%d.png" % i
		if ResourceLoader.exists(gem_path):
			gem_sprite.texture = load(gem_path)
		
		btn.add_child(gem_sprite)
		btn.pressed.connect(_on_number_button_pressed.bind(i))
		number_pad.add_child(btn)
		_number_buttons.append(btn)


func _style_number_button(btn: Button, num: int) -> void:
	"""US-B.3: Style number button with subtle background for gem sprite"""
	var color: Color = NUMBER_COLORS[num - 1] if num <= NUMBER_COLORS.size() else Color.WHITE
	
	# Normal state - subtle background to let gem sprite shine
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.98, 0.96, 0.92, 0.9)  # Light cream, matches board theme
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_right = 12
	style.corner_radius_bottom_left = 12
	style.border_width_left = 3
	style.border_width_top = 3
	style.border_width_right = 3
	style.border_width_bottom = 3
	style.border_color = color.lightened(0.2)
	style.shadow_color = Color(0, 0, 0, 0.15)
	style.shadow_size = 4
	style.shadow_offset = Vector2(2, 2)
	
	# Hover state - brighter border
	var hover_style := StyleBoxFlat.new()
	hover_style.bg_color = Color(1.0, 0.98, 0.95, 1.0)
	hover_style.corner_radius_top_left = 12
	hover_style.corner_radius_top_right = 12
	hover_style.corner_radius_bottom_right = 12
	hover_style.corner_radius_bottom_left = 12
	hover_style.border_width_left = 4
	hover_style.border_width_top = 4
	hover_style.border_width_right = 4
	hover_style.border_width_bottom = 4
	hover_style.border_color = color
	hover_style.shadow_color = Color(0, 0, 0, 0.2)
	hover_style.shadow_size = 6
	
	# Pressed state - slightly darker
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.95, 0.93, 0.88, 1.0)
	pressed_style.corner_radius_top_left = 12
	pressed_style.corner_radius_top_right = 12
	pressed_style.corner_radius_bottom_right = 12
	pressed_style.corner_radius_bottom_left = 12
	pressed_style.border_width_left = 3
	pressed_style.border_width_top = 3
	pressed_style.border_width_right = 3
	pressed_style.border_width_bottom = 3
	pressed_style.border_color = color.darkened(0.1)
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", hover_style)
	btn.add_theme_stylebox_override("pressed", pressed_style)


func _style_pencil_button() -> void:
	"""Initial styling for pencil button - replaced by _update_pencil_button_style"""
	_update_pencil_button_style()


# =============================================================================
# INPUT HANDLERS - US-B.1: Click-to-Place Input Mode
# =============================================================================

func _on_pencil_toggled(toggled_on: bool) -> void:
	_pencil_mode = toggled_on
	# Update button visuals to show mode
	_update_pencil_button_style()
	# US-B.3: Switch number pad sprites when pencil mode changes
	_update_number_pad_sprites()


func _update_number_pad_sprites() -> void:
	"""US-B.3: Switch between regular and small gem sprites based on pencil mode"""
	for i in range(_number_buttons.size()):
		var btn: Button = _number_buttons[i]
		var sprite: TextureRect = btn.get_node_or_null("GemSprite") as TextureRect
		if not sprite:
			continue
		
		var num: int = i + 1
		var gem_path: String
		
		if _pencil_mode:
			# GS-2: Use draftnote gem sprite for pencil mode
			gem_path = "res://assets/sprites/gems/gem_%d_draftnote.png" % num
			if not ResourceLoader.exists(gem_path):
				# Fallback to regular gem if draftnote doesn't exist
				gem_path = "res://assets/sprites/gems/gem_%d.png" % num
		else:
			gem_path = "res://assets/sprites/gems/gem_%d.png" % num
		
		if ResourceLoader.exists(gem_path):
			sprite.texture = load(gem_path)



func _on_number_button_pressed(num: int) -> void:
	"""US-B.1: Clicking a number immediately places it in the selected cell.
	No toggle behavior - numbers are actions, not selections."""
	
	# Check if a cell is selected
	if board._selected_cell < 0:
		_show_pet_message("Tap a cell first! 👆")
		return
	
	# Check if the selected cell is a given (pre-filled) cell
	if board._puzzle.starting_grid[board._selected_cell] != 0:
		_show_pet_message("That cell is already filled! 🔒")
		return
	
	if _pencil_mode:
		# Pencil mode - toggle note on selected cell
		board.toggle_note(board._selected_cell, num)
	else:
		# Normal mode - place number IMMEDIATELY in selected cell
		board.place_number_in_selected_cell(num)


func _update_pencil_button_style() -> void:
	"""Update pencil button appearance based on mode"""
	if not pencil_button:
		return
	
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	
	if _pencil_mode:
		style.bg_color = Color(0.9, 0.7, 0.2)  # Bright amber when active
		style.border_width_left = 3
		style.border_width_top = 3
		style.border_width_right = 3
		style.border_width_bottom = 3
		style.border_color = Color("#FFD700")
	else:
		style.bg_color = Color(0.3, 0.3, 0.35)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.4, 0.4, 0.45)
	
	pencil_button.add_theme_stylebox_override("normal", style)
	pencil_button.add_theme_stylebox_override("hover", style)
	pencil_button.add_theme_stylebox_override("pressed", style)

# =============================================================================
# UI UPDATES
# =============================================================================

func _update_ui() -> void:
	var total_gold: int = SaveManager.get_value("player_gold", 100)
	if coins_label:
		coins_label.text = "🪙 %d" % total_gold
	if gems_label:
		gems_label.text = "💎 13"


func _update_lives_ui() -> void:
	"""Update heart display - UI-SPEC 4.1: Lives System
	US-E.1: Show infinity symbol for breezy mode"""
	if not heart_container:
		return
	
	# In breezy mode, show infinity symbol instead of hearts
	if _breezy_mode:
		for child in heart_container.get_children():
			child.queue_free()
		var infinity_label := Label.new()
		infinity_label.text = "∞ 🌴"
		infinity_label.add_theme_font_size_override("font_size", 24)
		infinity_label.add_theme_color_override("font_color", Color(0.4, 0.85, 0.6))
		heart_container.add_child(infinity_label)
		return
	
	var hearts: Array[Node] = []
	for child in heart_container.get_children():
		hearts.append(child)
	
	for i in range(hearts.size()):
		var heart: Label = hearts[i] as Label
		if heart:
			if i < _lives:
				heart.text = "❤️"
				heart.modulate = Color.WHITE
			else:
				heart.text = "🖤"
				heart.modulate = Color(0.4, 0.4, 0.4)

# =============================================================================
# GAME EVENTS
# =============================================================================

func _on_cell_correct() -> void:
	_session_xp += 10
	_update_ui()
	_show_pet_message(_get_encouragement())


## US-D.3: Gold conversion animation when completing lines/boxes
func _on_gold_earned(amount: int) -> void:
	# Add gold to session total
	_session_gold += amount
	
	# Update player's gold immediately
	var current_gold: int = SaveManager.get_value("player_gold", 0)
	SaveManager.set_value("player_gold", current_gold + amount)
	
	# Show animated gold popup
	_show_gold_popup(amount)
	_update_ui()


func _show_gold_popup(amount: int) -> void:
	"""US-D.3: Show animated gold earned popup with multiplying numbers effect"""
	# Create floating gold label
	var gold_label := Label.new()
	gold_label.text = "+%d 🪙" % amount
	gold_label.add_theme_font_size_override("font_size", 28)
	gold_label.add_theme_color_override("font_color", Color("#FFD700"))
	gold_label.add_theme_color_override("font_outline_color", Color("#8B4513"))
	gold_label.add_theme_constant_override("outline_size", 3)
	gold_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Position near the board center
	gold_label.position = Vector2(size.x / 2 - 50, size.y / 2 - 100)
	add_child(gold_label)
	
	# Animate: float up and fade out
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(gold_label, "position:y", gold_label.position.y - 80, 1.2).set_ease(Tween.EASE_OUT)
	tween.tween_property(gold_label, "modulate:a", 0.0, 1.2).set_ease(Tween.EASE_IN).set_delay(0.3)
	tween.set_parallel(false)
	tween.tween_callback(gold_label.queue_free)


func _on_cell_wrong(explanation: String) -> void:
	_mistakes += 1
	
	# US-E.1: In breezy mode, don't lose lives
	if not _breezy_mode:
		_lives -= 1
		_update_lives_ui()
		
		if _lives <= 0:
			_handle_game_over()
			return
	
	# Story 2.1: Show the educating error explanation from the validator
	_show_pet_message(explanation)


func _handle_game_over() -> void:
	_timer_active = false
	_show_pet_message("Don't give up!")
	win_popup.visible = true
	rewards_label.text = "Out of lives!"
	stars_label.text = "💔"


func _on_puzzle_completed() -> void:
	_timer_active = false
	
	# Get current level info from SaveManager (set by WorldMap)
	var level_id: int = SaveManager.get_value("current_level_id", 1)
	var difficulty: String = SaveManager.get_value("current_difficulty", "normal")
	
	# Use RewardCalculator for proper reward calculation (Story 3.4)
	# US-D.4: Pass level_id for level-based scaling
	var reward_calc := RewardCalculator.new()
	var numbers_placed: int = board.get_board_size() * board.get_board_size()
	var rewards := reward_calc.calculate_rewards(difficulty, _mistakes, _time_elapsed, numbers_placed, level_id)
	
	var xp_reward: int = rewards.xp
	var gold_reward: int = rewards.gold
	
	# US-E.2: Star rating based on difficulty
	# Breezy = max 1 star (bronze), Normal = max 2 stars (silver), Hard = max 3 stars (gold)
	var stars: int
	var star_type: String
	match difficulty:
		"breezy":
			stars = 1
			star_type = "bronze"
		"normal":
			stars = 2
			star_type = "silver"
		"hard":
			stars = 3
			star_type = "gold"
		_:
			stars = rewards.stars
			star_type = "silver"
	
	_session_gold = gold_reward
	
	# Load or create PlayerProgress and update it (Story 3.3: Star Rating)
	var saved_data: Dictionary = SaveManager.get_value("player_progress", {})
	var player_progress: PlayerProgress
	if saved_data.is_empty():
		player_progress = PlayerProgress.new()
	else:
		player_progress = PlayerProgress.from_dict(saved_data)
	
	# Update progress with rewards
	player_progress.add_xp(_session_xp)
	player_progress.add_gold(gold_reward)
	player_progress.complete_level(level_id, stars)
	
	# Save updated progress
	SaveManager.set_value("player_progress", player_progress.to_dict())
	
	# Also update legacy save values for compatibility
	SaveManager.set_value("player_gold", player_progress.gold)
	SaveManager.set_value("player_xp", player_progress.current_xp)
	SaveManager.save_game()
	
	# US-G.1: Award XP to equipped pet
	var pet_leveled_up: bool = _award_pet_xp(xp_reward)
	
	# Show win popup with animated rewards display
	# US-E.2: Show star type (bronze/silver/gold)
	rewards_label.text = "+%d XP  +%d 🪙" % [_session_xp, gold_reward]
	var star_emoji: String
	match star_type:
		"bronze": star_emoji = "🥉"
		"silver": star_emoji = "🥈"
		"gold": star_emoji = "🥇"
		_: star_emoji = "⭐"
	stars_label.text = star_emoji + " " + "⭐".repeat(stars) + "☆".repeat(3 - stars)
	win_popup.visible = true
	
	# US-G.1: Show special message if pet leveled up
	if pet_leveled_up:
		_show_pet_message("LEVEL UP! 🎉✨ I got stronger!")
	else:
		_show_pet_message("Amazing! You did it! 🎉")

# =============================================================================
# PET COMPANION
# =============================================================================

func _show_pet_message(msg: String) -> void:
	if not speech_text or not pet_speech:
		return
	speech_text.text = msg
	pet_speech.visible = true
	await get_tree().create_timer(2.5).timeout
	if pet_speech:
		pet_speech.visible = false


func _get_encouragement() -> String:
	var messages: Array[String] = [
		"Great job! 🌟",
		"You're amazing! ✨",
		"Keep going! 💪",
		"Wonderful! 🎉",
		"So smart! 🧠",
		"Yay! 🎊",
		"Perfect! 💯"
	]
	return messages[randi() % messages.size()]


## US-G.1: Award XP to the currently equipped pet
## Returns true if the pet leveled up
func _award_pet_xp(xp_amount: int) -> bool:
	# Get equipped pet ID from save
	var equipped_pet_id: String = SaveManager.get_value("equipped_pet_id", "")
	if equipped_pet_id.is_empty():
		return false
	
	# Load pet data from save
	var pets_data: Array = SaveManager.get_value("owned_pets", [])
	if pets_data.is_empty():
		return false
	
	# Find the equipped pet and add XP
	var leveled_up: bool = false
	for i in range(pets_data.size()):
		var pet_dict: Dictionary = pets_data[i]
		if pet_dict.get("id", "") == equipped_pet_id:
			# Add XP to this pet
			var current_xp: int = pet_dict.get("xp", 0)
			var current_level: int = pet_dict.get("level", 1)
			
			# Calculate XP needed for next level (same formula as PetInstance)
			var xp_needed: int = int(100 * pow(1.15, current_level - 1))
			
			current_xp += xp_amount
			
			# Check for level up
			if current_xp >= xp_needed:
				current_xp -= xp_needed
				current_level += 1
				leveled_up = true
			
			# Update pet data
			pet_dict["xp"] = current_xp
			pet_dict["level"] = current_level
			pets_data[i] = pet_dict
			
			# Save updated pets
			SaveManager.set_value("owned_pets", pets_data)
			SaveManager.save_game()
			break
	
	return leveled_up

# =============================================================================
# BUTTON HANDLERS
# =============================================================================

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")


func _on_undo_pressed() -> void:
	board.undo_last_move()


func _on_hint_pressed() -> void:
	# Story 2.2: Hint system with educational explanation
	var hint_message: String = board.show_hint()
	_show_pet_message(hint_message + " 💡")


func _on_erase_pressed() -> void:
	"""Clear the selected cell's value"""
	if board._selected_cell >= 0:
		# Check if it's not a given cell
		if board._puzzle.starting_grid[board._selected_cell] == 0:
			board.clear_selected_cell()
		else:
			_show_pet_message("Can't erase that one! 🔒")


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")


# =============================================================================
# US-C.5: PET INTERACTION BUTTONS
# =============================================================================

func _on_pet_button_pressed() -> void:
	"""Pet the companion - triggers happy animation"""
	_play_pet_bounce_animation()
	_show_pet_message("*purrs happily* 💕")


func _on_feed_button_pressed() -> void:
	"""Feed the companion - costs gold, happiness effect"""
	var gold: int = SaveManager.get_value("player_gold", 0)
	if gold >= 10:
		SaveManager.set_value("player_gold", gold - 10)
		_play_pet_bounce_animation()
		_show_pet_message("Yummy! Thank you! 🍖")
		_update_ui()
	else:
		_show_pet_message("Need more gold! 🪙")


func _on_change_button_pressed() -> void:
	"""Change pet companion - open selection window"""
	var window = preload("res://scenes/pets/pet_selection_window.tscn").instantiate()
	add_child(window)
	window.pet_selected.connect(_on_pet_selected)


func _on_pet_selected(pet_id: String) -> void:
	"""Handle pet selection from window"""
	# Update save
	SaveManager.set_value("equipped_pet_id", pet_id)
	SaveManager.save_game()
	
	# Update sprite
	var pets_data: Array = SaveManager.get_value("owned_pets", [])
	var species: String = "cat"
	
	for p in pets_data:
		if p.get("id") == pet_id:
			species = p.get("species_id", "cat")
			break
	
	var path: String = "res://assets/sprites/pets/%s.png" % species
	if ResourceLoader.exists(path):
		if pet_sprite:
			pet_sprite.texture = load(path)
	
	_show_pet_message("I choose you! ✨")
	_play_pet_bounce_animation()


func _play_pet_bounce_animation() -> void:
	"""Play a bounce animation on the pet sprite for happy responses"""
	if not pet_sprite:
		return
	
	var tween := create_tween()
	tween.tween_property(pet_sprite, "scale", Vector2(1.2, 0.8), 0.1)
	tween.tween_property(pet_sprite, "scale", Vector2(0.9, 1.15), 0.1)
	tween.tween_property(pet_sprite, "scale", Vector2(1.05, 0.95), 0.08)
	tween.tween_property(pet_sprite, "scale", Vector2(1.0, 1.0), 0.08)
