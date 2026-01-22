## Tests for SudokuGenerator
extends GutTest

var _generator: SudokuGenerator


func before_each() -> void:
	_generator = SudokuGenerator.new()


func test_generates_4x4_puzzle() -> void:
	var puzzle := _generator.generate(PuzzleData.BoardSize.SIZE_4X4, PuzzleData.Difficulty.EASY)
	
	assert_eq(puzzle.solution.size(), 16, "4x4 should have 16 cells")
	assert_eq(puzzle.starting_grid.size(), 16, "Starting grid should have 16 cells")


func test_generates_valid_solution() -> void:
	var puzzle := _generator.generate(PuzzleData.BoardSize.SIZE_4X4, PuzzleData.Difficulty.EASY)
	var validator := SudokuValidator.new()
	
	# Check all numbers are 1-4
	for num in puzzle.solution:
		assert_true(num >= 1 and num <= 4, "All numbers should be 1-4")


func test_starting_grid_has_empty_cells() -> void:
	var puzzle := _generator.generate(PuzzleData.BoardSize.SIZE_4X4, PuzzleData.Difficulty.EASY)
	
	var empty_count := 0
	for num in puzzle.starting_grid:
		if num == 0:
			empty_count += 1
	
	assert_true(empty_count > 0, "Starting grid should have empty cells")


func test_generates_6x6_puzzle() -> void:
	var puzzle := _generator.generate(PuzzleData.BoardSize.SIZE_6X6, PuzzleData.Difficulty.MEDIUM)
	
	assert_eq(puzzle.solution.size(), 36, "6x6 should have 36 cells")
