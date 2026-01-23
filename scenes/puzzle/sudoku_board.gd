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

# =============================================================================
# CONSTANTS
# =============================================================================

## Cell size in pixels - DO NOT REMOVE - used by _build_grid() and _create_cell()
const CELL_SIZE: int = 80

## Path to gem sprites - files must be named gem_1.png through gem_9.png
const GEM_SPRITE_PATH: String = "res://assets/sprites/gems/gem_%d.png"

## Selection highlight color - bright gold
const SELECTION_COLOR: Color = Color("#FFD700")

## Fallback colors if sprites fail to load
const GEM_COLORS: Array[Color] = [
	Color("#E63946"), Color("#F4A261"), Color("#F9C74F"),
	Color("#2A9D8F"), Color("#00B4D8"), Color("#4361EE"),
	Color("#7209B7"), Color("#F72585"), Color("#E0E0E0"),
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
var _cell_notes: Array[Label] = []  # Notes labels
var _selected_cell: int = -1
var _selected_number: int = 0
var _move_history: Array[Dictionary] = []
var _generator := SudokuGenerator.new()
var _validator := SudokuValidator.new()

## Preloaded gem textures
var _gem_textures: Array[Texture2D] = []

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_preload_gem_textures()
	_start_new_puzzle(PuzzleData.BoardSize.SIZE_4X4, PuzzleData.Difficulty.EASY)


func _draw() -> void:
	if not _puzzle:
		return
	_draw_grid_lines()
	_draw_selection_highlight()

# =============================================================================
# TEXTURE LOADING
# =============================================================================

func _preload_gem_textures() -> void:
	"""Preload all gem textures at startup"""
	_gem_textures.clear()
	for i in range(1, 10):
		var path: String = GEM_SPRITE_PATH % i
		var texture: Texture2D = load(path) as Texture2D
		if texture:
			_gem_textures.append(texture)
			print("Loaded gem texture: ", path)
		else:
			push_warning("Failed to load gem texture: " + path)
			_gem_textures.append(null)

# =============================================================================
# PUBLIC API
# =============================================================================

func get_board_size() -> int:
	return _puzzle.get_grid_dimension() if _puzzle else 4


func set_selected_number(num: int) -> void:
	_selected_number = num


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
	"""Find a cell with only one possible candidate and highlight it with explanation (Story 2.2)"""
	var dim: int = _puzzle.get_grid_dimension()
	
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
	
	# Gem sprite (centered with padding)
	var sprite := TextureRect.new()
	sprite.name = "GemSprite"
	# Use anchors for proper sizing within cell
	sprite.anchor_left = 0.0
	sprite.anchor_top = 0.0
	sprite.anchor_right = 1.0
	sprite.anchor_bottom = 1.0
	# Padding from edges (8px on each side)
	sprite.offset_left = 8
	sprite.offset_top = 8
	sprite.offset_right = -8
	sprite.offset_bottom = -8
	# Stretch mode: keep aspect ratio, center in available space
	sprite.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	sprite.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	container.add_child(sprite)
	_cell_sprites.append(sprite)
	
	# Notes label (for pencil marks)
	var notes_label := Label.new()
	notes_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	notes_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	notes_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	notes_label.name = "NotesLabel"
	notes_label.add_theme_font_size_override("font_size", 11)
	notes_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.85, 0.9))
	container.add_child(notes_label)
	_cell_notes.append(notes_label)
	
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
	var cell: Control = _cells[index]
	var panel: Panel = cell.get_node("Background") as Panel
	var sprite: TextureRect = _cell_sprites[index]
	var notes_label: Label = _cell_notes[index]
	
	var value: int = _current_grid[index]
	var is_given: bool = _puzzle.starting_grid[index] != 0
	var is_selected: bool = index == _selected_cell
	var notes: Array = _notes_grid[index]
	
	# Create panel style
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 6
	style.corner_radius_top_right = 6
	style.corner_radius_bottom_right = 6
	style.corner_radius_bottom_left = 6
	
	# Selection highlighting
	if is_selected:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = SELECTION_COLOR
	else:
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.3, 0.3, 0.35, 0.3)
	
	if value == 0:
		# Empty cell
		style.bg_color = Color(0.15, 0.15, 0.2, 0.9)
		sprite.texture = null
		sprite.visible = false
		
		# Show notes if any
		if not notes.is_empty():
			notes_label.text = _format_notes_grid(notes)
			notes_label.visible = true
		else:
			notes_label.text = ""
			notes_label.visible = false
	else:
		# Filled cell - show gem sprite
		style.bg_color = Color(0.1, 0.1, 0.12, 0.95)
		notes_label.visible = false
		notes_label.text = ""
		
		# Set gem texture (value is 1-9, array is 0-indexed)
		var tex_index: int = value - 1
		if tex_index >= 0 and tex_index < _gem_textures.size():
			var tex: Texture2D = _gem_textures[tex_index]
			if tex:
				sprite.texture = tex
				sprite.visible = true
				sprite.show()  # Ensure visibility
				# Slightly dim given numbers vs player-placed
				if is_given:
					sprite.modulate = Color(0.9, 0.9, 0.9, 1.0)
				else:
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
	"""Format notes as a grid - 2x2 for 4x4 board, 3x3 for 9x9"""
	var dim: int = _puzzle.get_grid_dimension()
	var grid_size: int = 2 if dim <= 4 else 3
	var max_num: int = dim
	
	var result: String = ""
	var num: int = 1
	
	for row in range(grid_size):
		for col in range(grid_size):
			if num <= max_num:
				if num in notes:
					result += str(num)
				else:
					result += "·"
			num += 1
			if col < grid_size - 1:
				result += " "
		if row < grid_size - 1:
			result += "\n"
	
	return result

# =============================================================================
# DRAWING
# =============================================================================

func _draw_grid_lines() -> void:
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	
	var board_size: Vector2 = size
	var cell_w: float = board_size.x / dim
	var cell_h: float = board_size.y / dim
	
	var line_color: Color = Color(0.1, 0.1, 0.15)
	var line_width: float = 4.0
	
	# Vertical lines between boxes
	for i in range(1, dim):
		if i % box_w == 0:
			var x: float = i * cell_w
			draw_line(Vector2(x, 0), Vector2(x, board_size.y), line_color, line_width)
	
	# Horizontal lines between boxes
	for i in range(1, dim):
		if i % box_h == 0:
			var y: float = i * cell_h
			draw_line(Vector2(0, y), Vector2(board_size.x, y), line_color, line_width)
	
	# Outer border
	draw_rect(Rect2(Vector2.ZERO, board_size), line_color, false, line_width + 2)


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
	var old_selected: int = _selected_cell
	_selected_cell = index
	
	# Update visuals
	if old_selected >= 0 and old_selected < _cells.size():
		_update_cell(old_selected)
	_update_cell(index)
	
	# Can't modify given cells
	if _puzzle.starting_grid[index] != 0:
		return
	
	# Place number if one is selected
	if _selected_number > 0:
		_place_number(index, _selected_number)


func _place_number(index: int, num: int) -> void:
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
	
	# Validate
	var row: int = index / _puzzle.get_grid_dimension()
	var col: int = index % _puzzle.get_grid_dimension()
	
	if _validator.is_correct_number(_puzzle, row, col, num):
		cell_filled_correct.emit()
		_check_completion()
	else:
		# Get kid-friendly explanation of why this is wrong (Story 2.1: Educated Error)
		var explanation: String = _validator.get_conflict_explanation(_puzzle, row, col, num, _current_grid)
		if explanation.is_empty():
			explanation = "That's not quite right. Try again!"
		cell_filled_wrong.emit(explanation)
		_flash_cell_error(index)


func _flash_cell_error(index: int) -> void:
	var cell: Control = _cells[index]
	var panel: Panel = cell.get_node("Background") as Panel
	
	var error_style := StyleBoxFlat.new()
	error_style.bg_color = Color("#FF3333")
	error_style.corner_radius_top_left = 6
	error_style.corner_radius_top_right = 6
	error_style.corner_radius_bottom_right = 6
	error_style.corner_radius_bottom_left = 6
	error_style.border_width_left = 3
	error_style.border_width_top = 3
	error_style.border_width_right = 3
	error_style.border_width_bottom = 3
	error_style.border_color = Color("#FF0000")
	
	panel.add_theme_stylebox_override("panel", error_style)
	
	await get_tree().create_timer(0.4).timeout
	_update_cell(index)


func _check_completion() -> void:
	if _validator.is_puzzle_complete(_puzzle, _current_grid):
		puzzle_completed.emit()
