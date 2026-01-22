## SudokuBoard - Manages the Sudoku grid and gameplay
## 
## IMPORTANT FOR AI AGENTS:
## - All Array/Dictionary constants MUST have explicit types (Godot 4.5.1 strict mode)
## - Use `const NAME: Type = value` not `const NAME := value` for complex types
## - Reference: AGENTS.md "GDScript Standards" section
##
extends Control

signal cell_filled_correct
signal cell_filled_wrong
signal puzzle_completed

# =============================================================================
# CONSTANTS - UI-SPEC 2.2: Color-coded tiles
# =============================================================================

## Cell size in pixels - used for grid layout calculations
## DO NOT REMOVE - referenced by _build_grid() and _create_cell()
const CELL_SIZE: int = 80

# Gem colors matching UI-SPEC section 2.2 - these are vibrant, candy-like colors
# Will be replaced with actual gem sprites later (see HUMAN_TODO/2026-01-22_gem-sprites.md)
const GEM_COLORS: Array[Color] = [
	Color("#E63946"), # 1 - Ruby Red
	Color("#F4A261"), # 2 - Amber Orange  
	Color("#F9C74F"), # 3 - Topaz Yellow
	Color("#2A9D8F"), # 4 - Emerald Green
	Color("#00B4D8"), # 5 - Aquamarine Cyan
	Color("#4361EE"), # 6 - Sapphire Blue
	Color("#7209B7"), # 7 - Amethyst Purple
	Color("#F72585"), # 8 - Rose Pink
	Color("#E0E0E0"), # 9 - Diamond White/Silver
]

# Using numbers as text for now - will be replaced with gem sprites
const GEM_SHAPES: Array[String] = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

# Selection highlight color - bright and obvious
const SELECTION_COLOR: Color = Color("#FFD700")  # Gold
const SELECTION_GLOW_COLOR: Color = Color("#FFF8DC")  # Cornsilk (light glow)

# =============================================================================
# NODE REFERENCES
# =============================================================================

@onready var grid_container: GridContainer = $GridContainer

# =============================================================================
# STATE VARIABLES
# =============================================================================

var _puzzle: PuzzleData
var _current_grid: Array[int] = []
var _notes_grid: Array = []  # Array of Arrays - notes for each cell
var _cells: Array[Button] = []
var _selected_cell: int = -1
var _selected_number: int = 0
var _move_history: Array[Dictionary] = []
var _generator := SudokuGenerator.new()
var _validator := SudokuValidator.new()

# =============================================================================
# LIFECYCLE
# =============================================================================

func _ready() -> void:
	_start_new_puzzle(PuzzleData.BoardSize.SIZE_4X4, PuzzleData.Difficulty.EASY)


func _draw() -> void:
	if not _puzzle:
		return
	_draw_grid_lines()
	_draw_selection_highlight()

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
		return  # Can't add notes to filled cells
	
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


func show_hint() -> void:
	"""Place the correct number in the first empty cell"""
	var dim: int = _puzzle.get_grid_dimension()
	for i in range(dim * dim):
		if _current_grid[i] == 0:
			var row: int = i / dim
			var col: int = i % dim
			var correct: int = _puzzle.get_cell_value(row, col, true)
			_place_number(i, correct)
			return

# =============================================================================
# PUZZLE MANAGEMENT
# =============================================================================

func _start_new_puzzle(size: PuzzleData.BoardSize, difficulty: PuzzleData.Difficulty) -> void:
	_puzzle = _generator.generate(size, difficulty)
	_current_grid = _puzzle.starting_grid.duplicate()
	
	# Initialize notes grid - each cell gets an empty array
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
	
	var dim: int = _puzzle.get_grid_dimension()
	grid_container.columns = dim
	
	# Calculate total size with gaps
	var gap: int = 2
	var total_size: int = dim * CELL_SIZE + (dim - 1) * gap
	custom_minimum_size = Vector2(total_size, total_size)
	
	# Create cells
	for i in range(dim * dim):
		var cell: Button = _create_cell(i)
		grid_container.add_child(cell)
		_cells.append(cell)
	
	_update_all_cells()
	queue_redraw()

# =============================================================================
# CELL CREATION & RENDERING
# =============================================================================

func _create_cell(index: int) -> Button:
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(CELL_SIZE, CELL_SIZE)
	btn.focus_mode = Control.FOCUS_NONE
	btn.pressed.connect(_on_cell_pressed.bind(index))
	btn.clip_text = false
	return btn


func _update_all_cells() -> void:
	for i in range(_cells.size()):
		_update_cell(i)


func _update_cell(index: int) -> void:
	var cell: Button = _cells[index]
	var value: int = _current_grid[index]
	var is_given: bool = _puzzle.starting_grid[index] != 0
	var is_selected: bool = index == _selected_cell
	var notes: Array = _notes_grid[index]
	
	# Create stylebox for the cell
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 8
	style.corner_radius_top_right = 8
	style.corner_radius_bottom_right = 8
	style.corner_radius_bottom_left = 8
	
	# Selection highlighting - UI-SPEC 2.3: Cell States
	if is_selected:
		style.border_width_left = 4
		style.border_width_top = 4
		style.border_width_right = 4
		style.border_width_bottom = 4
		style.border_color = SELECTION_COLOR
		# Add glow effect via expand margin
		style.expand_margin_left = 2
		style.expand_margin_top = 2
		style.expand_margin_right = 2
		style.expand_margin_bottom = 2
	else:
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.3, 0.3, 0.35, 0.5)
	
	if value == 0:
		# Empty cell - show notes if any
		style.bg_color = Color(0.2, 0.2, 0.25, 0.8)
		
		if not notes.is_empty():
			# Render notes in a grid layout
			cell.text = _format_notes_grid(notes)
			cell.add_theme_font_size_override("font_size", 12)
			cell.add_theme_color_override("font_color", Color(0.7, 0.7, 0.75, 0.8))
		else:
			cell.text = ""
	else:
		# Filled cell - show gem
		var color: Color = GEM_COLORS[value - 1]
		
		if is_given:
			# Given numbers are slightly darker/more solid
			style.bg_color = color.darkened(0.1)
			cell.add_theme_color_override("font_color", Color.WHITE)
		else:
			# Player-placed numbers
			style.bg_color = color
			cell.add_theme_color_override("font_color", Color.WHITE)
		
		cell.text = GEM_SHAPES[value - 1]
		cell.add_theme_font_size_override("font_size", 36)
	
	# Apply styles
	cell.add_theme_stylebox_override("normal", style)
	cell.add_theme_stylebox_override("hover", style)
	cell.add_theme_stylebox_override("pressed", style)
	cell.add_theme_stylebox_override("focus", style)
	
	queue_redraw()


func _format_notes_grid(notes: Array) -> String:
	"""Format notes as a grid string for display
	For 4x4 board: 2x2 grid of notes (1-4)
	For 9x9 board: 3x3 grid of notes (1-9)
	"""
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
					result += "·"  # Dot placeholder for empty slots
			num += 1
			if col < grid_size - 1:
				result += " "
		if row < grid_size - 1:
			result += "\n"
	
	return result

# =============================================================================
# DRAWING - Grid lines and selection
# =============================================================================

func _draw_grid_lines() -> void:
	"""Draw thick lines between subgrids (boxes)"""
	var dim: int = _puzzle.get_grid_dimension()
	var box_w: int = _puzzle.get_box_width()
	var box_h: int = _puzzle.get_box_height()
	
	var board_size: Vector2 = size
	var cell_w: float = board_size.x / dim
	var cell_h: float = board_size.y / dim
	
	var line_color: Color = Color(0.15, 0.15, 0.2)
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
	"""Draw extra glow around selected cell"""
	if _selected_cell < 0:
		return
	
	var dim: int = _puzzle.get_grid_dimension()
	var row: int = _selected_cell / dim
	var col: int = _selected_cell % dim
	
	var cell_w: float = size.x / dim
	var cell_h: float = size.y / dim
	
	var rect := Rect2(
		col * cell_w - 2,
		row * cell_h - 2,
		cell_w + 4,
		cell_h + 4
	)
	
	# Draw glow outline
	draw_rect(rect, SELECTION_COLOR, false, 3.0)

# =============================================================================
# INPUT HANDLING
# =============================================================================

func _on_cell_pressed(index: int) -> void:
	# Select the cell
	var old_selected: int = _selected_cell
	_selected_cell = index
	
	# Update old and new selection visuals
	if old_selected >= 0 and old_selected < _cells.size():
		_update_cell(old_selected)
	_update_cell(index)
	
	# If it's a given cell, just select it (can't modify)
	if _puzzle.starting_grid[index] != 0:
		return
	
	# If a number is selected, place it
	if _selected_number > 0:
		_place_number(index, _selected_number)


func _place_number(index: int, num: int) -> void:
	var old_value: int = _current_grid[index]
	
	# Record for undo
	_move_history.append({
		"index": index,
		"old_value": old_value,
		"new_value": num
	})
	
	# Clear notes when placing a number
	_notes_grid[index] = []
	
	# Place the number
	_current_grid[index] = num
	_update_cell(index)
	
	# Validate
	var row: int = index / _puzzle.get_grid_dimension()
	var col: int = index % _puzzle.get_grid_dimension()
	
	if _validator.is_correct_number(_puzzle, row, col, num):
		cell_filled_correct.emit()
		_check_completion()
	else:
		cell_filled_wrong.emit()
		_flash_cell_error(index)


func _flash_cell_error(index: int) -> void:
	"""Flash red on wrong answer"""
	var cell: Button = _cells[index]
	
	# Create error style
	var error_style := StyleBoxFlat.new()
	error_style.bg_color = Color("#FF4444")
	error_style.corner_radius_top_left = 8
	error_style.corner_radius_top_right = 8
	error_style.corner_radius_bottom_right = 8
	error_style.corner_radius_bottom_left = 8
	error_style.border_width_left = 3
	error_style.border_width_top = 3
	error_style.border_width_right = 3
	error_style.border_width_bottom = 3
	error_style.border_color = Color("#FF0000")
	
	cell.add_theme_stylebox_override("normal", error_style)
	cell.add_theme_color_override("font_color", Color.WHITE)
	
	await get_tree().create_timer(0.4).timeout
	_update_cell(index)


func _check_completion() -> void:
	if _validator.is_puzzle_complete(_puzzle, _current_grid):
		puzzle_completed.emit()
