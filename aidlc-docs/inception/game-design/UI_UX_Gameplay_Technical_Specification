# Technical Spec: Sudoku UI/UX & Gameplay

## 1. Scope & Core Loop

**Goal:** Replicate the "World Map" progression shell and the "In-Level" Sudoku gameplay exactly as depicted in the reference screenshots.

* **State A (Active):** In-progress board, timer running, inputs active, superscripts counting down.
* **State B (Win):** Board filled, confetti overlay, timer paused/stopped, keypad input disabled/dimmed.

## 2. Global Visual Style

* **Theme:** "Casual Anime Puzzle." Bright, high-saturation colors.
* **UI Material:** Stylized wooden panels for header/footer backgrounds.
* **Play Field:** Warm beige/parchment background (`#F0EAD6` approx) to contrast with colorful tiles.
* **Feedback:**
* **Selection:** Thick white border around the active cell.
* **Completion:** Full-screen confetti particle system overlay.


## 3. Navigation & Menus

### 3.1 World Map (Main Menu)

* **Layout:** Vertical scrollable path.
* **Nodes:** Pill-shaped buttons labeled with Level Numbers (1, 2, 3...).
* **Ratings:** 0-3 Stars displayed above each node.
* **Environment:** Background biome changes (Jungle -> Desert) as player scrolls.
* **HUD:**
* **Top:** Coin & Gem counters with "+" buttons.
* **Bottom:** Large "Play Level [X]" CTA button; Settings Cog (Left).


## 4. In-Game HUD (Top Area)

Layout must match `Screenshot_20260122_074846_Sudoku Quest.jpg` exactly.

### 4.1 Power-Up Row (Top-most)

* **Background:** Darker wood grain.
* **Elements:** 4 Circular Slots.
* **State:** Displayed as **Locked** (Brown Padlock Icon) for the initial build.

### 4.2 Status Bar (Below Power-ups)

* **Background:** Lighter beige panel.
* **Left Cluster:**
* **Gems:** Pink Diamond Icon + Count (e.g., 13).
* **Coins:** Gold Coin Icon + Count (e.g., 16000).
* **Store:** Green Circular "+" Button.


* **Center:**
* **Palette Button:** Circular button with art palette icon (Theme toggle).


* **Right Cluster:**
* **Pause:** Blue Circle Button with "II".
* **Timer:** Analog clock icon + Digital text (`MM:SS`).
* **Lives:** 3 Red Heart icons (decrement on error).


## 5. Sudoku Grid System

### 5.1 Grid Rendering

* **Structure:** 9x9 Grid.
* **Lines:** Thin brown lines for cells; Thick brown lines for 3x3 sub-grids.
* **Cell States:**
1. **Locked (Given):** Bold font, background color applied. **User Constraint:** Cannot be selected/edited.
2. **Empty:** Beige background. Selectable.
3. **User Filled:** Same font/color style as Locked.
4. **Notes (Pencil):** Small black text, beige background.


### 5.2 Color Palette (Strict Mapping)

Every digit 1-9 has a specific background color used for both the **Board Tile** and the **Input Button**.

* **1:** Rust/Brown (`#D98E65`)
* **2:** Gold/Yellow (`#E6C55C`)
* **3:** Blue (`#6CA8F0`)
* **4:** Light Green (`#94D664`)
* **5:** Teal/Green (`#6CC5B3`)
* **6:** Cyan (`#74D3E3`)
* **7:** Purple (`#AC80D6`)
* **8:** Pink (`#E08ABF`)
* **9:** Lime Green (`#74D674`)

### 5.3 Pencil Note Logic (Visual)

Notes are **not** random; they map to a 3x3 micro-grid within the cell.

* Position 1: Top-Left
* Position 2: Top-Center
* Position 3: Top-Right
* ...
* Position 9: Bottom-Right

*Example from Screenshot:* A cell with notes "2, 5, 8" displays 2 in top-center, 5 in dead-center, 8 in bottom-center.

## 6. Input Control (Footer)

### 6.1 Number Pad

* **Layout:** Two rows.
* Row 1: 1, 2, 3, 4, 5
* Row 2: 6, 7, 8, 9, [Tools]


* **Superscript Logic:**
* Display a small number (superscript) on top-right of the button.
* **Formula:** `Remaining = 9 - (Count of Digit on Board)`.
* *Note:* Count includes both "Given" and "User Filled" instances.


* **Completion State:** When `Remaining == 0`, the superscript shows "0" and button may visually dim (but remains pressable if needed for notes, or disabled based on preference).

### 6.2 Tools

* **Pencil Toggle:** Button with Pencil Icon.
* *State:* Toggles `InputMode` between `Final` and `Draft`.
* *Visual:* Button should show "Pressed/Active" state when Draft is ON.


* **Undo:** Button with Back-Arrow icon.
* *Action:* Reverts last board state change.


## 7. Gameplay Logic (The "Brain")

1. **Selection:** User taps an **Empty** or **User-Filled** cell -> Cell gets White Border.
* *Constraint:* Tapping a **Locked** cell does nothing (or plays error sound).


2. **Input (Final Mode):**
* User taps Number `X`.
* Set selected cell value to `X`.
* **Validation:**
* If `X` is correct: Play success sound, Update Superscript.
* If `X` is wrong: Play error sound, Decrement Heart count, (Optional: Highlight red momentarily).


3. **Input (Draft Mode):**
* User taps Number `X`.
* Toggle `X` in the cell's note set.
* Update visual 3x3 micro-grid.
* *No validation or penalty for notes.*


4. **Win Condition:**
* IF (Board is full) AND (Hearts > 0) AND (No Errors):
* Trigger Confetti.
* Show "Level Complete" modal (Stars, Score, Next Level button).


## 8. Data Model (JSON Schema for Agent)

Pass this schema to the agent to define how a level is constructed.

```json
{
  "levelId": 12,
  "grid": [
    // 9x9 Array. 0 = Empty.
    [0, 4, 2, 0, 3, 7, 0, 0, 0],
    [0, 9, 0, 0, 6, 1, 0, 0, 0],
    [6, 5, 1, 4, 8, 2, 7, 0, 9],
    // ... remaining rows
  ],
  "solution": [
    // Full 9x9 solution grid for validation
    [8, 4, 2, 9, 3, 7, 1, 6, 5],
    // ...
  ],
  "config": {
    "lives": 3,
    "timeLimit": 0, // 0 = Infinite
    "colorTheme": "default_vibrant"
  }
}

```
