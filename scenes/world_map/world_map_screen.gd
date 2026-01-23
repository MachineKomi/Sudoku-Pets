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



# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var scroll_container: ScrollContainer = $ScrollContainer
@onready var level_path_container: VBoxContainer = $ScrollContainer/LevelPathContainer
@onready var header_gold: Label = $Header/GoldLabel
@onready var header_stars: Label = $Header/StarsLabel
@onready var level_popup: PanelContainer = $LevelPopup
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
	
	# Scroll to highest unlocked level
	await get_tree().process_frame
	_scroll_to_level(_player_progress.highest_unlocked_level)


func _load_player_progress() -> void:
	"""Load or create player progress from SaveManager"""
	var saved_data: Dictionary = SaveManager.get_value("player_progress", {})
	if saved_data.is_empty():
		_player_progress = PlayerProgress.new()
		_player_progress.gold = 100  # Starting gold
	else:
		_player_progress = PlayerProgress.from_dict(saved_data)


func _save_player_progress() -> void:
	SaveManager.set_value("player_progress", _player_progress.to_dict())
	SaveManager.save_game()


# =============================================================================
# LEVEL PATH CONSTRUCTION
# =============================================================================

func _build_level_path() -> void:
	"""Build the winding path of level nodes"""
	_level_nodes.clear()
	
	for child in level_path_container.get_children():
		child.queue_free()
	
	var current_biome: String = ""
	
	for level_id in range(1, TOTAL_LEVELS + 1):
		# Check for biome change
		var biome: String = _get_biome_for_level(level_id)
		if biome != current_biome:
			current_biome = biome
			_add_biome_header(biome, level_id)
		
		# Create level node
		var node: Control = _create_level_node(level_id)
		level_path_container.add_child(node)
		_level_nodes.append(node)


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
	var is_unlocked: bool = level_id <= _player_progress.highest_unlocked_level
	var stars: int = _player_progress.level_stars.get(level_id, 0)
	var biome: String = _get_biome_for_level(level_id)
	
	# Container for centering with zigzag offset
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 90)
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	
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
	"""Show popup with level details and play button"""
	var stars: int = _player_progress.level_stars.get(level_id, 0)
	
	popup_title.text = "Level %d" % level_id
	popup_stars.text = "Best: " + "★".repeat(stars) + "☆".repeat(3 - stars)
	popup_best_time.text = ""  # TODO: Track best times
	
	level_popup.visible = true


func _hide_popup() -> void:
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


func _on_play_normal_pressed() -> void:
	if _selected_level > 0:
		# Store selected level for puzzle screen to load
		SaveManager.set_value("current_level_id", _selected_level)
		SaveManager.set_value("current_difficulty", "normal")
		get_tree().change_scene_to_file("res://scenes/puzzle/puzzle_screen.tscn")


func _on_play_hard_pressed() -> void:
	if _selected_level > 0:
		SaveManager.set_value("current_level_id", _selected_level)
		SaveManager.set_value("current_difficulty", "hard")
		get_tree().change_scene_to_file("res://scenes/puzzle/puzzle_screen.tscn")


func _on_close_popup_pressed() -> void:
	_hide_popup()
