## ThemeManager - Handles visual themes (Normal/Zen mode) (Story 1.4)
## Autoload that manages the current visual style
extends Node


signal theme_changed(theme_name: String)


enum ThemeType {
	NORMAL,  ## Colorful anime style with gems
	ZEN      ## Pencil-on-paper, minimal, peaceful
}


var current_theme: ThemeType = ThemeType.NORMAL


## Theme color palettes
const THEMES: Dictionary = {
	ThemeType.NORMAL: {
		"name": "Normal",
		"background": Color("#1A1A2E"),
		"panel": Color("#16213E"),
		"accent": Color("#E94560"),
		"text": Color("#EAEAEA"),
		"button": Color("#0F3460"),
		"button_hover": Color("#1A5F7A"),
		"success": Color("#52B788"),
		"error": Color("#E63946"),
		"gold": Color("#FFD700"),
		"gem_mode": true
	},
	ThemeType.ZEN: {
		"name": "Zen",
		"background": Color("#F5F0E1"),
		"panel": Color("#E8E0D0"),
		"accent": Color("#5D4E37"),
		"text": Color("#3D3D3D"),
		"button": Color("#D4C9B5"),
		"button_hover": Color("#C4B9A5"),
		"success": Color("#4A7C59"),
		"error": Color("#8B4513"),
		"gold": Color("#B8860B"),
		"gem_mode": false  # Use plain numbers in Zen mode
	}
}


func _ready() -> void:
	# Load saved theme preference
	var saved_theme: int = SaveManager.get_value("display_theme", ThemeType.NORMAL)
	current_theme = saved_theme as ThemeType


func set_theme(theme: ThemeType) -> void:
	current_theme = theme
	SaveManager.set_value("display_theme", theme)
	SaveManager.save_game()
	theme_changed.emit(get_theme_name())


func toggle_theme() -> void:
	if current_theme == ThemeType.NORMAL:
		set_theme(ThemeType.ZEN)
	else:
		set_theme(ThemeType.NORMAL)


func get_theme_name() -> String:
	return THEMES[current_theme].name


func get_color(key: String) -> Color:
	return THEMES[current_theme].get(key, Color.WHITE)


func is_gem_mode() -> bool:
	return THEMES[current_theme].get("gem_mode", true)


func is_zen_mode() -> bool:
	return current_theme == ThemeType.ZEN
