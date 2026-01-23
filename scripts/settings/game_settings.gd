## GameSettings - Aggregate for user preferences
class_name GameSettings
extends RefCounted


## Visual theme
var display_mode: DisplayMode.Mode = DisplayMode.Mode.NORMAL

## Helper mode shows hints and explanations
var helper_mode_enabled: bool = true

## Breezy mode auto-fills trivial answers
var breezy_mode_enabled: bool = false

## Audio settings
var music_volume: float = 0.8
var sfx_volume: float = 1.0
var music_enabled: bool = true
var sfx_enabled: bool = true


## Toggle helper mode
func toggle_helper_mode() -> void:
	helper_mode_enabled = not helper_mode_enabled


## Toggle breezy mode
func toggle_breezy_mode() -> void:
	breezy_mode_enabled = not breezy_mode_enabled


## Set display mode
func set_display_mode(mode: DisplayMode.Mode) -> void:
	display_mode = mode


## Is zen mode active?
func is_zen_mode() -> bool:
	return display_mode == DisplayMode.Mode.ZEN


## Serialize for save
func to_dict() -> Dictionary:
	return {
		"display_mode": display_mode,
		"helper_mode_enabled": helper_mode_enabled,
		"breezy_mode_enabled": breezy_mode_enabled,
		"music_volume": music_volume,
		"sfx_volume": sfx_volume,
		"music_enabled": music_enabled,
		"sfx_enabled": sfx_enabled
	}


## Deserialize from save
static func from_dict(data: Dictionary) -> GameSettings:
	var settings := GameSettings.new()
	settings.display_mode = data.get("display_mode", DisplayMode.Mode.NORMAL)
	settings.helper_mode_enabled = data.get("helper_mode_enabled", true)
	settings.breezy_mode_enabled = data.get("breezy_mode_enabled", false)
	settings.music_volume = data.get("music_volume", 0.8)
	settings.sfx_volume = data.get("sfx_volume", 1.0)
	settings.music_enabled = data.get("music_enabled", true)
	settings.sfx_enabled = data.get("sfx_enabled", true)
	return settings
