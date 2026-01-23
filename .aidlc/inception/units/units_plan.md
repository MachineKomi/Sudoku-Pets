# Units breakdown Plan

This plan outlines the strategy for grouping the "Sudoku Pets" user stories into independent, cohesive implementation units.

## Goal
To modularize the development process by creating distinct units that can be implemented and tested in isolation, minimizing dependencies.

## Steps

- [ ] **Step 1: Analyze Dependencies**
    - specific stories will be mapped to core systems to identify tight coupling (e.g., Gacha depends on Gold, Gold depends on Sudoku).

- [ ] **Step 2: Define Units**
    - **Unit 1: The Core Engine (Sudoku)**
        - *Focus*: Grid logic, Input, Rules, Validation, Basic UI.
        - *Stories*: 1.1, 1.2, 1.3, 1.5, 2.1, 2.2.
    - **Unit 2: The Progression Loop (Meta)**
        - *Focus*: World Map, Level Data, Star Ratings, Currency Logic (Backend of XP/Gold).
        - *Stories*: 3.1, 3.2, 3.3, 3.4.
    - **Unit 3: The Pet System (Gacha & Rewards)**
        - *Focus*: Gacha Machine UI/Logic, Pet Collection Data, Pet "Evolution" visuals.
        - *Stories*: 4.1, 4.2, 4.3, 4.4.
    - **Unit 4: The Experience Wrapper (Polish)**
        - *Focus*: Main Menu, Settings (Zen Mode toggles), Tutorials, Audio, "Juicy" Feedback (Confetti).
        - *Stories*: 1.4, 2.3, 2.4, 5.1, 5.2, 5.3, 6.1, 6.3.

- [ ] **Step 3: Create Unit Documents**
    - Create `core_sudoku.md` (Unit 1).
    - Create `meta_progression.md` (Unit 2).
    - Create `pet_system.md` (Unit 3).
    - Create `polish_wrapper.md` (Unit 4).
    - *Each file will contain:*
        - Unit Goal.
        - List of User Stories.
        - Specific Acceptance Criteria for the Unit.
        - Interface requirements (what it needs from other units).

- [ ] **Step 4: Review**
    - Verify that units are indeed "loosely coupled" (e.g., The Sudoku engine shouldn't crash if the Pet system doesn't exist yet; it just won't show a pet).
