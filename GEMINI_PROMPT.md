# Prompt for Gemini 3 Pro - Sudoku Pets

## Quick Context

You're picking up a Godot 4.5.1 project called "Sudoku Pets" - a kid-friendly Sudoku game with collectible pets. Claude set up the foundation but there are runtime errors preventing gameplay.

**Read these files first (in order):**
1. `AGENTS.md` - Development guide and conventions
2. `aidlc-docs/HANDOFF_SUMMARY.md` - Detailed context from Claude
3. `aidlc-docs/aidlc-state.md` - Current status and known issues
4. `aidlc-docs/inception/game-design/ui-spec.md` - **NEW: Detailed UI requirements with colors, layouts, power-ups**

---

## Multi-Agent Collaboration

This project uses Claude, Gemini, and GPT working together. Please:
- Add code comments referencing doc sections (e.g., `// UI-SPEC 2.2: Color-coded tiles`)
- Update `aidlc-state.md` when you complete work
- Add your session notes to `audit.md`
- Don't edit existing HUMAN_TODO files, create new dated ones if needed

---

## Your Mission

Get a **working vertical slice** - the game should be playable end-to-end:

1. **Menu loads** → Click "Play" → Puzzle screen loads
2. **Puzzle works** → 4x4 grid, click numbers, place on cells, get feedback
3. **Win state** → Complete puzzle → See rewards popup
4. **Return** → Click Continue → Back to menu with updated Gold/XP
5. **Pets work** → Menu → "My Pets" → Pull gacha → See collection

---

## Known Issues to Fix

### 1. GDScript Type Inference (Godot 4.5.1 is strict)
```gdscript
# ❌ Fails in 4.5.1
var color := COLORS[index]
var cell := _cells[index]

# ✅ Works
var color: Color = COLORS[index]
var cell: Button = _cells[index]
```

### 2. Signal Connections
`puzzle_screen.gd` tries to connect to signals on `sudoku_board` - may fail if timing is wrong or signals don't exist.

### 3. Scene Navigation
Main menu buttons call `get_tree().change_scene_to_file()` - verify paths match actual file locations.

---

## Key Files to Fix

| Priority | File | Issue |
|----------|------|-------|
| P0 | `scenes/puzzle/sudoku_board.gd` | Type errors, core gameplay |
| P0 | `scenes/puzzle/puzzle_screen.gd` | Signal connections |
| P0 | `scenes/main/main_menu.gd` | Scene navigation |
| P1 | `scenes/pets/pet_screen.gd` | Gacha logic |

---

## How to Test

```powershell
# Run game
& "C:\Godot_451_20251015\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --path "sudoku-pets"

# Check for errors without window
& "C:\Godot_451_20251015\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --path "sudoku-pets" --headless --quit 2>&1
```

---

## Important Conventions

- **NO class_name on autoloads** - Causes "hides singleton" error
- **Explicit types for array access** - `var x: Type = array[i]`
- **1280x720 viewport, centered UI** - Aspect ratio "keep"
- **Don't edit HUMAN_TODO files** - Only create new dated .md files

---

## Success = Playable Game

Don't report back until you can:
1. Launch game without errors
2. Play through a complete 4x4 puzzle
3. See win popup with rewards
4. Pull a pet from gacha
5. See pet in collection

## New UI Requirements

Reference `aidlc-docs/inception/game-design/ui-spec.md` for:
- Color-coded number tiles (section 2.2)
- Lives system with 3 hearts (section 4.1)
- Number pad with remaining count superscript (section 3.2)
- Pencil mode toggle (section 3.3)

These don't all need to be implemented now, but the vertical slice should follow the general layout.

Good luck! 🎮
