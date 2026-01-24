## WorldMapScreen - Level selection with scrollable path (Story 3.1)
## "Candy Crush" style world map with biomes and level nodes
extends Control


## Signal when a level is selected for play
signal level_selected(level_id: int, difficulty: String)

# =============================================================================
# CONSTANTS - Biome themes and level configuration
# =============================================================================

const BIOME_COLORS: Dictionary = {
	"meadow": Color("#90EE90"),     # Light green - levels 1-10
	"beach": Color("#87CEEB"),      # Sky blue - levels 11-20
	"forest": Color("#228B22"),     # Forest green - levels 21-30
	"mountain": Color("#A0522D"),   # Sienna brown - levels 31-40
	"cloud": Color("#E6E6FA"),      # Lavender - levels 41-50
}

const LEVELS_PER_BIOME: int = 10
const TOTAL_LEVELS: int = 50

## LV-2: Board size for each level (1-50)
## More 4x4 early, scaling to larger boards later
## Note: Valid sizes are 4, 6, 9, 10 (no 8x8 in PuzzleData)
const LEVEL_BOARD_SIZES: Dictionary = {
	# Meadow (1-10): Mostly 4x4, some 6x6
	1: 4, 2: 4, 3: 4, 4: 4, 5: 4, 6: 6, 7: 4, 8: 6, 9: 4, 10: 6,
	# Beach (11-20): Mix of 4x4, 6x6, first 9x9
	11: 4, 12: 6, 13: 4, 14: 6, 15: 6, 16: 9, 17: 4, 18: 6, 19: 9, 20: 6,
	# Forest (21-30): More 6x6, 9x9
	21: 6, 22: 6, 23: 9, 24: 6, 25: 9, 26: 9, 27: 6, 28: 9, 29: 9, 30: 9,
	# Mountain (31-40): 6x6, 9x9, 10x10
	31: 6, 32: 9, 33: 9, 34: 9, 35: 9, 36: 9, 37: 10, 38: 9, 39: 9, 40: 10,
	# Cloud (41-50): Large boards - 9x9, 10x10
	41: 9, 42: 9, 43: 9, 44: 10, 45: 9, 46: 10, 47: 9, 48: 10, 49: 10, 50: 10,
}



# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var level_path_container: VBoxContainer = $ScrollContainer/LevelPathContainer
@onready var header_gold: Label = $Header/HBox/GoldLabel
@onready var header_stars: Label = $Header/HBox/StarsLabel
@onready var level_popup: PanelContainer = $LevelPopup
@onready var popup_dimmer: ColorRect = $PopupDimmer
@onready var popup_title: Label = $LevelPopup/VBox/TitleLabel
@onready var popup_stars: Label = $LevelPopup/VBox/StarsLabel
@onready var popup_best_time: Label = $LevelPopup/VBox/BestTimeLabel

# =============================================================================
# STATE
# =============================================================================

var _level_nodes: Array[Control] = []
var _selected_level: int = -1
var _player_progress: PlayerProgress


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_load_player_progress()
	_build_level_path()
	_update_header()
	_hide_popup()
	
	# US-A.1: Scroll to bottom (level 1) initially - levels are built in reverse order
	await get_tree().process_frame
	await get_tree().process_frame  # Extra frame for layout to settle
	_scroll_to_bottom()


func _load_player_progress() -> void:
	"""Load or create player progress from SaveManager"""
	var saved_data: Dictionary = SaveManager.get_value("player_progress", {})
	if saved_data.is_empty():
		_player_progress = PlayerProgress.new()
		_player_progress.gold = 100  # Starting gold
	else:
		_player_progress = PlayerProgress.from_dict(saved_data)
	
	# Sync from legacy 'player_gold' key if it exists and is different
	var legacy_gold: int = SaveManager.get_value("player_gold", _player_progress.gold)
	if legacy_gold != _player_progress.gold:
		# Use the higher value to avoid losing gold
		_player_progress.gold = maxi(legacy_gold, _player_progress.gold)



func _save_player_progress() -> void:
	SaveManager.set_value("player_progress", _player_progress.to_dict())
	# Sync gold to the legacy 'player_gold' key for other screens
	SaveManager.set_value("player_gold", _player_progress.gold)
	SaveManager.save_game()



# =============================================================================
# LEVEL PATH CONSTRUCTION
# =============================================================================

func _build_level_path() -> void:
	"""US-A.1: Build the winding path of level nodes in REVERSE order.
	Level 1 at BOTTOM, higher levels at TOP - scroll UP to progress."""
	_level_nodes.clear()
	
	for child in level_path_container.get_children():
		child.queue_free()
	
	var current_biome: String = ""
	
	# Build in REVERSE order (highest level first, so it appears at top)
	for level_id in range(TOTAL_LEVELS, 0, -1):
		# Check for biome change (still check in forward order for correct headers)
		var biome: String = _get_biome_for_level(level_id)
		
		# Add biome header when entering a new biome (from top)
		var next_level_biome: String = _get_biome_for_level(level_id + 1) if level_id < TOTAL_LEVELS else ""
		if biome != next_level_biome:
			_add_biome_header(biome, level_id)
		
		# Create level node
		var node: Control = _create_level_node(level_id)
		level_path_container.add_child(node)
	
	# Rebuild _level_nodes array in correct order (1 to TOTAL_LEVELS)
	_level_nodes.clear()
	for level_id in range(1, TOTAL_LEVELS + 1):
		# Find the node for this level in the container
		for child in level_path_container.get_children():
			if child.has_meta("level_id") and child.get_meta("level_id") == level_id:
				_level_nodes.append(child)
				break


func _get_biome_for_level(level_id: int) -> String:
	var biome_index: int = (level_id - 1) / LEVELS_PER_BIOME
	match biome_index:
		0: return "meadow"
		1: return "beach"
		2: return "forest"
		3: return "mountain"
		4: return "cloud"
	return "meadow"


func _add_biome_header(biome: String, start_level: int) -> void:
	"""Add a decorative biome header"""
	var header := Panel.new()
	header.custom_minimum_size = Vector2(0, 60)
	
	var style := StyleBoxFlat.new()
	style.bg_color = BIOME_COLORS.get(biome, Color.WHITE).darkened(0.2)
	style.corner_radius_top_left = 15
	style.corner_radius_top_right = 15
	style.corner_radius_bottom_left = 15
	style.corner_radius_bottom_right = 15
	header.add_theme_stylebox_override("panel", style)
	
	var label := Label.new()
	label.text = "🌿 " + biome.capitalize() + " World"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color.WHITE)
	header.add_child(label)
	
	level_path_container.add_child(header)


func _create_level_node(level_id: int) -> Control:
	"""Create a single level node with lock/unlock/stars display"""
	var is_unlocked: bool = true  # LV-1: All levels unlocked for testing

	var stars: int = _player_progress.level_stars.get(level_id, 0)
	var biome: String = _get_biome_for_level(level_id)
	
	# Container for centering with zigzag offset
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 90)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.set_meta("level_id", level_id)  # Store level_id for lookup
	
	# Add spacer for zigzag pattern (alternate left/right)
	if level_id % 2 == 0:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(100, 0)
		row.add_child(spacer)
	
	# Level button
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(70, 70)
	btn.focus_mode = Control.FOCUS_NONE
	
	var btn_style := StyleBoxFlat.new()
	btn_style.corner_radius_top_left = 35
	btn_style.corner_radius_top_right = 35
	btn_style.corner_radius_bottom_left = 35
	btn_style.corner_radius_bottom_right = 35
	
	if is_unlocked:
		btn_style.bg_color = BIOME_COLORS.get(biome, Color.WHITE)
		btn_style.border_width_left = 4
		btn_style.border_width_top = 4
		btn_style.border_width_right = 4
		btn_style.border_width_bottom = 4
		btn_style.border_color = Color.WHITE
		btn.text = str(level_id)
		btn.add_theme_font_size_override("font_size", 24)
		btn.add_theme_color_override("font_color", Color.WHITE)
		btn.pressed.connect(_on_level_pressed.bind(level_id))
	else:
		btn_style.bg_color = Color(0.3, 0.3, 0.35, 0.8)
		btn_style.border_width_left = 2
		btn_style.border_width_top = 2
		btn_style.border_width_right = 2
		btn_style.border_width_bottom = 2
		btn_style.border_color = Color(0.5, 0.5, 0.5)
		btn.text = "🔒"
		btn.add_theme_font_size_override("font_size", 20)
	
	btn.add_theme_stylebox_override("normal", btn_style)
	btn.add_theme_stylebox_override("hover", btn_style)
	btn.add_theme_stylebox_override("pressed", btn_style)
	
	# Vertical container for button + stars
	var vbox := VBoxContainer.new()
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	vbox.add_child(btn)
	
	# Stars display
	if is_unlocked:
		var stars_label := Label.new()
		stars_label.text = "★".repeat(stars) + "☆".repeat(3 - stars)
		stars_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		stars_label.add_theme_font_size_override("font_size", 16)
		stars_label.add_theme_color_override("font_color", Color("#FFD700") if stars > 0 else Color(0.5, 0.5, 0.5))
		vbox.add_child(stars_label)
		
		# LV-3: Board size label
		var board_size: int = LEVEL_BOARD_SIZES.get(level_id, 4)
		var size_label := Label.new()
		size_label.text = "%d×%d" % [board_size, board_size]
		size_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		size_label.add_theme_font_size_override("font_size", 12)
		size_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.5))
		vbox.add_child(size_label)

	
	row.add_child(vbox)
	
	# Add spacer for opposite side zigzag
	if level_id % 2 == 1:
		var spacer := Control.new()
		spacer.custom_minimum_size = Vector2(100, 0)
		row.add_child(spacer)
	
	return row


# =============================================================================
# SCROLLING
# =============================================================================

func _scroll_to_bottom() -> void:
	"""US-A.1: Scroll to bottom where level 1 is located"""
	if scroll_container:
		scroll_container.scroll_vertical = scroll_container.get_v_scroll_bar().max_value


func _scroll_to_level(level_id: int) -> void:
	"""Smoothly scroll to bring a level into view"""
	if level_id < 1 or level_id > _level_nodes.size():
		return
	
	var node: Control = _level_nodes[level_id - 1]
	var target_scroll: int = int(node.position.y - scroll_container.size.y / 2)
	scroll_container.scroll_vertical = maxi(0, target_scroll)


# =============================================================================
# LEVEL SELECTION
# =============================================================================

func _on_level_pressed(level_id: int) -> void:
	"""Handle level button press"""
	_selected_level = level_id
	_show_level_popup(level_id)


func _show_level_popup(level_id: int) -> void:
	"""US-E.3: Show beautiful popup with level details and difficulty options"""
	var stars: int = _player_progress.level_stars.get(level_id, 0)
	
	popup_title.text = "Level %d" % level_id
	popup_stars.text = "Best: " + "★".repeat(stars) + "☆".repeat(3 - stars)
	popup_best_time.text = ""  # TODO: Track best times
	
	popup_dimmer.visible = true
	level_popup.visible = true


func _hide_popup() -> void:
	popup_dimmer.visible = false
	level_popup.visible = false
	_selected_level = -1


# =============================================================================
# UI UPDATES
# =============================================================================

func _update_header() -> void:
	"""Update header with player stats"""
	header_gold.text = "🪙 %d" % _player_progress.gold
	header_stars.text = "⭐ %d" % _player_progress.get_total_stars()


# =============================================================================
# BUTTON HANDLERS
# =============================================================================

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main/main_menu.tscn")


func _on_play_breezy_pressed() -> void:
	"""US-E.1: Breezy mode - unlimited mistakes, relaxed gameplay"""
	if _selected_level > 0:
		SaveManager.set_value("current_level_id", _selected_level)
		SaveManager.set_value("current_difficulty", "breezy")
		SaveManager.set_value("current_board_size", LEVEL_BOARD_SIZES.get(_selected_level, 4))
		get_tree().change_scene_to_file("res://scenes/puzzle/puzzle_screen.tscn")


func _on_play_normal_pressed() -> void:
	if _selected_level > 0:
		SaveManager.set_value("current_level_id", _selected_level)
		SaveManager.set_value("current_difficulty", "normal")
		SaveManager.set_value("current_board_size", LEVEL_BOARD_SIZES.get(_selected_level, 4))
		get_tree().change_scene_to_file("res://scenes/puzzle/puzzle_screen.tscn")


func _on_play_hard_pressed() -> void:
	if _selected_level > 0:
		SaveManager.set_value("current_level_id", _selected_level)
		SaveManager.set_value("current_difficulty", "hard")
		SaveManager.set_value("current_board_size", LEVEL_BOARD_SIZES.get(_selected_level, 4))
		get_tree().change_scene_to_file("res://scenes/puzzle/puzzle_screen.tscn")



func _on_close_popup_pressed() -> void:
	_hide_popup()
