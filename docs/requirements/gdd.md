# Sudoku Pets - Game Design Document

## 1. Game Overview

### 1.1 Concept Statement
Sudoku Pets is a cozy, kid-friendly puzzle game that teaches Sudoku through colorful gem-shaped numbers, helpful learning tools, and adorable collectible pets that grow alongside the player. Solve puzzles, earn rewards, and build your dream pet collection - all without spending real money.

### 1.2 Genre
- Primary: Puzzle (Sudoku)
- Secondary: Virtual Pet Collection, Gacha

### 1.3 Target Audience
- **Age**: 4+ (designed for kids, enjoyable for all ages)
- **Experience**: Beginners to Sudoku experts
- **Platform preference**: Tablets, mobile phones
- **Similar games they enjoy**: Pokemon, Kirby, Animal Crossing, Candy Crush

### 1.4 Unique Selling Points
1. 🎓 **Learn by doing** - Hints explain WHY, not just WHAT
2. 💎 **Gem numbers** - Pre-readers can play with shapes/colors
3. 🐱 **Stress-free pets** - Collect and love, never lose
4. 💰 **Ethical gacha** - Earn everything through play
5. 📏 **All sizes** - 2x2 for tots to 9x9 for pros

### 1.5 Target Platforms
- **Primary**: iOS, Android (tablets)
- **Secondary**: PC (Windows/Mac), Web (HTML5)

---

## 2. Gameplay

### 2.1 Core Gameplay Loop

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│   ┌──────────┐    ┌──────────┐    ┌──────────┐            │
│   │  SOLVE   │───▶│  EARN    │───▶│  SPEND   │            │
│   │  SUDOKU  │    │  XP+GOLD │    │  ON PETS │            │
│   └──────────┘    └──────────┘    └──────────┘            │
│        ▲                               │                   │
│        │                               ▼                   │
│   ┌──────────┐                   ┌──────────┐             │
│   │  UNLOCK  │◀──────────────────│  COLLECT │             │
│   │  LEVELS  │                   │  & GROW  │             │
│   └──────────┘                   └──────────┘             │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

**Per-Puzzle Loop:**
1. Select a puzzle from world map
2. Place gem numbers on the board
3. Get XP for each correct placement
4. Complete puzzle → Get Gold + Stars
5. Pet companion celebrates with you!

### 2.2 Game Mechanics

#### Primary Mechanics

| Mechanic | Description | Player Input | Feedback |
|----------|-------------|--------------|----------|
| Number Placement | Put gems in empty cells | Tap cell, tap number | Sparkle (correct) or shake (wrong) |
| Hint System | Learn solving techniques | Tap hint button | Highlight + explanation |
| Pencil Marks | Note possible numbers | Long-press cell | Small numbers appear |

#### Secondary Mechanics

| Mechanic | Description |
|----------|-------------|
| Gacha Pull | Spend Gold to get random pet |
| Pet Feeding | Give treats to increase happiness |
| Pet Evolution | Level up pets to transform them |
| Mode Toggle | Switch between Normal/Relaxed/Zen |

### 2.3 Controls

#### Touch (Primary)
| Action | Gesture |
|--------|---------|
| Select cell | Tap |
| Place number | Tap number pad |
| Pencil mark | Long-press + tap numbers |
| Undo | Tap undo button |
| Get hint | Tap lightbulb |
| Pet interaction | Tap pet |

#### Keyboard (PC)
| Action | Key |
|--------|-----|
| Select cell | Arrow keys / Click |
| Place number | 1-9 keys |
| Pencil mode | Hold Shift |
| Undo | Ctrl+Z |
| Hint | H |

### 2.4 Game Flow

```
1. FIRST TIME
   └─▶ Meet your first pet (tutorial companion)
   └─▶ Learn basics with 2x2 puzzle
   └─▶ Unlock world map

2. EARLY GAME (Levels 1-20)
   └─▶ 2x2 and 4x4 puzzles
   └─▶ Learn basic Sudoku rules
   └─▶ First gacha pulls
   └─▶ Collect starter pets

3. MID GAME (Levels 21-50)
   └─▶ 6x6 puzzles unlock
   └─▶ Advanced techniques taught
   └─▶ Pet evolution begins
   └─▶ Rare pets available

4. LATE GAME (Levels 51+)
   └─▶ 9x9 puzzles unlock
   └─▶ Expert techniques
   └─▶ Legendary pets
   └─▶ Challenge modes

5. END GAME
   └─▶ Complete pet collection
   └─▶ 3-star all levels
   └─▶ Master all techniques
```

---

## 3. The Gem Number System

### 3.1 Why Gems?
Kids who can't read numbers yet can still play by matching shapes and colors. Each number 1-9 is a unique, beautiful gem.

### 3.2 Gem Designs

| Number | Gem Shape | Color | Visual |
|--------|-----------|-------|--------|
| 1 | Circle | Ruby Red | 🔴 |
| 2 | Oval | Orange Amber | 🟠 |
| 3 | Triangle | Yellow Topaz | 🟡 |
| 4 | Square | Emerald Green | 🟢 |
| 5 | Pentagon | Cyan Aquamarine | 🔵 |
| 6 | Hexagon | Sapphire Blue | 💙 |
| 7 | Star | Purple Amethyst | 💜 |
| 8 | Diamond | Pink Rose Quartz | 💗 |
| 9 | Heart | White Diamond | 🤍 |

### 3.3 Accessibility
- High contrast between all colors
- Distinct shapes even in grayscale
- Optional colorblind palette
- Number digit shown inside gem (optional toggle)

---

## 4. Board Sizes

### 4.1 Size Progression

| Size | Grid | Box Size | Numbers | Difficulty | Unlock |
|------|------|----------|---------|------------|--------|
| 2x2 | 4 cells | 2x1 | 1-2 | Tutorial | Start |
| 4x4 | 16 cells | 2x2 | 1-4 | Beginner | Level 1 |
| 6x6 | 36 cells | 2x3 | 1-6 | Intermediate | Level 15 |
| 9x9 | 81 cells | 3x3 | 1-9 | Standard | Level 30 |

### 4.2 Note on 2x2
A true 2x2 Sudoku is trivial (only 2 valid solutions exist), but it's perfect for:
- Teaching the basic rule (no repeats in row/column)
- Building confidence in very young players
- Tutorial purposes

---

## 5. Learning Helpers

### 5.1 Helper Features

| Helper | Description | Mode |
|--------|-------------|------|
| Row/Column Highlight | Shows related cells when selecting | All |
| Pencil Marks | Small numbers showing possibilities | All |
| Auto-Pencil | Fill all pencil marks automatically | Relaxed |
| Single Highlight | Glow cells with only one option | Relaxed |
| Mistake Explanation | "This can't be 3 because..." | All |
| Technique Hints | Teach solving strategies | Normal |

### 5.2 Mistake Feedback
When a player places a wrong number:
1. Cell shakes gently (not scary!)
2. Conflicting cells highlight
3. Pet companion says something encouraging
4. Popup explains: "Oops! There's already a [gem] in this row!"

### 5.3 Hint Progression
Hints teach real Sudoku techniques:
1. **Naked Single**: "This cell can only be one number!"
2. **Hidden Single**: "This row needs a 5, and only here works!"
3. **Pointing Pairs**: (Advanced, 9x9 only)
4. **Box/Line Reduction**: (Advanced, 9x9 only)

### 5.4 Power-Ups

Power-ups are unlocked through progression and can be earned or purchased with in-game currency (NOT real money).

| Power-Up | Icon | Function | Cost |
|----------|------|----------|------|
| Magic Lamp | 🪔 | Reveals correct number for ONE selected cell | 50 gems |
| Magic Eye | 👁️ | Highlights all cells where a specific number can go (5 sec) | 30 gems |
| Undo Plus | ↩️+ | Undo up to 10 moves (not just last one) | 20 gems |
| Time Freeze | ❄️ | Pauses timer for 60 seconds | 25 gems |
| Extra Life | ❤️+ | Restores one heart | 40 gems |

#### Magic Lamp Logic
```
1. Player taps Magic Lamp power-up
2. UI enters "lamp mode" - cursor changes
3. Player taps any empty cell
4. System looks up correct answer from solution
5. Number is placed with special "genie smoke" animation
6. Power-up consumed (count decreases)
7. Does NOT count as a mistake if wrong cell selected
```

#### Magic Eye Logic
```
1. Player taps Magic Eye power-up
2. Number pad highlights - "Select a number"
3. Player taps a number (e.g., 5)
4. All valid cells for that number glow for 5 seconds
5. Glow color matches the number's gem color
6. After 5 seconds, highlighting fades
7. Power-up consumed
```

### 5.5 Auto-Remove Notes Setting
- **Location**: Settings menu
- **Default**: ON
- **Behavior**: When a final number is placed, automatically remove that number from pencil marks in the same row, column, and 3x3 box
- **Why**: Reduces tedium, helps beginners focus on logic

---

## 6. Progression System

### 6.1 Currencies

| Currency | Earned From | Spent On | Icon |
|----------|-------------|----------|------|
| ⭐ XP | Each correct number placed | Player level up | Star |
| 🪙 Gold/Coins | Completing puzzles, daily rewards | Gacha pulls, treats | Gold coin |
| 💎 Gems | Special achievements, daily spin | Premium gacha, power-ups | Pink diamond |

### 6.2 Lives System

| Rule | Value |
|------|-------|
| Starting Lives | 3 hearts (5 for kids mode?) |
| Wrong Entry | Lose 1 heart |
| Zero Hearts | Puzzle failed, can retry |
| Restore | Wait for timer, watch reward, or restart |

### 6.3 XP Rewards

| Action | XP Earned |
|--------|-----------|
| Place correct number | 10 XP |
| Complete puzzle | 50 XP bonus |
| No mistakes (3 stars) | 50 XP bonus |
| First try completion | 25 XP bonus |

### 6.4 Gold Rewards

| Puzzle Size | Base Gold | 3-Star Bonus |
|-------------|-----------|--------------|
| 2x2 | 5 | +5 |
| 4x4 | 15 | +10 |
| 6x6 | 30 | +20 |
| 9x9 | 50 | +30 |

### 6.5 Star Rating

| Stars | Criteria |
|-------|----------|
| ⭐⭐⭐ | No mistakes |
| ⭐⭐☆ | 1-2 mistakes |
| ⭐☆☆ | 3+ mistakes |

### 6.6 Player Levels
- Level up every 500 XP (scales slightly)
- Each level unlocks something (new puzzle, pet slot, feature)
- Level displayed with cute badge

### 6.7 World Map
- Candy Crush style path through themed worlds
- Each node is a puzzle
- Backgrounds change (Forest → Beach → Mountains → Space)
- Can replay any completed level

---

## 7. Pet System

### 7.1 Pet Philosophy
- Pets are friends, not responsibilities
- They NEVER die, get sick, or run away
- They're always happy to see you
- They grow WITH you, not because of you

### 7.2 Pet Attributes

| Attribute | Description |
|-----------|-------------|
| Name | Player can rename |
| Species | Cat, Owl, Goblin, etc. |
| Rarity | Common → Rare → Epic → Legendary |
| Level | 1-100, gains XP when you play |
| Evolution | Transforms at certain levels |
| Happiness | Always high! Increases with treats |

### 7.3 Pet Interactions
- **Tap**: Pet does a cute animation, says something
- **Feed**: Give treats (costs Gold), happiness sparkles
- **Play**: Mini-interaction animations
- **Companion**: One pet accompanies you during puzzles

### 7.4 Gacha System

**Gacha Machine:**
- Cute physical machine in the pet area
- Pets visible inside clear gacha balls
- Pull animation is exciting but not predatory

**Pull Costs:**
| Pull Type | Cost | Rates |
|-----------|------|-------|
| Single | 100 Gold | Normal rates |
| 10-Pull | 900 Gold | Guaranteed Rare+ |

**Rarity Rates:**
| Rarity | Rate | Example Pets |
|--------|------|--------------|
| Common | 60% | Tabby Cat, Brown Owl |
| Rare | 30% | Calico Cat, Snowy Owl |
| Epic | 8% | Phoenix Cat, Mystic Owl |
| Legendary | 2% | Rainbow Cat, Cosmic Owl |

### 7.5 Pet Species (Initial)
- 🐱 Cats (various breeds/colors)
- 🦉 Owls (various types)
- 👺 Goblins (cute, not scary!)
- 🐰 Bunnies
- 🦊 Foxes
- 🐉 Baby Dragons

---

## 8. Game Modes

### 8.1 Normal Mode
- Full colorful gem visuals
- Rewards for every number
- Pet companion cheers you on
- Learning helpers available (toggle)

### 8.2 Relaxed/Breezy Mode
- All helpers always on
- Auto-pencil marks
- Highlights obvious moves
- Great for grinding Gold/XP
- "Farming mode" for pet collectors

### 8.3 Zen Mode
- Clean paper/pencil aesthetic
- No gems, just numbers
- No rewards or fanfare
- Pure Sudoku experience
- For when you want peace

---

## 9. Art & Audio

### 9.1 Art Style
- Cute anime inspired by Kirby, Pokemon, Animal Crossing
- Soft, rounded shapes
- Pastel color palette with vibrant accents
- Legally distinct original characters
- AI-generated with consistent style guide

### 9.2 UI Design
- Large, friendly buttons
- Minimal text (icons where possible)
- Soft shadows and gentle animations
- Child-safe (no small touch targets)

### 9.3 Audio Style
- **Music**: Relaxing, upbeat (Kirby OST vibes)
- **SFX**: Satisfying pops, sparkles, chimes
- **Pet Sounds**: Cute chirps, meows, coos
- No startling or loud sounds

---

## 10. Technical Specs

### 10.1 Engine
Godot Engine 4.2+

### 10.2 Performance Targets
- 60 FPS on mid-range devices
- < 3 second load times
- < 100MB install size
- Minimal battery usage

### 10.3 Save System
- Auto-save after every action
- Local save (no cloud initially)
- Multiple profiles for siblings

---

## 11. Monetization

### 11.1 Business Model
- **Premium**: One-time purchase ($4.99)
- **No ads**: Ever
- **No real-money gacha**: All currency earned in-game
- **DLC/Expansions**: New pet packs, world themes ($1.99-$2.99)

### 11.2 Ethical Commitment
- Parents can trust this game
- No dark patterns
- No FOMO mechanics
- No pay-to-win

---

## 12. Development Roadmap

### Phase 1: Core Sudoku (MVP)
- [ ] Sudoku puzzle generation (4x4, 6x6, 9x9)
- [ ] Basic board UI with gem numbers
- [ ] Touch input
- [ ] Win/lose detection
- [ ] Simple progression (XP/Gold)

### Phase 2: Learning & Polish
- [ ] Hint system
- [ ] Mistake explanations
- [ ] Pencil marks
- [ ] Sound effects
- [ ] Basic pet companion

### Phase 3: Pet System
- [ ] Gacha machine
- [ ] Pet collection
- [ ] Pet interactions
- [ ] Pet leveling

### Phase 4: World & Modes
- [ ] World map
- [ ] Relaxed mode
- [ ] Zen mode
- [ ] Music integration

### Phase 5: Polish & Release
- [ ] Full art pass
- [ ] All sound/music
- [ ] Tutorial flow
- [ ] Platform builds
- [ ] Testing with kids!
