# Sudoku Pets - Requirements

## 1. Game Concept

### One-Liner
A cute, kid-friendly Sudoku game where solving puzzles hatches and evolves adorable collectible pets.

### Core Loop
```
Solve Sudoku Numbers → Earn XP + Gold → Pull Gacha → Collect Pets → Level Up Pets → Unlock More Puzzles
```

### Unique Selling Points
1. **Learning-focused**: Teaches Sudoku with helpful hints that explain WHY
2. **Pre-reader friendly**: Numbers shown as colorful, distinct gem shapes
3. **Ethical gacha**: No real money - earn currency through gameplay only
4. **Stress-free pets**: No death, no neglect - just fun collection
5. **All skill levels**: 2x2 boards for toddlers to 9x9 for experts

---

## 2. Target Audience

### Primary
- **Age**: 4-12 years old
- **Experience**: Casual, learning to play games
- **Platform**: Tablets (iPad, Android tablets)
- **Interests**: Cute characters, collecting, simple puzzles

### Secondary
- **Age**: Parents/Adults
- **Experience**: Casual to core gamers
- **Platform**: Mobile phones, PC
- **Interests**: Relaxing puzzles, nostalgia (Tamagotchi, Pokemon)

---

## 3. Functional Requirements

### 3.1 Sudoku Gameplay

| ID | Requirement | Priority |
|----|-------------|----------|
| F-001 | Generate valid Sudoku puzzles for 2x2, 4x4, 6x6, 9x9 grids | P0 |
| F-002 | Validate player number placement in real-time | P0 |
| F-003 | Show visual feedback for correct/incorrect placement | P0 |
| F-004 | Display numbers as colorful gem shapes (not just digits) | P0 |
| F-005 | Support touch input for number selection and placement | P0 |
| F-006 | Track time spent on puzzle (optional display) | P2 |
| F-007 | Allow undo/redo of moves | P1 |

### 3.2 Learning Helpers (Toggle On/Off)

| ID | Requirement | Priority |
|----|-------------|----------|
| F-010 | Highlight row/column/box when cell selected | P1 |
| F-011 | Show "pencil marks" - possible numbers for each cell | P1 |
| F-012 | Auto-fill pencil marks on request | P1 |
| F-013 | Highlight cells where only one number is possible | P1 |
| F-014 | Explain WHY a placement is wrong when mistake made | P1 |
| F-015 | Hint system that teaches solving techniques | P2 |

### 3.3 Game Modes

| ID | Requirement | Priority |
|----|-------------|----------|
| F-020 | Normal Mode: Full visuals, rewards per number | P0 |
| F-021 | Relaxed/Breezy Mode: Auto-helpers always on | P1 |
| F-022 | Zen Mode: Clean paper/pencil aesthetic | P2 |

### 3.4 Progression System

| ID | Requirement | Priority |
|----|-------------|----------|
| F-030 | Award XP for each correctly placed number | P0 |
| F-031 | Award Gold for completing puzzles | P0 |
| F-032 | Player level system with XP thresholds | P1 |
| F-033 | World map with levels/challenges on a path | P1 |
| F-034 | Unlock new board sizes through progression | P1 |
| F-035 | Star rating per puzzle (1-3 stars based on performance) | P2 |

### 3.5 Pet System

| ID | Requirement | Priority |
|----|-------------|----------|
| F-040 | Gacha machine to spend Gold for random pets | P1 |
| F-041 | Pet collection/inventory screen | P1 |
| F-042 | Pets gain XP when you solve puzzles | P1 |
| F-043 | Pets level up and evolve/transform | P2 |
| F-044 | Pets have rarity tiers (Common → Legendary) | P2 |
| F-045 | Pet companion visible during gameplay (encourages you) | P1 |
| F-046 | Simple pet interactions (tap to pet, feed treats) | P2 |
| F-047 | Pets displayed in gacha balls (can see them inside) | P2 |

### 3.6 Audio/Visual

| ID | Requirement | Priority |
|----|-------------|----------|
| F-050 | Relaxing, upbeat background music (Kirby-style) | P1 |
| F-051 | Satisfying sound effects for correct placements | P1 |
| F-052 | Cute anime art style for all visuals | P0 |
| F-053 | Pet voice lines/sounds for encouragement | P2 |
| F-054 | Particle effects for rewards and celebrations | P1 |

### 3.7 Save/Load

| ID | Requirement | Priority |
|----|-------------|----------|
| F-060 | Auto-save progress | P0 |
| F-061 | Save puzzle state if exiting mid-puzzle | P1 |
| F-062 | Multiple save slots (for siblings) | P2 |

---

## 4. Non-Functional Requirements

### 4.1 Performance
- Target 60 FPS on mid-range mobile devices
- Load times under 3 seconds
- Minimal battery drain

### 4.2 Accessibility
- Large touch targets for small fingers
- High contrast gem colors
- Optional colorblind-friendly palette
- Simple, clear UI with minimal text

### 4.3 Monetization Constraints
- NO real-money purchases for gacha
- NO advertisements
- Premium purchase model with optional DLC/expansions
- All content earnable through gameplay

### 4.4 Content Safety
- Suitable for ages 4+
- No violence, scary content, or negative themes
- Pets cannot die or be harmed
- Positive, encouraging messaging only

---

## 5. Out of Scope (For Now)

- Multiplayer/online features
- Leaderboards
- Daily challenges (maybe later DLC)
- Pet trading
- Cloud saves
- Localization (English first)

---

## 6. Open Questions

1. **2x2 Sudoku**: Is this mathematically possible? Need to verify.
2. **Pet count**: How many unique pets at launch?
3. **Level count**: How many puzzles on the world map?
4. **Gacha rates**: What are fair rates for each rarity?
5. **Evolution paths**: Linear or branching pet evolutions?
