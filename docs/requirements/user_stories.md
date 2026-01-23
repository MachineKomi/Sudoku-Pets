# Sudoku Pets: User Stories & Requirements

## 1. Vision & Personas

**Vision**: A "clean", kid-friendly, ad-free Sudoku game that hybridizes puzzle solving with "Tamagotchi" style pet collecting and RPG progression. It must be sufficiently visually stimulating ("candy crush" addictive) for children while offering depth for adults.

### Personas

1.  **Kira (The Learner)**
    *   **Age**: 4-7 years old.
    *   **Motivation**: Loves "cute" things, colors, and collecting. Wants to play but doesn't fully grasp Sudoku rules yet.
    *   **Pain Points**: Frustrated by abstract numbers and harsh failure states.
    *   **Needs**: distinct visual cues (gems), constant encouragement, "helper" modes that guide rather than punish.

2.  **Alex (The Relaxed Parent)**
    *   **Age**: Adult.
    *   **Motivation**: Wants a "zen" experience to unwind, or to play alongside a child. Enjoys filling progression bars and collecting things.
    *   **Pain Points**: Intrusive ads, complex monetization, pay-to-win.
    *   **Needs**: A "Zen Hardmode" for pure puzzle solving, effortless synchronization with the child's progress.

3.  **The "Gacha" Gamer**
    *   **Motivation**: Completing collections, leveling up characters, finding "Rare" items.
    *   **Needs**: Constant small feedback loops (XP, Gold), tangible rewards for gameplay success.

---

## 2. Epics & User Stories

### Epic 1: Core Sudoku Gameplay (The "Puzzle")
*The fundamental act of solving the board, adapted for broad appeal.*

*   **Story 1.1 (Visual Numbers)**: As **Kira**, I want numbers to be represented as distinct, colorful "Gems" (e.g., Red Ruby 1, Blue Sapphire 2), so that I can distinguish them even if I'm not confident reading numbers yet.
*   **Story 1.2 (Grid Scaling)**: As **Kira**, I want to play on smaller grids (2x2, 6x6) before tackling 9x9, so that I can learn the rules without being overwhelmed.
*   **Story 1.3 (Input Feedback)**: As **a Player**, I want immediate visual feedback when I select a cell (white border) or place a number, so I know the game registered my action.
*   **Story 1.4 (Zen Mode)**: As **Alex**, I want a "Zen Hardmode" that replaces gems/anime art with a clean pencil-on-paper aesthetic, so I can focus purely on logic when I want a traditional experience.
*   **Story 1.5 (Pencil Notes)**: As **Alex**, I want to toggle "Note Mode" to place small candidate numbers in a cell (mapped to a 3x3 micro-grid), so I can track possibilities without committing.

### Epic 2: Tutorial & "Smart" Helper (The "Teacher")
*Features that teach the player, rather than just solving it for them.*

*   **Story 2.1 (Educated Error)**: As **Kira**, when I make a mistake, I want the game to visually show *why* it is wrong (e.g., "Look! There is already a Blue Gem in this row!"), so I learn the rules.
*   **Story 2.2 (Hint System)**: As **Kira**, I want a "Hint" button that highlights a logical next move based on available info (e.g., "Only one 3 is missing here"), rather than just filling a random square.
*   **Story 2.3 (Breezy/Lazy Mode)**: As **a Player**, I want to toggle "Breezy Mode" (or use "Cheats") that auto-fills trivial answers (e.g., "Full House" where only 1 number is left), so I can fast-track the grind for gold/XP.
*   **Story 2.4 (Encouragement)**: As **Kira**, I want the Cat Girl companion to cheer for me when I do well and offer gentle support when I fail, so I don't feel discouraged.

### Epic 3: Meta-Progression (The "Journey")
*The "Candy Crush" style map and RPG elements.*

*   **Story 3.1 (World Map)**: As **a Player**, I want to scroll through a "World Map" path with distinct biomes (Jungle, Desert), unlocking levels sequentially, so I feel a sense of progression.
*   **Story 3.2 (Level Replayability)**: As **a Player**, I want to be able to replay previous levels in different modes (Normal, Zen, Hard), so I can farm resources or just enjoy a favorite puzzle.
*   **Story 3.3 (Star Rating)**: As **a Player**, I want to earn 1-3 stars per level based on my performance (mistakes made, time taken), so I have a goal to master.
*   **Story 3.4 (XP & Gold)**: As **a Player**, I want to earn "Gold" for completing levels and "XP" for every correct number placed, so every action feels rewarding.

### Epic 4: Collection & Gacha (The "Reward")
*The "Tamagotchi" and "Pokemon" inspired layer.*

*   **Story 4.1 (Gacha Machine)**: As **a Player**, I want to spend my earned Gold at a Gacha Machine to unlock new Pet Capsules, so I can expand my collection.
*   **Story 4.2 (Pet Collection)**: As **a Player**, I want to view my collected pets (Goblins, Owls, Mythical Creatures) in a gallery/sanctuary, so I can admire what I've earned.
*   **Story 4.3 (Pet Leveling)**: As **a Player**, I want my equipped active pet to gain XP from my Sudoku solving and "Evolve" or change appearance at higher levels, so I bond with them.
*   **Story 4.4 (Pet Interaction)**: As **Kira**, I want to "feed" or "play" with my pets in a simple, non-punishing way (they never die), so I feel like I'm taking care of them.

### Epic 5: Visuals & Audio (The "Vibe")
*The specific aesthetic requirements.*

*   **Story 5.1 (Anime Aesthetic)**: As **a Player**, I want high-quality, cute anime-style artwork for characters and UI, so the game feels premium and inviting.
*   **Story 5.2 (Juicy Feedback)**: As **a Player**, when I complete a board, I want a massive "Confetti" explosion and celebration screen, so I feel a rush of dopamine ("Candy Crush" effect).
*   **Story 5.3 (Relaxing Audio)**: As **Alex**, I want an upbeat but peaceful soundtrack (think "Kirby" or "Animal Crossing"), so the experience remains stress-free.

### Epic 6: Monetization & Technical (The "Contract")
*Scope constraints and business model.*

*   **Story 6.1 (No Ads)**: As **Alex**, I want a strictly ad-free experience to ensure it is safe and uninterrupted for my child.
*   **Story 6.2 (DLC Model)**: As **Alex**, I want to be able to buy "Expansions" or "Level Packs" as a one-time purchase if we enjoy the game, avoiding predatory microtransactions.
*   **Story 6.3 (Offline Play)**: As **Alex**, I want the game to work fully offline, so we can play on tablets during travel.

---

## 3. Acceptance Criteria Summary

*   **Gameplay**: 9x9 Grid (standard) & 6x6/2x2 (easy), drag-and-drop or tap-to-select input.
*   **Visuals**: "Gem" numbers, specific color palette per number (1=Rust, 2=Gold, etc.), "Parchment" board background.
*   **Audio**: Positive reinforcement sfx, looping BGM.
*   **Platform**: Windows (Godot export), adaptable to Mobile touch input.
