## SudokuValidator - Validates moves and checks puzzle state
class_name SudokuValidator
extends RefCounted


## Check if placing a number at position is valid (doesn't conflict)
func is_valid_move(puzzle: PuzzleData, row: int, col: int, num: int, current_grid: Array[int]) -> bool:
	var size := puzzle.get_grid_dimension()
	var box_width := puzzle.get_box_width()
	var box_height := puzzle.get_box_height()
	
	# Check row
	for c in range(size):
		if c != col and current_grid[row * size + c] == num:
			return false
	
	# Check column
	for r in range(size):
		if r != row and current_grid[r * size + col] == num:
			return false
	
	# Check box
	var box_start_row := (row / box_height) * box_height
	var box_start_col := (col / box_width) * box_width
	
	for r in range(box_start_row, box_start_row + box_height):
		for c in range(box_start_col, box_start_col + box_width):
			if (r != row or c != col) and current_grid[r * size + c] == num:
				return false
	
	return true


## Check if the number matches the solution
func is_correct_number(puzzle: PuzzleData, row: int, col: int, num: int) -> bool:
	return puzzle.get_cell_value(row, col, true) == num


## Get all cells that conflict with placing num at (row, col)
func get_conflicting_cells(puzzle: PuzzleData, row: int, col: int, num: int, current_grid: Array[int]) -> Array[Vector2i]:
	var conflicts: Array[Vector2i] = []
	var size := puzzle.get_grid_dimension()
	var box_width := puzzle.get_box_width()
	var box_height := puzzle.get_box_height()
	
	# Check row
	for c in range(size):
		if c != col and current_grid[row * size + c] == num:
			conflicts.append(Vector2i(c, row))
	
	# Check column
	for r in range(size):
		if r != row and current_grid[r * size + col] == num:
			conflicts.append(Vector2i(col, r))
	
	# Check box
	var box_start_row := (row / box_height) * box_height
	var box_start_col := (col / box_width) * box_width
	
	for r in range(box_start_row, box_start_row + box_height):
		for c in range(box_start_col, box_start_col + box_width):
			if (r != row or c != col) and current_grid[r * size + c] == num:
				var pos := Vector2i(c, r)
				if pos not in conflicts:
					conflicts.append(pos)
	
	return conflicts


## Check if the puzzle is complete and correct
func is_puzzle_complete(puzzle: PuzzleData, current_grid: Array[int]) -> bool:
	var size := puzzle.get_grid_dimension()
	
	for i in range(size * size):
		if current_grid[i] == 0:
			return false
		if current_grid[i] != puzzle.solution[i]:
			return false
	
	return true


## Get explanation for why a move is wrong
func get_conflict_explanation(puzzle: PuzzleData, row: int, col: int, num: int, current_grid: Array[int]) -> String:
	var size := puzzle.get_grid_dimension()
	var box_width := puzzle.get_box_width()
	var box_height := puzzle.get_box_height()
	
	# Check row
	for c in range(size):
		if c != col and current_grid[row * size + c] == num:
			return "Oops! There's already a %d in this row!" % num
	
	# Check column
	for r in range(size):
		if r != row and current_grid[r * size + col] == num:
			return "Oops! There's already a %d in this column!" % num
	
	# Check box
	var box_start_row := (row / box_height) * box_height
	var box_start_col := (col / box_width) * box_width
	
	for r in range(box_start_row, box_start_row + box_height):
		for c in range(box_start_col, box_start_col + box_width):
			if (r != row or c != col) and current_grid[r * size + c] == num:
				return "Oops! There's already a %d in this box!" % num
	
	return ""
