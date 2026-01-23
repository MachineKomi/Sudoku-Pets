# Implementation Tasks Plan

This plan outlines the steps to implement the DDD domain models for Sudoku Pets in GDScript (Godot 4.5.1).

## Context
- **Engine**: Godot 4.5.1 (GDScript)
- **Existing Code**: `SudokuValidator`, `SudokuGenerator`, autoload managers, `PuzzleData` resource
- **Test Framework**: GUT (Godot Unit Test)
- **Conventions**: See `AGENTS.md` for GDScript standards

## Goal
Create in-memory implementations of the DDD domain models, organized into the existing `scripts/` structure, with simple demo scripts that can be run locally.

---

## Steps

- [ ] **Step 1: Create Domain Model Documentation**
    - Write `core_sudoku/domain_model.md` documenting Aggregates/Entities/Events.
    - Write `meta_progression/domain_model.md`.
    - Write `pet_system/domain_model.md`.
    - Write `polish_wrapper/domain_model.md`.

- [ ] **Step 2: Implement Shared Infrastructure**
    - Create `scripts/domain/event_bus.gd` - Simple in-memory event dispatcher.
    - Create `scripts/domain/base_event.gd` - Base class for domain events.
    - *Note: This provides the "event-driven" backbone for cross-unit communication.*

- [ ] **Step 3: Implement Core Sudoku Domain (scripts/puzzle/)**
    - **Value Objects**:
        - `scripts/puzzle/value_objects/cell_position.gd`
        - `scripts/puzzle/value_objects/cell_value.gd`
        - `scripts/puzzle/value_objects/pencil_notes.gd`
    - **Domain Events**:
        - `scripts/puzzle/events/number_placed_event.gd`
        - `scripts/puzzle/events/mistake_made_event.gd`
        - `scripts/puzzle/events/puzzle_solved_event.gd`
    - **Aggregate**:
        - Refactor `puzzle_screen.gd` to emit domain events.
    - *Existing `SudokuValidator` and `SudokuGenerator` serve as Domain Services.*

- [ ] **Step 4: Implement Meta Progression Domain (scripts/progression/)**
    - **Value Objects**:
        - `scripts/progression/value_objects/currency.gd` (Gold, XP, Gems)
        - `scripts/progression/value_objects/star_rating.gd`
    - **Aggregate**:
        - `scripts/progression/player_progress.gd` (tracks levels, currencies)
    - **Domain Events**:
        - `scripts/progression/events/level_completed_event.gd`
        - `scripts/progression/events/currency_earned_event.gd`
    - **Repository**:
        - Refactor `SaveManager` to act as `PlayerProgressRepository`.
    - **Domain Service**:
        - `scripts/progression/reward_calculator.gd`

- [ ] **Step 5: Implement Pet System Domain (scripts/pets/)**
    - **Value Objects**:
        - `scripts/pets/value_objects/pet_species.gd`
        - `scripts/pets/value_objects/pet_rarity.gd`
        - `scripts/pets/value_objects/evolution_stage.gd`
    - **Aggregate**:
        - `scripts/pets/pet.gd` (individual pet with level/XP)
        - `scripts/pets/pet_collection.gd` (all owned pets)
    - **Domain Events**:
        - `scripts/pets/events/pet_acquired_event.gd`
        - `scripts/pets/events/pet_leveled_up_event.gd`
    - **Domain Services**:
        - `scripts/pets/gacha_machine.gd`
        - `scripts/pets/evolution_policy.gd`
    - **Repository**:
        - Refactor `PetManager` to persist collection.

- [ ] **Step 6: Implement Polish Wrapper Domain (scripts/settings/)**
    - **Aggregate**:
        - `scripts/settings/game_settings.gd`
    - **Value Objects**:
        - `scripts/settings/value_objects/display_mode.gd` (Normal, Zen)
    - **Domain Service**:
        - `scripts/settings/companion_dialogue_service.gd`

- [ ] **Step 7: Create Demo Script**
    - Create `scripts/demo/domain_demo.gd` that:
        1. Initializes a `PuzzleBoard` with a test puzzle.
        2. Simulates placing correct/incorrect numbers.
        3. Listens for `PuzzleSolved` event and triggers `CurrencyEarned`.
        4. Performs a gacha pull and shows acquired pet.
    - *This can be run from Godot editor as a scene with a script attached.*

- [ ] **Step 8: Create Unit Tests**
    - `test/unit/test_event_bus.gd` - Test event subscription/emission.
    - `test/unit/test_reward_calculator.gd` - Test XP/Gold calculation.
    - `test/unit/test_gacha_machine.gd` - Test rarity distribution.

---

## Verification Plan

### Automated Tests (GUT)
Run via Godot command line:
```powershell
& "C:\Godot_451_20251015\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --path "sudoku-pets" -s res://addons/gut/gut_cmdln.gd -gexit
```

### Manual Verification
1. Open Godot editor and load `sudoku-pets` project.
2. Open `scripts/demo/domain_demo.tscn` and run the scene (F6).
3. Observe console output showing domain events being emitted and handled.
4. Verify no runtime errors.

---

## Notes
- **No Clarification Needed**: I will follow the existing GDScript conventions from `AGENTS.md`.
- All implementations use in-memory storage as specified.
