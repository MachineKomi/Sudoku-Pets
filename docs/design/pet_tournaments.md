# Pet Battle Tournament - Design Doc

## Overview
A simple, turn-based combat system where players can use their collected pets to battle in tournament ladders. Winning tournaments awards exclusive stickers for the Sticker Book collection.

## Core Mechanics

### 1. Stats & Progression
Pets stats are derived from their **Sudoku Level** (gained by solving puzzles):
- **HP (Health Points)**: Base + Level scaling
- **Attack**: Base + Level scaling
- **Speed**: Determines turn order
- **Type**: Rock / Paper / Scissors style advantages

### 2. Elemental Types
Classic weakness system to encourage collecting different pets:
- **Fire** 🔥 adds burn DOT.
- **Water** 💧 heals small amounts.
- **Nature** 🌿 high defense/HP.
- **Star/Cosmic** ✨ high crit chance.

### 3. Combat Loop
1. **Enter Tournament**: Select a ladder (Bronze -> Silver -> Gold).
2. **Team Selection**: Choose 1-3 pets for your team.
3. **Turn-Based Battle**:
   - Attack (Basic hit)
   - Special (Cooldown based, unique to species)
   - Swap (Switch active pet if team > 1)
4. **Victory/Defeat**:
   - Win: Advance bracket, heal 50%.
   - Lose: Tournament over, try again.

### 4. Special Attacks
Examples:
- **Phoenix Cat**: "Rebirth" (Heals on low HP) or "Fireball" (DMG + Burn)
- **Hoot Owl**: "Wisdom Strike" (High crit chance)
- **Fluffy Bunny**: "Mega Hop" (Speed up)

## Progression Loop relative to Sudoku
- **Play Sudoku** -> Earn XP & Gold -> Level up Pets -> **Get Stronger for Battle**
- **Win Battles** -> Earn Stickers & Badges -> **Complete Collection**

## Rewards
- **Stickers**: Static sprites awarded for clearing specific brackets.
- **Sticker Book**: A new UI screen to view collected battle trophies.
