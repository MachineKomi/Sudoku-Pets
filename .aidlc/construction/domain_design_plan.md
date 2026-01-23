# Domain Driven Design Plan

This plan outlines the steps to design Domain-Driven Design (DDD) domain models for each of the 4 Sudoku Pets units.

## Goal
Create comprehensive domain models using DDD tactical patterns (Aggregates, Entities, Value Objects, Domain Events, Repositories, Domain Services, Policies) for each unit.

---

## Steps

- [ ] **Step 1: Create Unit Directories**
    - Create `core_sudoku/` directory.
    - Create `meta_progression/` directory.
    - Create `pet_system/` directory.
    - Create `polish_wrapper/` directory.

- [ ] **Step 2: Design Core Sudoku Domain Model**
    - **Aggregates**:
        - `PuzzleBoard` (Root): Manages grid state, validation, cell selections.
    - **Entities**:
        - `Cell`: Individual grid position with its value and state.
    - **Value Objects**:
        - `CellPosition` (row, col), `CellValue` (1-9, or null), `GridSize` (2x2, 6x6, 9x9), `PencilNotes` (set of candidates).
    - **Domain Events**:
        - `NumberPlaced`, `MistakeMade`, `PuzzleSolved`, `HintRequested`.
    - **Domain Services**:
        - `SudokuValidator`: Checks row/column/box constraints.
        - `HintEngine`: Identifies logical next moves.
    - **Policies**:
        - `ErrorFeedbackPolicy`: When a mistake is made, explain *why*.
    - *Note: No repository needed—puzzles are loaded from level data, not persisted mid-solve.*

- [ ] **Step 3: Design Meta Progression Domain Model**
    - **Aggregates**:
        - `PlayerProgress` (Root): Tracks unlocked levels, stars, currencies.
        - `Level` (Root): Defines puzzle configuration and rewards.
    - **Entities**:
        - `LevelNode`: A point on the world map with status (locked/unlocked/completed).
    - **Value Objects**:
        - `StarRating` (0-3), `Currency` (Gold, XP, Gems), `BiomeType` (Jungle, Desert).
    - **Domain Events**:
        - `LevelCompleted`, `StarEarned`, `CurrencyEarned`, `LevelUnlocked`.
    - **Repositories**:
        - `PlayerProgressRepository`: Load/save player data (local file).
        - `LevelRepository`: Load level definitions.
    - **Domain Services**:
        - `RewardCalculator`: Determines XP/Gold based on performance.

- [ ] **Step 4: Design Pet System Domain Model**
    - **Aggregates**:
        - `PetCollection` (Root): Manages all owned pets.
        - `Pet` (Root): Individual pet with its level and evolution state.
    - **Value Objects**:
        - `PetSpecies` (Goblin, Owl, Cat), `PetRarity` (Common, Rare, Epic), `EvolutionStage` (Baby, Teen, Adult).
    - **Domain Events**:
        - `PetAcquired`, `PetLeveledUp`, `PetEvolved`, `GachaPulled`.
    - **Repositories**:
        - `PetCollectionRepository`: Load/save owned pets.
    - **Domain Services**:
        - `GachaMachine`: Handles random pet selection based on rarity tables.
        - `PetInteractionService`: Handles "feeding" and "playing".
    - **Policies**:
        - `EvolutionPolicy`: Defines XP thresholds for evolution.
        - `GachaRatePolicy`: Defines pull rates (no pay-to-win, uses earned currency only).

- [ ] **Step 5: Design Polish Wrapper Domain Model**
    - *This unit is primarily UI/UX and presentation logic, so it has minimal "domain" complexity.*
    - **Aggregates**:
        - `GameSettings` (Root): Manages toggleable modes (Zen, Breezy), audio settings.
    - **Value Objects**:
        - `DisplayMode` (Normal, Zen), `AudioSettings` (volume levels).
    - **Domain Events**:
        - `SettingsChanged`, `TutorialStepCompleted`.
    - **Repositories**:
        - `SettingsRepository`: Load/save user preferences.
    - **Domain Services**:
        - `CompanionDialogueService`: Selects and delivers Cat Girl dialogue based on game events.

- [ ] **Step 6: Create `domain_model.md` Files**
    - Write `core_sudoku/domain_model.md` with Mermaid diagrams.
    - Write `meta_progression/domain_model.md`.
    - Write `pet_system/domain_model.md`.
    - Write `polish_wrapper/domain_model.md`.

- [ ] **Step 7: Review & Finalize**
    - Verify loose coupling: Each unit should only depend on shared Value Objects (like `Currency`) via well-defined interfaces.
    - Identify integration points (e.g., `PuzzleSolved` event triggers `CurrencyEarned` in Meta Progression).

---

## Notes for Clarification
- **No Clarification Needed**: The DDD approach will map cleanly to the existing user stories. I will proceed with the outlined structure unless you have specific concerns about aggregate boundaries or event flow.
