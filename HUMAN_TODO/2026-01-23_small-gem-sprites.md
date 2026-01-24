# Small Gem Sprites Needed

**Date**: 2026-01-23
**Priority**: HIGH - Blocks pencil mode visual improvements
**Related Stories**: US-B.2, US-B.3

## Required Assets

We need small versions of each gem sprite for:
1. Pencil marks (candidate numbers) in sudoku cells
2. Number pad buttons when in pencil/draft mode

### Files Needed:

| File | Size | Notes |
|------|------|-------|
| `gem_1_small.png` | ~24x24px | Ruby Red circle |
| `gem_2_small.png` | ~24x24px | Amber Orange oval |
| `gem_3_small.png` | ~24x24px | Topaz Yellow triangle |
| `gem_4_small.png` | ~24x24px | Emerald Green square |
| `gem_5_small.png` | ~24x24px | Aquamarine Cyan pentagon |
| `gem_6_small.png` | ~24x24px | Sapphire Blue hexagon |
| `gem_7_small.png` | ~24x24px | Amethyst Purple star |
| `gem_8_small.png` | ~24x24px | Rose Pink diamond |
| `gem_9_small.png` | ~24x24px | White Diamond heart |
| `gem_10_small.png` | ~24x24px | (New gem for 10x10 boards) |

### Location:
Place in: `assets/sprites/gems/`

### Style Requirements:
- Match existing gem style (sparkly, colorful, cute)
- Transparent background (PNG)
- Should be recognizable at small size
- Clear silhouette/shape distinction between numbers
- Numbers should NOT be visible on small gems (shape only)

### AI Art Prompt Suggestion:
```
Tiny cute sparkly gem icon, [SHAPE] shape, [COLOR] color, 
kawaii style, transparent background, game UI element, 
24x24 pixels, crisp edges, no text, simple but recognizable
```

### Usage Context:
These small gems will appear:
1. Inside sudoku cells as pencil marks (up to 9 per cell)
2. On number pad buttons when pencil mode is active
3. Need to be clearly distinguishable at small size

## Workaround Until Assets Ready:
The code can fall back to small colored numbers if sprites aren't available, but the visual experience will be degraded.
