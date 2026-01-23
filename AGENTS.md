# AGENTS.md - Sudoku Pets Development Guide

**READ THIS FIRST** - This is the primary reference for all developers (human or AI) working on this project.

---

## 🎮 Project Overview

**Sudoku Pets** is a kid-friendly Sudoku game with collectible pets, learning helpers, and ethical gacha mechanics.

| Attribute | Value |
|-----------|-------|
| Engine | Godot 4.5.1-stable |
| Platforms | Web, PC, Android |
| Monetization | Free-to-play, paid DLC only, NO ads, NO real-money gacha |
| Audience | Kids 4+ and families |
| Art Style | Cute anime (Kirby/Pokemon/Animal Crossing inspired) |

---

## 🛠️ Development Environment

| Item | Path/Value |
|------|------------|
| Godot Executable | `C:\Godot_451_20251015\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe` |
| Project Path | `sudoku-pets/` |
| Viewport | 1280x720, centered, aspect "keep" |
| GitHub Repo | `https://github.com/MachineKomi/Sudoku-Pets` |

### Running the Game
```powershell
# Run with window
& "C:\Godot_451_20251015\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --path "sudoku-pets"

# Headless check for errors
& "C:\Godot_451_20251015\Godot_v4.5.1-stable_win64.exe\Godot_v4.5.1-stable_win64.exe" --path "sudoku-pets" --headless --quit 2>&1
```

---

## 👨‍👧 Development Context

This game is being built collaboratively with a 4-year-old. When communicating:
- Use simple, clear language
- Make decisions confidently - iterate based on testing
- Keep scope focused - add features later
- Test with actual kids when possible!

---

## 📁 Project Structure

```
sudoku-pets/
├── project.godot              # Godot config (4.5.1)
├── AGENTS.md                  # THIS FILE - read first!
├── README.md                  # Player-facing info
├── icon.svg                   # App icon
│
├── docs/                      # ALL documentation (consolidated)
│   ├── design/               # Technical design docs
│   │   ├── sudoku_pets_components.md  # Component model
│   │   └── domain_models/    # DDD domain models
│   ├── requirements/         # What to build
│   │   ├── user_stories.md   # User stories
│   │   ├── gdd.md            # Game Design Document
│   │   └── ui-spec.md        # UI/UX specification
│   ├── plans/                # Implementation plans
│   └── status/               # Progress tracking
│       ├── aidlc-state.md    # Current dev status
│       └── HANDOFF_SUMMARY.md # Context for new devs
│
├── HUMAN_TODO/                # Tasks for humans (art, etc.)
│   └── [date]_[task].md      # Dated task files
│
├── scenes/                    # All .tscn scene files
│   ├── main/                 # Main menu
│   ├── puzzle/               # Sudoku gameplay
│   └── pets/                 # Pet collection, gacha
│
├── scripts/
│   ├── autoload/             # Singletons (NO class_name!)
│   ├── domain/               # EventBus, domain events
│   ├── puzzle/               # Sudoku logic, events
│   ├── progression/          # XP, Gold, leveling
│   ├── pets/                 # Pet system, gacha
│   ├── settings/             # Game settings, dialogue
│   ├── resources/            # Data classes (PetData, etc.)
│   └── demo/                 # Demo scripts for testing
│
├── resources/                 # .tres files
│   └── config/               # Theme, settings
│
├── assets/                    # Art, audio (mostly TODO)
│   └── sprites/
│
└── test/                      # GUT tests
    └── unit/                 # Unit tests
```

---

## 💻 GDScript Standards (Godot 4.5.1)

### Critical Rules

```gdscript
# ❌ WRONG - Autoloads must NOT have class_name
class_name GameManager
extends Node

# ✅ CORRECT - Let Godot register via project.godot
extends Node
```

```gdscript
# ❌ WRONG - Type inference fails for array access in 4.5.1
var color := GEM_COLORS[index]
var cell := _cells[index]

# ✅ CORRECT - Use explicit types
var color: Color = GEM_COLORS[index]
var cell: Button = _cells[index]
```

### Code Order
```gdscript
## Documentation comment
extends ParentClass

signal something_happened(value: int)

const MAX_VALUE := 100

@export var setting: int = 10

var public_var: String = ""
var _private_var: int = 0

@onready var _node: Node = $Child


func _ready() -> void:
    pass


func public_method() -> void:
    pass


func _private_method() -> void:
    pass
```

### Naming
| Type | Convention | Example |
|------|------------|---------|
| Files | snake_case | `player_data.gd` |
| Classes | PascalCase | `class_name PlayerData` |
| Functions | snake_case | `func get_value()` |
| Variables | snake_case | `var player_health` |
| Constants | UPPER_CASE | `const MAX_HP := 100` |
| Signals | snake_case | `signal health_changed` |
| Private | _prefix | `var _internal` |

---

## 🧩 Core Systems

### Autoloads (scripts/autoload/)
| Singleton | Purpose |
|-----------|---------|
| GameManager | Game state, scene transitions |
| SaveManager | Persistence (JSON to user://) |
| AudioManager | Music and SFX |
| PetManager | Pet collection state |

### Sudoku Engine (scripts/puzzle/)
| File | Purpose |
|------|---------|
| sudoku_generator.gd | Creates valid puzzles |
| sudoku_validator.gd | Validates moves, checks completion |

### Resources (scripts/resources/)
| Resource | Purpose |
|----------|---------|
| PuzzleData | Puzzle definition (solution, starting grid) |
| PetData | Pet species definition |
| PetInstance | Player-owned pet instance |
| PlayerData | XP, Gold, level, progress |

---

## 🎯 Current Priorities

### Vertical Slice (IN PROGRESS)
1. ⚠️ Fix GDScript type errors for Godot 4.5.1
2. ⚠️ Fix scene navigation (menu buttons)
3. ⚠️ Fix signal connections (puzzle screen)
4. ⬜ Test complete flow: Menu → Puzzle → Win → Menu
5. ⬜ Test pet flow: Menu → Pets → Gacha → Collection

### After Vertical Slice
- Replace emoji with gem sprites
- Add sound effects
- Implement hint system
- Add more board sizes
- World map progression

---

## 🎨 HUMAN_TODO Workflow

The `HUMAN_TODO/` folder contains tasks requiring human action (art generation, etc.).

**Rules for AI:**
- CREATE new `.md` files with date prefix: `YYYY-MM-DD_task-name.md`
- DO NOT edit existing HUMAN_TODO files (humans update those)
- Include detailed AI art prompts with transparency notes
- Specify exact file paths for asset placement

**File Format:**
```markdown
# Task Title
**Created**: YYYY-MM-DD
**Status**: TODO | IN_PROGRESS | DONE
**Priority**: P0 | P1 | P2 | P3

[Detailed prompts and file paths]
```

---

## 📝 Key Documentation

| Document | Location | Purpose |
|----------|----------|---------|
| This file | `AGENTS.md` | Quick dev reference |
| **UI Spec** | `aidlc-docs/inception/game-design/ui-spec.md` | **Detailed UI/UX requirements** |
| Status | `aidlc-docs/aidlc-state.md` | Current progress |
| Handoff | `aidlc-docs/HANDOFF_SUMMARY.md` | Context for new devs |
| Decisions | `aidlc-docs/audit.md` | Why we chose what |
| GDD | `aidlc-docs/inception/game-design/gdd.md` | Full game design |
| Requirements | `aidlc-docs/inception/requirements/requirements.md` | Feature list |
| Art Tasks | `HUMAN_TODO/` | Art generation prompts |

---

## 🤖 Multi-Agent Collaboration

This project is developed by multiple AI agents (Claude, Gemini, GPT). Follow these rules for seamless collaboration:

### Code Comments
- Reference documentation sections: `// UI-SPEC 2.2: Color-coded tiles`
- Explain non-obvious logic: `// Lives system - see GDD 6.2`
- Mark TODOs with agent name: `// TODO(Claude): Add confetti effect`

### Documentation Updates
- Always update `aidlc-state.md` when completing work
- Add session notes to `audit.md`
- Create new HUMAN_TODO files for art needs (don't edit existing)

### Handoff Protocol
1. Update `aidlc-state.md` with current status
2. Add session summary to `audit.md`
3. Note any blockers or known issues
4. List files modified in this session

### Consistency Rules
- Follow GDScript standards in this file
- Match UI colors from `ui-spec.md` color table
- Use gem shapes/colors from GDD section 3.2
- Keep all text kid-friendly (no scary words)

---

## ⚠️ Common Errors & How to Avoid Them

### Error 1: "Identifier not declared in current scope"
**Cause**: Constant or variable was removed/renamed but still referenced elsewhere.
**Prevention**: 
- Add comments above constants: `## DO NOT REMOVE - used by function_name()`
- Search for usages before deleting anything
- Example fix: `const CELL_SIZE: int = 80  # Used by _build_grid(), _create_cell()`

### Error 2: "Cannot infer type of variable"
**Cause**: Godot 4.5.1 strict mode can't infer types from array/dictionary access.
**Prevention**:
```gdscript
# ❌ WRONG
var color := COLORS[index]
var item := dict["key"]

# ✅ CORRECT
var color: Color = COLORS[index]
var item: String = dict["key"]
```

### Error 3: "Invalid access to property or key"
**Cause**: Trying to access a signal/property before node is ready, or node path is wrong.
**Prevention**:
- Use `@onready` for node references
- Verify paths match .tscn file structure
- Add null checks: `if node: node.do_thing()`

### Error 4: "Node not found" / Signal connection fails
**Cause**: .tscn file has different node structure than .gd expects.
**Prevention**:
- Comment node paths in script: `# Path: CenterContainer/MainVBox/TopBar`
- When modifying .tscn, update corresponding .gd @onready vars
- Check signal connections in .tscn match method names in .gd

### Error 5: "Class 'X' hides an autoload singleton"
**Cause**: Using `class_name` on an autoload script.
**Prevention**: Never use `class_name` in scripts registered as autoloads in project.godot.

---

## 🚫 What NOT To Do

- ❌ No real-money purchases for gacha
- ❌ No advertisements
- ❌ No scary/negative content
- ❌ No pet death/neglect mechanics
- ❌ No dark patterns or FOMO
- ❌ No complex text (keep it simple for kids)
- ❌ No class_name on autoload scripts
- ❌ No type inference from array access

---

## ✅ Definition of Done

A feature is complete when:
1. Code follows GDScript standards above
2. No runtime errors in Godot 4.5.1
3. Works on touch devices (large tap targets)
4. Visually clear for young kids
5. No scary sounds or visuals
6. Documented in relevant .md files

---

*Last updated: 2026-01-22*
*Current phase: Construction - Vertical Slice*
