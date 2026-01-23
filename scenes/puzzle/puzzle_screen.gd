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

@onready var board: Control = $CenterContainer/MainVBox/BoardContainer/SudokuBoard
@onready var number_pad: HBoxContainer = $CenterContainer/MainVBox/BottomBar/NumberPad
@onready var pencil_button: Button = $CenterContainer/MainVBox/BottomBar/PencilButton

# Top Bar Nodes - UI-SPEC 1.2: Currency Display
@onready var gems_label: Label = $CenterContainer/MainVBox/TopBar/CurrencyBox/GemsLabel
@onready var coins_label: Label = $CenterContainer/MainVBox/TopBar/CurrencyBox/CoinsLabel
@onready var timer_label: Label = $CenterContainer/MainVBox/TopBar/TimerLabel
@onready var heart_container: HBoxContainer = $CenterContainer/MainVBox/TopBar/HeartContainer

# Pet companion - bottom right corner
@onready var pet_sprite: TextureRect = $PetCompanion/PetSprite
@onready var pet_speech: PanelContainer = $PetCompanion/SpeechBubble
@onready var speech_text: Label = $PetCompanion/SpeechBubble/SpeechText

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

var _selected_number: int = 0
var _session_xp: int = 0
var _session_gold: int = 0
var _mistakes: int = 0
var _lives: int = 3
var _timer_active: bool = true
var _time_elapsed: float = 0.0
var _pencil_mode: bool = false
var _number_buttons: Array[Button] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
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
	
	_show_pet_message("Let's solve this puzzle!")


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
	var board_size: int = board.get_board_size()
	
	for i in range(1, board_size + 1):
		var btn := Button.new()
		btn.custom_minimum_size = Vector2(55, 55)
		btn.text = str(i)
		btn.focus_mode = Control.FOCUS_NONE
		
		# Style the button with gem color
		_style_number_button(btn, i)
		
		btn.pressed.connect(_on_number_button_pressed.bind(i))
		number_pad.add_child(btn)
		_number_buttons.append(btn)


func _style_number_button(btn: Button, num: int) -> void:
	"""Style a number button with its gem color"""
	var color: Color = NUMBER_COLORS[num - 1]
	
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = color.darkened(0.3)
	
	# Add shadow effect
	style.shadow_color = Color(0, 0, 0, 0.3)
	style.shadow_size = 3
	style.shadow_offset = Vector2(2, 2)
	
	btn.add_theme_stylebox_override("normal", style)
	btn.add_theme_stylebox_override("hover", style)
	btn.add_theme_stylebox_override("pressed", style)
	btn.add_theme_font_size_override("font_size", 24)
	btn.add_theme_color_override("font_color", Color.WHITE)


func _style_pencil_button() -> void:
	"""Style the pencil toggle button"""
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.3, 0.3, 0.35)
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_right = 10
	style.corner_radius_bottom_left = 10
	
	pencil_button.add_theme_stylebox_override("normal", style)
	
	var pressed_style := StyleBoxFlat.new()
	pressed_style.bg_color = Color(0.5, 0.4, 0.2)  # Amber when active
	pressed_style.corner_radius_top_left = 10
	pressed_style.corner_radius_top_right = 10
	pressed_style.corner_radius_bottom_right = 10
	pressed_style.corner_radius_bottom_left = 10
	pressed_style.border_width_left = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_bottom = 2
	pressed_style.border_color = Color("#FFD700")
	
	pencil_button.add_theme_stylebox_override("pressed", pressed_style)


func _highlight_selected_number(num: int) -> void:
	"""Highlight the currently selected number button"""
	for i in range(_number_buttons.size()):
		var btn: Button = _number_buttons[i]
		var btn_num: int = i + 1
		var color: Color = NUMBER_COLORS[i]
		
		var style := StyleBoxFlat.new()
		style.corner_radius_top_left = 10
		style.corner_radius_top_right = 10
		style.corner_radius_bottom_right = 10
		style.corner_radius_bottom_left = 10
		
		if btn_num == num:
			# Selected - add glow border
			style.bg_color = color.lightened(0.1)
			style.border_width_left = 3
			style.border_width_top = 3
			style.border_width_right = 3
			style.border_width_bottom = 3
			style.border_color = Color("#FFD700")  # Gold border
			style.expand_margin_left = 2
			style.expand_margin_top = 2
			style.expand_margin_right = 2
			style.expand_margin_bottom = 2
		else:
			# Not selected
			style.bg_color = color
			style.border_width_left = 2
			style.border_width_top = 2
			style.border_width_right = 2
			style.border_width_bottom = 2
			style.border_color = color.darkened(0.3)
		
		style.shadow_color = Color(0, 0, 0, 0.3)
		style.shadow_size = 3
		style.shadow_offset = Vector2(2, 2)
		
		btn.add_theme_stylebox_override("normal", style)
		btn.add_theme_stylebox_override("hover", style)

# =============================================================================
# INPUT HANDLERS
# =============================================================================

func _on_pencil_toggled(toggled_on: bool) -> void:
	_pencil_mode = toggled_on
	# Clear number selection when entering pencil mode
	if toggled_on:
		_selected_number = 0
		board.set_selected_number(0)
		_highlight_selected_number(0)


func _on_number_button_pressed(num: int) -> void:
	if _pencil_mode:
		# In pencil mode, toggle note on selected cell
		board.set_selected_number(0)
		if board._selected_cell != -1:
			board.toggle_note(board._selected_cell, num)
	else:
		# Normal mode - select number for placement
		_selected_number = num
		board.set_selected_number(num)
		_highlight_selected_number(num)

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
	"""Update heart display - UI-SPEC 4.1: Lives System"""
	if not heart_container:
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


func _on_cell_wrong(explanation: String) -> void:
	_mistakes += 1
	_lives -= 1
	_update_lives_ui()
	
	if _lives <= 0:
		_handle_game_over()
	else:
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
	var reward_calc := RewardCalculator.new()
	var numbers_placed: int = board.get_board_size() * board.get_board_size()
	var rewards := reward_calc.calculate_rewards(difficulty, _mistakes, _time_elapsed, numbers_placed)
	
	var xp_reward: int = rewards.xp
	var gold_reward: int = rewards.gold
	var stars: int = rewards.stars
	
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
	
	# Show win popup with animated rewards display
	rewards_label.text = "+%d XP  +%d 🪙" % [_session_xp, gold_reward]
	stars_label.text = "⭐".repeat(stars) + "☆".repeat(3 - stars)
	win_popup.visible = true
	
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
	_selected_number = 0
	board.set_selected_number(0)
	_highlight_selected_number(0)


func _on_continue_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")
