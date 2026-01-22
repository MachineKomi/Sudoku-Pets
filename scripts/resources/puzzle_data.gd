## PuzzleData - Resource storing a Sudoku puzzle
class_name PuzzleData
extends Resource

enum BoardSize { SIZE_2X2 = 2, SIZE_4X4 = 4, SIZE_6X6 = 6, SIZE_9X9 = 9 }
enum Difficulty { TUTORIAL, EASY, MEDIUM, HARD, EXPERT }

@export var id: String = ""
@export var board_size: BoardSize = BoardSize.SIZE_4X4
@export var difficulty: Difficulty = Difficulty.EASY

## The complete solution grid (row-major order)
@export var solution: Array[int] = []

## The starting grid with 0 for empty cells
@export var starting_grid: Array[int] = []

## Metadata
@export var world_id: int = 1
@export var level_number: int = 1


func get_grid_dimension() -> int:
	return int(board_size)


func get_box_width() -> int:
	match board_size:
		BoardSize.SIZE_2X2: return 2
		BoardSize.SIZE_4X4: return 2
		BoardSize.SIZE_6X6: return 3
		BoardSize.SIZE_9X9: return 3
		_: return 3


func get_box_height() -> int:
	match board_size:
		BoardSize.SIZE_2X2: return 1
		BoardSize.SIZE_4X4: return 2
		BoardSize.SIZE_6X6: return 2
		BoardSize.SIZE_9X9: return 3
		_: return 3


func get_cell_value(row: int, col: int, use_solution: bool = false) -> int:
	var grid := solution if use_solution else starting_grid
	var dim := get_grid_dimension()
	var index := row * dim + col
	if index < 0 or index >= grid.size():
		return 0
	return grid[index]


func is_cell_given(row: int, col: int) -> bool:
	return get_cell_value(row, col, false) != 0
