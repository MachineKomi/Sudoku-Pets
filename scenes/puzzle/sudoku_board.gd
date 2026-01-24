## SudokuBoard - Manages the Sudoku grid and gameplay
## 
## IMPORTANT FOR AI AGENTS:
## - All Array/Dictionary constants MUST have explicit types (Godot 4.5.1 strict mode)
## - Gem sprites are loaded from assets/sprites/gems/gem_X.png
## - Reference: AGENTS.md "GDScript Standards" section
##
extends Control

signal cell_filled_correct
signal cell_filled_wrong(explanation: String)
signal puzzle_completed
signal gold_earned(amount: int)  # US-D.3: Signal for gold conversion animation

# =============================================================================
# CONSTANTS
# =============================================================================

## Cell size in pixels - DO NOT REMOVE - used by _build_grid() and _create_cell()
const CELL_SIZE: int = 80

## Path to gem sprites - files must be named gem_1.png through gem_10.png
const GEM_SPRITE_PATH: String = "res://assets/sprites/gems/gem_%d.png"
const GEM_GLOWING_PATH: String = "res://assets/sprites/gems/gem_%d_glowing.png"
const GEM_DRAFTNOTE_PATH: String = "res://assets/sprites/gems/gem_%d_draftnote.png"


## Selection highlight color - bright gold
const SELECTION_COLOR: Color = Color("#FFD700")

## US-C.2: Bright, cozy theme colors (Kirby-inspired)
## US-I.3: Added highlighting colors for row/col/region and same-number
const THEME_COLORS: Dictionary = {
	"cell_empty": Color("#F5F0E6"),       # Warm cream for empty cells
	"cell_filled": Color("#FFF8F0"),      # Light cream for filled cells
	"cell_selected_bg": Color("#FFE4B5"), # Moccasin for selected cell
	"cell_related_bg": Color("#FFF5E6"),  # US-I.3: Light peach for row/col/region cells
	"cell_same_number": Color("#E8F5E9"), # US-I.3: Light mint for same-number cells
	"border_thin": Color("#D4C4B0"),      # Soft brown for cell borders
	"border_thick": Color("#8B7355"),     # Medium brown for segment borders
	"border_outer": Color("#6B5344"),     # Dark brown for outer border
	"segment_alt": Color("#F0EBE0"),      # Slightly darker cream for alternating segments
}

## Fallback colors if sprites fail to load
const GEM_COLORS: Array[Color] = [
	Color("#E63946"), Color("#F4A261"), Color("#F9C74F"),
	Color("#2A9D8F"), Color("#00B4D8"), Color("#4361EE"),
	Color("#7209B7"), Color("#F72585"), Color("#E0E0E0"),
	Color("#9B59B6"),  # gem_10 - Purple for 10x10 boards
]

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var grid_container: GridContainer = $GridContainer

# =============================================================================
# STATE VARIABLES
# =============================================================================

var _puzzle: PuzzleData
var _current_grid: Array[int] = []
var _notes_grid: Array = []
var _cells: Array[Control] = []  # Now using Control (Panel with TextureRect)
var _cell_buttons: Array[Button] = []  # Invisible buttons for click detection
var _cell_sprites: Array[TextureRect] = []  # Gem sprite displays
var _cell_notes: Array[Label] = []  # Notes labels (legacy fallback)
var _cell_notes_grids: Array[GridContainer] = []  # DN-1: GridContainers for draftnote sprites
var _selected_cell: int = -1

var _selected_number: int = 0
var _move_history: Array[Dictionary] = []
var _generator := SudokuGenerator.new()
var _validator := SudokuValidator.new()

## Preloaded gem textures
var _gem_textures: Array[Texture2D] = []
var _gem_textures_glowing: Array[Texture2D] = []
var _gem_textures_draftnote: Array[Texture2D] = []

## Track cells that are part of completed lines/boxes (keep glowing)
var _completed_cells: Array[int] = []


# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_preload_gem_textures()
	
	# LV-2: Read board size from level selection
	var board_size_val: int = SaveManager.get_value("current_board_size", 4)
	var board_size: PuzzleData.BoardSize = _int_to_board_size(board_size_val)
	
	# Read difficulty from level selection
	var difficulty_str: String = SaveManager.get_value("current_difficulty", "normal")
	var difficulty: PuzzleData.Difficulty = _str_to_difficulty(difficulty_str)
	
	_start_new_puzzle(board_size, difficulty)


func _int_to_board_size(size: int) -> PuzzleData.BoardSize:
	"""Convert integer board size to enum
	Note: Only valid sizes are 2, 4, 6, 9, 10 (no 8x8 in PuzzleData)"""
	match size:
		4: return PuzzleData.BoardSize.SIZE_4X4
		6: return PuzzleData.BoardSize.SIZE_6X6
		9: return PuzzleData.BoardSize.SIZE_9X9
		10: return PuzzleData.BoardSize.SIZE_10X10
		_: return PuzzleData.BoardSize.SIZE_4X4



func _str_to_difficulty(diff: String) -> PuzzleData.Difficulty:
	"""Convert string difficulty to enum"""
	match diff:
		"easy", "breezy": return PuzzleData.Difficulty.EASY
		"normal": return PuzzleData.Difficulty.MEDIUM
		"hard": return PuzzleData.Difficulty.HARD
		_: return PuzzleData.Difficulty.EASY



func _draw() -> void:
	if not _puzzle:
		return
	_draw_grid_lines()
	_draw_selection_highlight()

# =============================================================================
# TEXTURE LOADING
# =============================================================================

func _preload_gem_textures() -> void:
	"""Preload all gem texture variants: normal, glowing, draftnote (1-10)"""
	_gem_textures.clear()
	_gem_textures_glowing.clear()
	_gem_textures_draftnote.clear()
	
	for i in range(1, 11):
		# Normal gem
		var normal_path: String = GEM_SPRITE_PATH % i
		var normal_tex: Texture2D = load(normal_path) as Texture2D
		_gem_textures.append(normal_tex)
		
		# Glowing gem
		var glowing_path: String = GEM_GLOWING_PATH % i
		var glowing_tex: Texture2D = load(glowing_path) as Texture2D
		_gem_textures_glowing.append(glowing_tex if glowing_tex else normal_tex)
		
		# Draftnote gem
		var draftnote_path: String = GEM_DRAFTNOTE_PATH % i
		var draftnote_tex: Texture2D = load(draftnote_path) as Texture2D
		_gem_textures_draftnote.append(draftnote_tex if draftnote_tex else normal_tex)


# =============================================================================
# PUBLIC API
# =============================================================================

func get_board_size() -> int:
	return _puzzle.get_grid_dimension() if _puzzle else 4


func set_selected_number(num: int) -> void:
	# DEPRECATED: This was used for toggle-based input
	# Kept for compatibility but no longer used in click-to-place mode
	_selected_number = num


func place_number_in_selected_cell(num: int) -> void:
	"""US-B.1: Place a number in the currently selected cell immediately.
	Called directly when user clicks a number button."""
	if _selected_cell < 0:
		return
	
	# Can't modify given cells
	if _puzzle.starting_grid[_selected_cell] != 0:
		return
	
	# US-Polish: Can't modify CORRECTLY filled cells (Locked)
	var current_val: int = _current_grid[_selected_cell]
	var correct_val: int = _puzzle.get_cell_value(0, 0, true) # Access solution via helper or index
	# Actually puzzle data has get_cell_value.
	var row = _selected_cell / _puzzle.get_grid_dimension()
	var col = _selected_cell % _puzzle.get_grid_dimension()
	if current_val != 0 and current_val == _puzzle.get_cell_value(row, col, true):
		return # Locked
	
	_place_number(_selected_cell, num)


func clear_selected_cell() -> void:
	"""Clear the value in the currently selected cell (erase)."""
	if _selected_cell < 0:
		return
	
	# Can't modify given cells
	if _puzzle.starting_grid[_selected_cell] != 0:
		return
	
	# US-Polish: Can't clear CORRECTLY filled cells (Locked)
	var current_val: int = _current_grid[_selected_cell]
	if current_val != 0:
		var dim = _puzzle.get_grid_dimension()
		var row = _selected_cell / dim
		var col = _selected_cell % dim
		if current_val == _puzzle.get_cell_value(row, col, true):
			return # Locked
	
	var old_value: int = _current_grid[_selected_cell]
	if old_value == 0:
		return  # Already empty
	
	# Add to history for undo
	_move_history.append({
		"index": _selected_cell,
		"old_value": old_value,
		"new_value": 0
	})
	
	_current_grid[_selected_cell] = 0
	_update_cell(_selected_cell)


func toggle_note(index: int, num: int) -> void:
	"""Toggle a pencil mark note on a cell"""
	if _current_grid[index] != 0:
		return
	
	var notes: Array = _notes_grid[index]
	if num in notes:
		notes.erase(num)
	else:
		notes.append(num)
		notes.sort()
	_update_cell(index)


func undo_last_move() -> void:
	if _move_history.is_empty():
		return
	
	var move: Dictionary = _move_history.pop_back()
	_current_grid[move.index] = move.old_value
	_update_cell(move.index)


func show_hint() -> String:
	"""Find a cell with only one possible candidate and highlight it with explanation (Story 2.2)
	
	FIX for US-H.1: Clear previous hint highlight before showing new one
	"""
	var dim: int = _puzzle.get_grid_dimension()
	
	# Clear previous selection/hint highlight
	var old_selected: int = _selected_cell
	if old_selected >= 0 and old_selected < _cells.size():
		_selected_cell = -1  # Clear first
		_update_cell(old_selected)
	
	# First try to find a "naked single" - a cell where only one number works
	for i in range(dim * dim):
		if _current_grid[i] == 0:
			var row: int = i / dim
			var col: int = i % dim
			var candidates: Array[int] = _get_candidates_for_cell(row, col)
			
			if candidates.size() == 1:
				# This is a naked single - explain it!
				var correct: int = candidates[0]
				_selected_cell = i
				_update_cell(i)
				queue_redraw()
				return "Look at this cell! Only a %d can go here!" % correct
	
	# Fallback: just hint the first empty cell with its answer
	for i in range(dim * dim):
		if _current_grid[i] == 0:
			var row: int = i / dim
			var col: int = i % dim
			var correct: int = _puzzle.get_cell_value(row, col, true)
			_selected_cell = i
			_update_cell(i)
			queue_redraw()
			return "Try putting a %d here!" % correct
	
	return "The puzzle is complete!"


func _get_candidates_for_cell(row: int, col: int) -> Array[int]:
	"""Get all valid candidates for a cell (numbers 1-N not in row/col/box)"""
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	var candidates: Array[int] = []
	
	for num in range(1, dim + 1):
		if _validator.is_valid_move(_puzzle, row, col, num, _current_grid):
			candidates.append(num)
	
	return candidates


# =============================================================================
# US-I.3: HIGHLIGHTING HELPERS - Row/Col/Region and Same-Number Highlighting
# =============================================================================

func _is_cell_related_to_selected(index: int) -> bool:
	"""US-I.3: Check if a cell is in the same row, column, or box as the selected cell"""
	if _selected_cell < 0:
		return false
	if index == _selected_cell:
		return false  # Don't mark selected cell as "related"
	
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	
	var sel_row: int = _selected_cell / dim
	var sel_col: int = _selected_cell % dim
	var cell_row: int = index / dim
	var cell_col: int = index % dim
	
	# Same row?
	if cell_row == sel_row:
		return true
	
	# Same column?
	if cell_col == sel_col:
		return true
	
	# Same box?
	var sel_box_row: int = sel_row / box_h
	var sel_box_col: int = sel_col / box_w
	var cell_box_row: int = cell_row / box_h
	var cell_box_col: int = cell_col / box_w
	
	if sel_box_row == cell_box_row and sel_box_col == cell_box_col:
		return true
	
	return false


func _is_same_number_as_selected(index: int) -> bool:
	"""US-I.3: Check if a cell has the same number as the selected cell"""
	if _selected_cell < 0:
		return false
	if index == _selected_cell:
		return false  # Don't mark selected cell as "same number"
	
	var selected_value: int = _current_grid[_selected_cell]
	if selected_value == 0:
		return false  # Selected cell is empty
	
	var cell_value: int = _current_grid[index]
	return cell_value == selected_value


func auto_fill_singles() -> int:
	"""Story 2.3: Auto-fill all naked singles (cells with only one candidate).
	Returns the number of cells that were auto-filled."""
	var dim: int = _puzzle.get_grid_dimension()
	var filled_count: int = 0
	
	for i in range(dim * dim):
		if _current_grid[i] == 0:
			var row: int = i / dim
			var col: int = i % dim
			var candidates: Array[int] = _get_candidates_for_cell(row, col)
			
			if candidates.size() == 1:
				# Auto-fill this naked single
				_current_grid[i] = candidates[0]
				_notes_grid[i] = []
				_update_cell(i)
				filled_count += 1
	
	if filled_count > 0:
		queue_redraw()
		cell_filled_correct.emit()
		_check_completion()
	
	return filled_count

# =============================================================================
# PUZZLE MANAGEMENT
# =============================================================================

func _start_new_puzzle(size: PuzzleData.BoardSize, difficulty: PuzzleData.Difficulty) -> void:
	_puzzle = _generator.generate(size, difficulty)
	_current_grid = _puzzle.starting_grid.duplicate()
	
	_notes_grid.clear()
	for i in range(_current_grid.size()):
		_notes_grid.append([])
	
	_move_history.clear()
	_selected_cell = -1
	_build_grid()


func _build_grid() -> void:
	# Clear existing cells
	for child in grid_container.get_children():
		child.queue_free()
	_cells.clear()
	_cell_buttons.clear()
	_cell_sprites.clear()
	_cell_notes.clear()
	_cell_notes_grids.clear()  # DN-1: Clear notes grids

	
	var dim: int = _puzzle.get_grid_dimension()
	grid_container.columns = dim
	
	var gap: int = 2
	var total_size: int = dim * CELL_SIZE + (dim - 1) * gap
	custom_minimum_size = Vector2(total_size, total_size)
	
	for i in range(dim * dim):
		var cell: Control = _create_cell(i)
		grid_container.add_child(cell)
		_cells.append(cell)
	
	_update_all_cells()
	queue_redraw()

# =============================================================================
# CELL CREATION - Using TextureRect for gem sprites
# =============================================================================

func _create_cell(index: int) -> Control:
	"""Create a cell with layered components: background panel, gem sprite, notes label, click button
	
	Structure: Control (container)
	  └─ Panel (Background) - colored background with border
	  └─ TextureRect (GemSprite) - displays gem image, centered with padding
	  └─ Label (NotesLabel) - pencil mark notes in grid format
	  └─ Button (ClickArea) - invisible, handles click input
	"""
	
	# Container for all cell elements
	var container := Control.new()
	container.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	container.size = Vector2(CELL_SIZE, CELL_SIZE)
	
	# Background panel
	var panel := Panel.new()
	panel.set_anchors_preset(Control.PRESET_FULL_RECT)
	panel.name = "Background"
	container.add_child(panel)
	
	# Gem sprite (centered with minimal padding for larger display - US-C.3)
	var sprite := TextureRect.new()
	sprite.name = "GemSprite"
	# Use anchors for proper sizing within cell
	sprite.anchor_left = 0.0
	sprite.anchor_top = 0.0
	sprite.anchor_right = 1.0
	sprite.anchor_bottom = 1.0
	# Reduced padding (0px on each side) for larger gems - US-C.3
	sprite.offset_left = 0
	sprite.offset_top = 0
	sprite.offset_right = 0
	sprite.offset_bottom = 0
	# Stretch mode: keep aspect ratio, center in available space
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	container.add_child(sprite)
	_cell_sprites.append(sprite)
	
	# Notes label (for pencil marks) - legacy fallback
	var notes_label := Label.new()
	notes_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	notes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notes_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notes_label.name = "NotesLabel"
	notes_label.add_theme_font_size_override("font_size", 14)
	notes_label.add_theme_color_override("font_color", Color(0.4, 0.35, 0.3, 0.9))
	notes_label.visible = false  # DN-1: Hidden by default, use grid instead
	container.add_child(notes_label)
	_cell_notes.append(notes_label)
	
	# DN-1: GridContainer for draftnote gem sprites
	var notes_grid := GridContainer.new()
	notes_grid.name = "NotesGrid"
	notes_grid.set_anchors_preset(Control.PRESET_CENTER)
	notes_grid.columns = 2  # 2x2 for 4x4 board, will be updated per board size
	notes_grid.add_theme_constant_override("h_separation", 1)
	notes_grid.add_theme_constant_override("v_separation", 1)
	notes_grid.visible = false
	container.add_child(notes_grid)
	_cell_notes_grids.append(notes_grid)

	
	# Invisible button for click detection (on top)
	var button := Button.new()
	button.set_anchors_preset(Control.PRESET_FULL_RECT)
	button.flat = true
	button.focus_mode = Control.FOCUS_NONE
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.pressed.connect(_on_cell_pressed.bind(index))
	button.name = "ClickArea"
	container.add_child(button)
	_cell_buttons.append(button)
	
	return container

# =============================================================================
# CELL RENDERING
# =============================================================================

func _update_all_cells() -> void:
	for i in range(_cells.size()):
		_update_cell(i)


func _update_cell(index: int) -> void:
	"""US-C.2: Updated with bright, cozy theme colors
	US-I.3: Added row/col/region and same-number highlighting"""
	var cell: Control = _cells[index]
	var panel: Panel = cell.get_node("Background") as Panel
	var sprite: TextureRect = _cell_sprites[index]
	var notes_label: Label = _cell_notes[index]
	
	var value: int = _current_grid[index]
	var is_given: bool = _puzzle.starting_grid[index] != 0
	var is_selected: bool = index == _selected_cell
	var notes: Array = _notes_grid[index]
	
	# US-I.3: Check if this cell is related to selected cell (same row/col/region)
	var is_related: bool = _is_cell_related_to_selected(index)
	# US-I.3: Check if this cell has the same number as selected cell
	var is_same_number: bool = _is_same_number_as_selected(index)
	
	# Create panel style with bright theme
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	
	# Selection highlighting with priority: selected > same_number > related > normal
	if is_selected:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = SELECTION_COLOR
		style.bg_color = THEME_COLORS["cell_selected_bg"]
	elif is_same_number and value != 0:
		# US-I.3: Highlight cells with same number
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color("#4CAF50")  # Green border for same number
		style.bg_color = THEME_COLORS["cell_same_number"]
	elif is_related:
		# US-I.3: Highlight cells in same row/col/region
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = THEME_COLORS["border_thin"]
		style.bg_color = THEME_COLORS["cell_related_bg"]
	else:
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = THEME_COLORS["border_thin"]
		
		if value == 0:
			# Empty cell - warm cream
			style.bg_color = THEME_COLORS["cell_empty"]
		else:
			# Filled cell - light cream
			style.bg_color = THEME_COLORS["cell_filled"]
	
	if value == 0:
		# Empty cell
		sprite.texture = null
		sprite.visible = false
		
		# DN-1: Show notes as draftnote gem sprites in grid
		if not notes.is_empty():
			_update_notes_grid_display(index, notes)
			notes_label.visible = false
		else:
			_update_notes_grid_display(index, [])
			notes_label.visible = false
	else:
		# Filled cell - show gem sprite
		notes_label.visible = false
		_update_notes_grid_display(index, [])  # Clear any notes grid

		
		# Set gem texture (value is 1-10, array is 0-indexed)
		var tex_index: int = value - 1
		if tex_index >= 0 and tex_index < _gem_textures.size():
			var tex: Texture2D
			# GW-1: Use glowing texture for completed cells
			if index in _completed_cells and tex_index < _gem_textures_glowing.size():
				tex = _gem_textures_glowing[tex_index]
			else:
				tex = _gem_textures[tex_index]
			
			if tex:
				sprite.texture = tex
				sprite.visible = true
				sprite.show()
				# Gems are always bright - no dimming for givens
				sprite.modulate = Color.WHITE
			else:
				# Fallback if texture missing - show colored number
				sprite.visible = false
				_show_fallback_number(notes_label, value, is_given)
		else:
			# Value out of range - show fallback
			sprite.visible = false
			_show_fallback_number(notes_label, value, is_given)
	
	panel.add_theme_stylebox_override("panel", style)
	queue_redraw()



func _show_fallback_number(label: Label, value: int, is_given: bool) -> void:
	"""Show number as text if sprite fails to load"""
	label.text = str(value)
	label.add_theme_font_size_override("font_size", 32)
	var color: Color = GEM_COLORS[value - 1] if value <= GEM_COLORS.size() else Color.WHITE
	if is_given:
		color = color.darkened(0.2)
	label.add_theme_color_override("font_color", color)
	label.visible = true


func _format_notes_grid(notes: Array) -> String:
	"""US-B.4: Format notes without placeholder dots - only show actual noted numbers"""
	if notes.is_empty():
		return ""
	
	# Simply join the noted numbers with spaces
	var result: String = ""
	for i in range(notes.size()):
		if i > 0:
			result += " "
		result += str(notes[i])
	
	return result


func _update_notes_grid_display(index: int, notes: Array) -> void:
	"""DN-1/DN-3/DN-4: Update the notes grid with draftnote gem sprites
	- Fixed positions (1 top-left, etc.)
	- Dynamic sizing (larger when fewer, standard when full)
	"""
	if index < 0 or index >= _cell_notes_grids.size():
		return
	
	var notes_grid: GridContainer = _cell_notes_grids[index]
	
	# Clear existing sprites
	for child in notes_grid.get_children():
		child.queue_free()
	
	if notes.is_empty():
		notes_grid.visible = false
		return
	
	# Determine grid columns based on board size
	var dim: int = _puzzle.get_grid_dimension() if _puzzle else 4
	var cols: int = 2 if dim <= 4 else 3  # 2x2 for 4x4, 3x3 for larger
	notes_grid.columns = cols
	
	# Calculate sprite size to fit in cell
	# DN-4: Make them as large as possible
	var sprite_size: int = int(CELL_SIZE / cols) - 2
	
	# DN-3: Fixed positional layout
	# We need to fill slots 1 through dim
	# For each slot i (1..dim), check if 'i' is in 'notes'
	# If yes, show sprite. If no, show empty spacer.
	
	for i in range(1, dim + 1):
		if i in notes:
			# Show sprite
			var tex_index: int = i - 1
			if tex_index >= 0 and tex_index < _gem_textures_draftnote.size():
				var sprite := TextureRect.new()
				sprite.custom_minimum_size = Vector2(sprite_size, sprite_size)
				sprite.texture = _gem_textures_draftnote[tex_index]
				sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
				sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
				notes_grid.add_child(sprite)
			else:
				# Fallback if texture missing
				var spacer := Control.new()
				spacer.custom_minimum_size = Vector2(sprite_size, sprite_size)
				notes_grid.add_child(spacer)
		else:
			# Empty slot
			var spacer := Control.new()
			spacer.custom_minimum_size = Vector2(sprite_size, sprite_size)
			# Make it transparent but take up space
			notes_grid.add_child(spacer)
	
	notes_grid.visible = true




# =============================================================================
# DRAWING
# =============================================================================

func _draw_grid_lines() -> void:
	"""US-C.1: Clear segment/box boundaries with improved visibility"""
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	
	var board_size: Vector2 = size
	
	# Exact pixel calculations matching GridContainer (gap = 2)
	var gap: int = 2

	
	for box_row in range(ceili(float(dim) / box_h)):
		for box_col in range(ceili(float(dim) / box_w)):
			var is_alternate: bool = (box_row + box_col) % 2 == 1
			if is_alternate:
				# Calculate exact position based on cell count and gaps
				var start_col: int = box_col * box_w
				var start_row: int = box_row * box_h
				
				var x: float = start_col * CELL_SIZE + (start_col) * gap
				var y: float = start_row * CELL_SIZE + (start_row) * gap
				
				# Width/Height depends on how many cells in this box (edge case for non-square)
				var cells_w: int = mini(box_w, dim - start_col)
				var cells_h: int = mini(box_h, dim - start_row)
				
				var w: float = cells_w * CELL_SIZE + (cells_w - 1) * gap
				var h: float = cells_h * CELL_SIZE + (cells_h - 1) * gap
				
				draw_rect(Rect2(x - 2, y - 2, w + 4, h + 4), THEME_COLORS["segment_alt"], true)
	
	# Draw thick segment borders
	var segment_color: Color = THEME_COLORS["border_thick"]
	var segment_width: float = 4.0
	
	# Vertical segment lines - Draw lines exactly in the gaps between boxes
	for i in range(1, dim):
		if i % box_w == 0:
			# Gap is between cell i-1 and i
			# Position is after i cells and i-1 gaps, plus half gap
			var x: float = i * CELL_SIZE + (i - 1) * gap + (gap / 2.0)
			draw_line(Vector2(x, 0), Vector2(x, board_size.y), segment_color, segment_width)
	
	# Horizontal segment lines
	for i in range(1, dim):
		if i % box_h == 0:
			var y: float = i * CELL_SIZE + (i - 1) * gap + (gap / 2.0)
			draw_line(Vector2(0, y), Vector2(board_size.x, y), segment_color, segment_width)
	
	# Outer border (thicker and darker)
	var outer_color: Color = THEME_COLORS["border_outer"]
	draw_rect(Rect2(Vector2.ZERO, board_size), outer_color, false, 5.0)


func _draw_selection_highlight() -> void:
	if _selected_cell < 0:
		return
	
	var dim: int = _puzzle.get_grid_dimension()
	var row: int = _selected_cell / dim
	var col: int = _selected_cell % dim
	
	var cell_w: float = size.x / dim
	var cell_h: float = size.y / dim
	
	# Outer glow
	var rect := Rect2(col * cell_w - 2, row * cell_h - 2, cell_w + 4, cell_h + 4)
	draw_rect(rect, SELECTION_COLOR, false, 3.0)

# =============================================================================
# INPUT HANDLING
# =============================================================================

func _on_cell_pressed(index: int) -> void:
	"""US-B.1: Cell click only selects the cell, does NOT auto-place numbers.
	US-I.3: Update all cells to refresh row/col/region and same-number highlighting.
	Numbers are placed by clicking the number buttons after selecting a cell."""
	var old_selected: int = _selected_cell
	_selected_cell = index
	
	# US-I.3: Update ALL cells to refresh highlighting (row/col/region + same-number)
	# This is necessary because highlighting depends on the selected cell
	_update_all_cells()
	queue_redraw()


func _place_number(index: int, num: int) -> void:
	var row: int = index / _puzzle.get_grid_dimension()
	var col: int = index % _puzzle.get_grid_dimension()
	
	# US-Polish: Check correctness BEFORE placing
	if _validator.is_correct_number(_puzzle, row, col, num):
		# Correct! Place it.
		var old_value: int = _current_grid[index]
		
		_move_history.append({
			"index": index,
			"old_value": old_value,
			"new_value": num
		})
		
		# Clear notes when placing
		_notes_grid[index] = []
		_current_grid[index] = num
		_update_cell(index)
		
		# Celebrate
		_celebrate_correct_placement(index, num)
		cell_filled_correct.emit()
		_check_completion()
		
	else:
		# Incorrect! Do NOT place it.
		# Show error feedback
		_flash_cell_error(index)
		_show_error_overlay(index) # Show X
		
		# Identify conflicts - convert Vector2i to int indices
		var dim: int = _puzzle.get_grid_dimension()
		var conflicts = _validator.get_conflicting_cells(_puzzle, row, col, num, _current_grid)
		for conflict in conflicts:
			var conflict_index: int = conflict.y * dim + conflict.x
			_flash_cell_error(conflict_index)
			
		var explanation: String = _validator.get_conflict_explanation(_puzzle, row, col, num, _current_grid)
		if explanation.is_empty():
			explanation = "That's not quite right. Try again!"
		cell_filled_wrong.emit(explanation)
		
		# Note: We do NOT update _current_grid, so cell remains empty/unchanged


func _celebrate_correct_placement(index: int, value: int) -> void:
	"""US-D.1: Satisfying celebration animation for correct number placement.
	Gem glows, scales up, slams down with bounce, and particle-like effect."""
	var sprite: TextureRect = _cell_sprites[index]
	if not sprite:
		return
	
	var color: Color = GEM_COLORS[value - 1] if value <= GEM_COLORS.size() else Color.WHITE
	
	# Create glow effect using modulate
	var original_modulate: Color = sprite.modulate
	
	# Animation sequence using tween
	var tween := create_tween()
	tween.set_parallel(false)
	
	# 1. Quick scale up with glow
	tween.tween_property(sprite, "scale", Vector2(1.25, 1.25), 0.08).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(sprite, "modulate", color.lightened(0.4), 0.08)
	
	# 2. Slam down with bounce
	tween.tween_property(sprite, "scale", Vector2(0.95, 0.95), 0.06).set_ease(Tween.EASE_IN)
	tween.tween_property(sprite, "scale", Vector2(1.08, 1.08), 0.08).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1).set_ease(Tween.EASE_OUT)
	
	# 3. Fade glow back to normal
	tween.parallel().tween_property(sprite, "modulate", original_modulate, 0.15)
	
	# Check for line/segment completion after animation
	tween.tween_callback(_check_line_completion.bind(index))


func _check_line_completion(index: int) -> void:
	"""US-D.2: Check if placing this number completed a row, column, or box"""
	var dim: int = _puzzle.get_grid_dimension()
	var row: int = index / dim
	var col: int = index % dim
	
	# Check row completion
	if _is_row_complete(row):
		_celebrate_line_completion("row", row)
	
	# Check column completion
	if _is_column_complete(col):
		_celebrate_line_completion("column", col)
	
	# Check box completion
	if _is_box_complete(row, col):
		_celebrate_box_completion(row, col)


func _is_row_complete(row: int) -> bool:
	"""Check if all cells in a row are correctly filled"""
	var dim: int = _puzzle.get_grid_dimension()
	for col in range(dim):
		var index: int = row * dim + col
		if _current_grid[index] == 0:
			return false
		if not _validator.is_correct_number(_puzzle, row, col, _current_grid[index]):
			return false
	return true


func _is_column_complete(col: int) -> bool:
	"""Check if all cells in a column are correctly filled"""
	var dim: int = _puzzle.get_grid_dimension()
	for row in range(dim):
		var index: int = row * dim + col
		if _current_grid[index] == 0:
			return false
		if not _validator.is_correct_number(_puzzle, row, col, _current_grid[index]):
			return false
	return true


func _is_box_complete(row: int, col: int) -> bool:
	"""Check if all cells in a box are correctly filled"""
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	
	var box_start_row: int = (row / box_h) * box_h
	var box_start_col: int = (col / box_w) * box_w
	
	for r in range(box_start_row, box_start_row + box_h):
		for c in range(box_start_col, box_start_col + box_w):
			var index: int = r * dim + c
			if _current_grid[index] == 0:
				return false
			if not _validator.is_correct_number(_puzzle, r, c, _current_grid[index]):
				return false
	return true


func _celebrate_line_completion(line_type: String, line_index: int) -> void:
	"""US-D.2: Celebrate completing a row or column with cascading glow effect
	US-D.3: Also triggers gold conversion animation"""
	var dim: int = _puzzle.get_grid_dimension()
	var indices: Array[int] = []
	
	if line_type == "row":
		for col in range(dim):
			indices.append(line_index * dim + col)
	else:  # column
		for row in range(dim):
			indices.append(row * dim + line_index)
	
	# Staggered celebration for each cell in the line
	for i in range(indices.size()):
		var cell_index: int = indices[i]
		var delay: float = i * 0.05  # Stagger effect
		_celebrate_cell_delayed(cell_index, delay)
	
	# US-D.3: Award gold for completing a line (random range 254-646)
	var gold_amount: int = randi_range(254, 646)
	gold_earned.emit(gold_amount)


func _celebrate_box_completion(row: int, col: int) -> void:
	"""US-D.2: Celebrate completing a box with cascading glow effect
	US-D.3: Also triggers gold conversion animation"""
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	
	var box_start_row: int = (row / box_h) * box_h
	var box_start_col: int = (col / box_w) * box_w
	
	var delay_counter: int = 0
	for r in range(box_start_row, box_start_row + box_h):
		for c in range(box_start_col, box_start_col + box_w):
			var index: int = r * dim + c
			var delay: float = delay_counter * 0.04
			_celebrate_cell_delayed(index, delay)
			delay_counter += 1
	
	# US-D.3: Award gold for completing a box (random range 254-646)
	var gold_amount: int = randi_range(254, 646)
	gold_earned.emit(gold_amount)


func _celebrate_cell_delayed(index: int, delay: float) -> void:
	"""Celebrate a single cell with a delay (for cascading effects)
	GS-1: Uses glowing gem sprite and marks cell as permanently glowing"""
	if delay > 0:
		await get_tree().create_timer(delay).timeout
	
	var sprite: TextureRect = _cell_sprites[index]
	if not sprite:
		return
	
	var value: int = _current_grid[index]
	if value <= 0 or value > _gem_textures_glowing.size():
		return
	
	var color: Color = GEM_COLORS[value - 1] if value <= GEM_COLORS.size() else Color.WHITE
	
	# GS-1: Swap to glowing texture permanently
	var glowing_tex: Texture2D = _gem_textures_glowing[value - 1]
	if glowing_tex:
		sprite.texture = glowing_tex
	
	# Track this cell as completed (stays glowing)
	if index not in _completed_cells:
		_completed_cells.append(index)
	
	# Subtle pulse animation on top of glowing texture
	var tween := create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE.lightened(0.3), 0.15)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.2)
	
	# Spawn particle burst
	_spawn_gem_particles(index, color)



func _spawn_gem_particles(index: int, color: Color) -> void:
	"""US-D.4: Spawn colored particle burst from a cell for line/box completion"""
	var cell: Control = _cells[index]
	var center: Vector2 = cell.position + Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	
	# Create 8-10 small particles
	var particle_count: int = randi_range(8, 10)
	for i in range(particle_count):
		var particle := ColorRect.new()
		particle.size = Vector2(6, 6)
		particle.color = color.lightened(randf_range(0.2, 0.5))
		particle.position = center - Vector2(3, 3)
		particle.z_index = 100
		add_child(particle)
		
		# Random direction outward
		var angle: float = randf() * TAU
		var distance: float = randf_range(40, 80)
		var end_pos: Vector2 = center + Vector2(cos(angle), sin(angle)) * distance
		
		# Animate outward and fade
		var tween := create_tween()
		tween.set_parallel(true)
		tween.tween_property(particle, "position", end_pos, 0.5).set_ease(Tween.EASE_OUT)
		tween.tween_property(particle, "modulate:a", 0.0, 0.5).set_delay(0.15)
		tween.tween_property(particle, "scale", Vector2(0.3, 0.3), 0.5)
		tween.set_parallel(false)
		tween.tween_callback(particle.queue_free)



func _flash_cell_error(index: int) -> void:
	"""Flash cell red on error - bright flash, slow fade"""
	var cell: Control = _cells[index]
	var panel: Panel = cell.get_node("Background") as Panel
	
	var tween = create_tween()
	# Bright red flash
	tween.tween_property(panel, "modulate", Color(1.0, 0.2, 0.2, 1.0), 0.1)
	# Slow fade back to normal (1.5 seconds)
	tween.tween_property(panel, "modulate", Color.WHITE, 1.5).set_ease(Tween.EASE_OUT)



func _show_error_overlay(index: int) -> void:
	"""Show large RED X over the cell with black outline"""
	var cell = _cells[index]
	
	# Remove existing X if present
	var existing = cell.get_node_or_null("ErrorX")
	if existing:
		existing.queue_free()
	
	var x = Label.new()
	x.name = "ErrorX"
	x.text = "✖"
	x.set_anchors_preset(Control.PRESET_FULL_RECT)
	x.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	x.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	# Red with black outline
	x.add_theme_color_override("font_color", Color(1.0, 0.1, 0.1, 1.0))
	x.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1.0))
	x.add_theme_constant_override("outline_size", 4)
	x.add_theme_font_size_override("font_size", 52)
	x.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# Set pivot to center for proper scale animation
	x.pivot_offset = Vector2(CELL_SIZE / 2, CELL_SIZE / 2)
	cell.add_child(x)
	
	# Animation: scale up quickly, hold, then fade slowly
	var tween = create_tween()
	x.scale = Vector2(0.5, 0.5)
	tween.tween_property(x, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(x, "scale", Vector2(1.0, 1.0), 0.1)
	# Hold for a moment then fade slowly over 2 seconds
	tween.tween_interval(0.5)
	tween.tween_property(x, "modulate:a", 0.0, 2.0).set_ease(Tween.EASE_IN)
	tween.tween_callback(x.queue_free)



func _check_completion() -> void:
	if _validator.is_puzzle_complete(_puzzle, _current_grid):
		puzzle_completed.emit()
