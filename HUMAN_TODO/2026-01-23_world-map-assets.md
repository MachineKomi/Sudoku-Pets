# World Map Art Assets Needed

## Overview
The World Map screen (Story 3.1) needs decorative backgrounds and icons for the 5 biomes.

## Required Assets

### Biome Backgrounds (Optional but nice-to-have)
These would replace the solid color backgrounds with themed illustrations.

| Filename | Description | Prompt for Generation |
|----------|-------------|----------------------|
| `biome_meadow.png` | Green meadow with flowers | "Cute cartoon meadow landscape with rolling green hills, colorful flowers, blue sky with fluffy clouds, kid-friendly anime style" |
| `biome_beach.png` | Tropical beach scene | "Cute cartoon tropical beach with palm trees, gentle waves, sunny sky, kid-friendly anime style" |
| `biome_forest.png` | Enchanted forest | "Cute cartoon enchanted forest with tall trees, magical glowing plants, mushrooms, kid-friendly anime style" |
| `biome_mountain.png` | Snowy mountain peaks | "Cute cartoon mountain range with snow-capped peaks, pine trees, clear sky, kid-friendly anime style" |
| `biome_cloud.png` | Floating cloud kingdom | "Cute cartoon cloud kingdom in the sky, fluffy clouds, rainbow, magical atmosphere, kid-friendly anime style" |

**Resolution**: 1280x720 PNG, landscape orientation

### Level Node Icons (Priority)
These circular icons represent levels on the map.

| Filename | Description | Prompt for Generation |
|----------|-------------|----------------------|
| `level_locked.png` | Padlock icon for locked levels | "Simple 2D padlock icon, silver metallic, cute style, on transparent background, 64x64" |
| `level_unlocked.png` | Star burst for unlocked levels | "Circular star burst badge, golden glow, cute style, on transparent background, 64x64" |
| `level_completed.png` | Checkmark with stars | "Circular badge with checkmark and 3 stars, golden, victory celebration, cute style, 64x64" |

**Resolution**: 64x64 PNG with transparency

### Star Icons
| Filename | Description | Prompt |
|----------|-------------|--------|
| `star_filled.png` | Golden glowing star | "Cute 2D golden star icon, glowing, cartoon style, 32x32, transparent background" |
| `star_empty.png` | Gray outline star | "Simple 2D star outline, gray, cartoon style, 32x32, transparent background" |

## Current Implementation
The world map currently uses:
- Solid colors for biomes (works but basic)
- Text/emoji for level nodes ("1", "2", "🔒")
- Unicode stars (★☆) for ratings

## Integration Instructions
Once you have the images:
1. Place files in `assets/sprites/ui/world_map/`
2. Update `world_map_screen.gd` to load and display textures
3. The code is designed to work with or without these assets (graceful fallback)

## Notes
- Keep the style consistent with the existing gem sprites
- Bright, cheerful, kid-friendly artwork
- Avoid anything scary or intimidating
