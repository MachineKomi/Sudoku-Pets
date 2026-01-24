## SudokuGenerator - Creates valid Sudoku puzzles
class_name SudokuGenerator
extends RefCounted

var _size: int
var _box_width: int
var _box_height: int
var _grid: Array[int]


func generate(board_size: PuzzleData.BoardSize, difficulty: PuzzleData.Difficulty) -> PuzzleData:
	_size = int(board_size)
	_set_box_dimensions(board_size)
	
	# Generate a complete valid solution
	_grid = []
	_grid.resize(_size * _size)
	_grid.fill(0)
	
	_fill_grid()
	
	var puzzle := PuzzleData.new()
	puzzle.board_size = board_size
	puzzle.difficulty = difficulty
	puzzle.solution = _grid.duplicate()
	
	# Remove numbers based on difficulty
	puzzle.starting_grid = _create_starting_grid(difficulty)
	
	return puzzle


func _set_box_dimensions(board_size: PuzzleData.BoardSize) -> void:
	match board_size:
		PuzzleData.BoardSize.SIZE_2X2:
			_box_width = 2
			_box_height = 1
		PuzzleData.BoardSize.SIZE_4X4:
			_box_width = 2
			_box_height = 2
		PuzzleData.BoardSize.SIZE_6X6:
			_box_width = 3
			_box_height = 2
		PuzzleData.BoardSize.SIZE_9X9:
			_box_width = 3
			_box_height = 3
		PuzzleData.BoardSize.SIZE_10X10:  # US-F.1: 10x10 with 5x2 regions
			_box_width = 5
			_box_height = 2


func _fill_grid() -> bool:
	var empty_cell := _find_empty_cell()
	if empty_cell.x == -1:
		return true  # Grid is complete
	
	var row := int(empty_cell.y)
	var col := int(empty_cell.x)
	
	var numbers := _get_shuffled_numbers()
	
	for num in numbers:
		if _is_valid_placement(row, col, num):
			_set_cell(row, col, num)
			if _fill_grid():
				return true
			_set_cell(row, col, 0)
	
	return false


func _find_empty_cell() -> Vector2i:
	for row in range(_size):
		for col in range(_size):
			if _get_cell(row, col) == 0:
				return Vector2i(col, row)
	return Vector2i(-1, -1)


func _get_shuffled_numbers() -> Array[int]:
	var numbers: Array[int] = []
	for i in range(1, _size + 1):
		numbers.append(i)
	numbers.shuffle()
	return numbers


func _is_valid_placement(row: int, col: int, num: int) -> bool:
	# Check row
	for c in range(_size):
		if _get_cell(row, c) == num:
			return false
	
	# Check column
	for r in range(_size):
		if _get_cell(r, col) == num:
			return false
	
	# Check box
	var box_start_row := (row / _box_height) * _box_height
	var box_start_col := (col / _box_width) * _box_width
	
	for r in range(box_start_row, box_start_row + _box_height):
		for c in range(box_start_col, box_start_col + _box_width):
			if _get_cell(r, c) == num:
				return false
	
	return true


func _get_cell(row: int, col: int) -> int:
	return _grid[row * _size + col]


func _set_cell(row: int, col: int, value: int) -> void:
	_grid[row * _size + col] = value


func _create_starting_grid(difficulty: PuzzleData.Difficulty) -> Array[int]:
	var starting := _grid.duplicate()
	var cells_to_remove := _get_cells_to_remove(difficulty)
	
	var positions: Array[int] = []
	for i in range(_size * _size):
		positions.append(i)
	positions.shuffle()
	
	var removed := 0
	for pos in positions:
		if removed >= cells_to_remove:
			break
		starting[pos] = 0
		removed += 1
	
	return starting


func _get_cells_to_remove(difficulty: PuzzleData.Difficulty) -> int:
	var total := _size * _size
	match difficulty:
		PuzzleData.Difficulty.TUTORIAL:
			return int(total * 0.2)  # Remove 20%
		PuzzleData.Difficulty.EASY:
			return int(total * 0.4)  # Remove 40%
		PuzzleData.Difficulty.MEDIUM:
			return int(total * 0.5)  # Remove 50%
		PuzzleData.Difficulty.HARD:
			return int(total * 0.6)  # Remove 60%
		PuzzleData.Difficulty.EXPERT:
			return int(total * 0.7)  # Remove 70%
		_:
			return int(total * 0.4)
