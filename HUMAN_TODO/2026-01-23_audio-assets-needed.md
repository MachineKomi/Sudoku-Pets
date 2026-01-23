# Audio Assets Needed

## Overview
Sprint 5 audio integration requires BGM and SFX files. The AudioManager is ready to play them.

## Required Audio Files

### Background Music (BGM)
Place in `assets/audio/bgm/`

| Filename | Description | Prompt for AI Music Generation |
|----------|-------------|-------------------------------|
| `main_menu.ogg` | Cheerful, welcoming tune | "Upbeat cheerful lofi background music, Kirby game style, 30 second loop, kid-friendly" |
| `puzzle_theme.ogg` | Calm, thinking music | "Calm relaxing puzzle game music, Animal Crossing style, piano and soft synth, 60 second loop" |
| `victory.ogg` | Short celebration jingle | "Victory celebration jingle, 5 seconds, triumphant and cute, game sound" |
| `pet_screen.ogg` | Playful, cozy tune | "Playful cozy background music, pet game style, soft and warm, 45 second loop" |

**Format**: OGG Vorbis, 44.1kHz, stereo. Godot imports .ogg directly.

### Sound Effects (SFX)
Place in `assets/audio/sfx/`

| Filename | Description | Prompt |
|----------|-------------|--------|
| `cell_tap.wav` | Selecting a grid cell | "Soft UI tap click sound, game interface, short" |
| `number_place.wav` | Placing a number | "Positive pop sound effect, gem placing, satisfying" |
| `correct.wav` | Correct answer feedback | "Success ding sound, positive feedback, game sound" |
| `error.wav` | Wrong answer feedback | "Soft error buzz, gentle wrong answer, not harsh" |
| `level_complete.wav` | Finishing a puzzle | "Level complete fanfare, celebration, short jingle" |
| `gacha_spin.wav` | Gacha capsule spinning | "Slot machine spinning sound, exciting anticipation" |
| `gacha_reveal.wav` | New pet revealed | "Magical reveal sound, sparkle and wonder, exciting" |
| `button_click.wav` | Generic button press | "UI button click, satisfying, game interface" |
| `star_earn.wav` | Earning a star | "Star collect sound, twinkle, reward" |

**Format**: WAV, 44.1kHz, mono. Keep files short (< 2 seconds).

## Integration Code
Once files are added, load them like this:

```gdscript
# In puzzle_screen.gd
var sfx_correct := preload("res://assets/audio/sfx/correct.wav")
AudioManager.play_sfx(sfx_correct)
```

## Free Sources (Optional)
- [Freesound.org](https://freesound.org) - Free sound effects (check licenses)
- [Incompetech](https://incompetech.com) - Royalty-free music (credit required)
- [OpenGameArt](https://opengameart.org) - Game audio assets

## Notes
- Keep all audio kid-friendly
- Avoid loud/startling sounds - this is a relaxing game
- Test on speakers AND headphones
- Looping music should have seamless loop points
