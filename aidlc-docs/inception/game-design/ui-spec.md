# Sudoku Pets - UI Specification

**Version**: 1.0
**Last Updated**: 2026-01-22
**Status**: Reference Design (based on competitor analysis)

> **FOR ALL AI AGENTS**: This document defines the target UI/UX. Reference this when implementing or modifying any UI components. Keep code comments aligned with section numbers (e.g., "// UI-SPEC 2.1: Color-coded tiles").

---

## 1. Top Header & Status Bar

The header manages game state, progression tools, and monetization.

### 1.1 Power-up Slots
- **Location**: Top of screen, horizontal row
- **Count**: 4 circular slots
- **Initial State**: Locked with padlock icon 🔒
- **Unlock**: Via level progression or purchase
- **Visual**: Brown circular buttons with gold trim

### 1.2 Currency Display
| Currency | Icon | Position | Example |
|----------|------|----------|---------|
| Gems | 💎 Pink diamond | Left side | "💎 13" |
| Coins | 🪙 Gold coin | Below gems | "🪙 16,000" |

- **Store Access**: Green "+" button next to currencies
- **Tap Action**: Opens in-app purchase / reward screen

### 1.3 Customization
- **Icon**: Paint palette 🎨
- **Function**: Switch themes or tile color sets
- **Position**: Center-right of header

### 1.4 Game Management
| Element | Icon | Function |
|---------|------|----------|
| Pause | ⏸️ "II" | Halt timer, show settings menu |
| Timer | ⏱️ | Digital clock (MM:SS format) |
| Lives | ❤️❤️❤️ | Three hearts, lose one per mistake |

---

## 2. The Sudoku Grid

Main play area with color-coded visual assistance.

### 2.1 Grid Layout
- **Size**: 9x9 cells
- **Subgrids**: 3x3 boxes with thicker borders
- **Border Style**: Dark brown wood-texture frame
- **Background**: Cream/beige color

### 2.2 Color-Coded Tile System

Each number (1-9) has a unique background color:

| Number | Color Name | Hex Code | RGB |
|--------|------------|----------|-----|
| 1 | Coral/Salmon | #F4A683 | 244, 166, 131 |
| 2 | Warm Yellow | #F9D56E | 249, 213, 110 |
| 3 | Sky Blue | #7EC8E3 | 126, 200, 227 |
| 4 | Mint Green | #7DD87D | 125, 216, 125 |
| 5 | Light Green | #A8E6CF | 168, 230, 207 |
| 6 | Lavender | #C9B1FF | 201, 177, 255 |
| 7 | Purple | #B19CD9 | 177, 156, 217 |
| 8 | Pink | #FFB6C1 | 255, 182, 193 |
| 9 | Teal | #5DADE2 | 93, 173, 226 |

> **Note**: These colors are approximations from screenshots. Adjust for accessibility.

### 2.3 Cell States

| State | Visual Treatment |
|-------|------------------|
| Empty | White/cream background |
| Given (pre-filled) | Colored background, darker text |
| Player-filled | Colored background, standard text |
| Selected | Thick white border highlight |
| Same-number highlight | Subtle glow on matching numbers |
| Error | Red flash, then normal |

### 2.4 Candidate/Notes System (Pencil Marks)
- **Display**: Small numbers in cell (e.g., "258" or "12348")
- **Font Size**: ~30% of main number size
- **Layout**: Can show multiple candidates per cell
- **Color**: Gray or muted version of number colors

### 2.5 Completion Feedback
- **Trigger**: Final correct number placed
- **Animation**: Confetti particle effect overlay
- **Duration**: 2-3 seconds
- **Sound**: Celebration jingle

---

## 3. Input & Navigation Footer

Primary interaction area for number entry.

### 3.1 Number Pad Layout

```
┌─────┬─────┬─────┬─────┬─────┐
│  1⁷ │  2⁶ │  3⁵ │  4⁵ │  5⁶ │
├─────┼─────┼─────┼─────┼─────┤
│  6⁴ │  7³ │  8⁶ │  9³ │     │
└─────┴─────┴─────┴─────┴─────┘
```

### 3.2 Number Button Features
- **Background**: Matches the number's tile color
- **Superscript Counter**: Shows remaining count needed
  - Example: "1⁷" means 7 more 1s needed on board
- **Exhaustion State**: When count = 0, button dims/grays out
- **Size**: Large touch targets (minimum 48x48dp)

### 3.3 Input Toggles
| Button | Icon | Function |
|--------|------|----------|
| Pencil Mode | ✏️ | Toggle between final entry and notes |
| Undo | ↩️ | Revert last move |

### 3.4 Button States
- **Normal**: Full color, active
- **Selected**: Highlighted border
- **Disabled**: Grayed out (number exhausted)
- **Pencil Active**: Pencil icon highlighted

---

## 4. Game Mechanics

### 4.1 Lives System
| Rule | Behavior |
|------|----------|
| Starting Lives | 3 hearts |
| Wrong Entry | Lose 1 heart, cell flashes red |
| Zero Hearts | Game Over screen |
| Restore Lives | Watch ad, use power-up, or restart |

### 4.2 Note Auto-Removal
- **Setting**: Toggle in options menu
- **Behavior**: When final number placed, automatically remove that number from notes in same row, column, and 3x3 box
- **Default**: ON (recommended for beginners)

### 4.3 Timer
- **Format**: MM:SS (e.g., "14:54")
- **Pause**: Stops when game paused
- **Completion**: Final time shown on win screen
- **Star Rating**: Based on time + mistakes

### 4.4 Star Rating System
| Stars | Criteria |
|-------|----------|
| ⭐⭐⭐ | No mistakes, fast time |
| ⭐⭐☆ | 1-2 mistakes OR slow time |
| ⭐☆☆ | 3+ mistakes OR very slow |

---

## 5. Power-Ups

### 5.1 Magic Lamp 🪔
- **Function**: Reveals the correct number for ONE selected cell
- **Usage**: Tap power-up, then tap empty cell
- **Cost**: 1 use per activation
- **Visual**: Genie smoke animation, number appears

### 5.2 Magic Eye 👁️
- **Function**: Highlights all cells where a specific number can go
- **Usage**: Tap power-up, then tap a number (1-9)
- **Duration**: 5 seconds of highlighting
- **Visual**: Cells glow with that number's color

### 5.3 Undo Plus ↩️+
- **Function**: Undo multiple moves (not just last one)
- **Usage**: Opens move history, select how far to revert
- **Limit**: Up to 10 moves back

### 5.4 Time Freeze ❄️
- **Function**: Pauses timer for 60 seconds
- **Usage**: Tap to activate
- **Visual**: Snowflake particles, timer turns blue

---

## 6. Screens & Navigation

### 6.1 Screen Flow
```
┌─────────────┐
│  Main Menu  │
└──────┬──────┘
       │
   ┌───┴───┬───────────┬──────────┐
   ▼       ▼           ▼          ▼
┌──────┐ ┌──────┐ ┌─────────┐ ┌────────┐
│ Play │ │ Pets │ │Settings │ │ Shop   │
└──┬───┘ └──┬───┘ └─────────┘ └────────┘
   │        │
   ▼        ▼
┌──────┐ ┌──────────┐
│World │ │Pet Screen│
│ Map  │ │ + Gacha  │
└──┬───┘ └──────────┘
   │
   ▼
┌──────────┐
│  Puzzle  │
│  Screen  │
└──┬───────┘
   │
   ▼
┌──────────┐
│Win/Lose  │
│  Popup   │
└──────────┘
```

### 6.2 World Map (Future)
- **Style**: Candy Crush-like path through themed worlds
- **Themes**: Jungle, Ruins, Beach, Mountains, Space
- **Nodes**: Each node = one puzzle level
- **Stars**: Show 0-3 stars earned per level
- **Unlock**: Linear progression, complete level to unlock next

### 6.3 Daily Rewards (Future)
- **Spin Wheel**: Daily free spin
- **Rewards**: Coins, gems, power-ups, pet eggs
- **Streak Bonus**: Better rewards for consecutive days

---

## 7. Sudoku Pets Adaptations

How we adapt the reference UI for our kid-friendly theme:

### 7.1 Visual Changes
| Reference | Sudoku Pets Version |
|-----------|---------------------|
| Plain numbers | Gem-shaped numbers with colors |
| Hearts for lives | Cute heart icons with faces |
| Generic confetti | Pet-themed celebration (pet dances) |
| Wood texture | Soft pastel/anime style |

### 7.2 Kid-Friendly Modifications
- **No real-money purchases** - Earn all currency through play
- **Forgiving lives** - Maybe 5 lives instead of 3
- **Encouraging feedback** - Pet companion cheers, never scolds
- **Simpler power-ups** - Start with just Hint and Undo

### 7.3 Pet Integration
- **Companion Display**: Small pet in corner during puzzle
- **Reactions**: Pet reacts to correct/wrong moves
- **Celebration**: Pet does happy dance on completion
- **Speech Bubbles**: Encouraging messages

---

## 8. Implementation Checklist

### Phase 1 (MVP)
- [ ] Basic 9x9 grid with color-coded cells
- [ ] Number pad with remaining count
- [ ] Lives system (3 hearts)
- [ ] Timer display
- [ ] Win/lose detection
- [ ] Pencil mode toggle
- [ ] Undo button

### Phase 2 (Polish)
- [ ] Cell selection highlighting
- [ ] Same-number highlighting
- [ ] Confetti on win
- [ ] Pet companion reactions
- [ ] Sound effects

### Phase 3 (Features)
- [ ] Power-ups (Hint, Magic Eye)
- [ ] World map progression
- [ ] Daily rewards
- [ ] Theme customization

---

## 9. Asset Requirements

See `HUMAN_TODO/2026-01-22_art-assets-needed.md` for detailed art prompts.

### New Assets Needed (from this spec):
- Heart icons (full, empty, breaking animation)
- Power-up icons (lamp, eye, undo+, freeze)
- Pause button icon
- Timer icon
- Store/shop button
- Theme selector icon
- Confetti particles
- Wood texture frame for grid
- Number pad button backgrounds (9 colors)

---

*This document should be updated whenever UI requirements change. All AI agents working on this project should reference this spec and note the section number in code comments.*
