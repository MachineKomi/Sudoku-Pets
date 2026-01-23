## SettingsScreen - User preferences UI (Stories 1.4, 5.3)
extends Control


@onready var music_slider: HSlider = $CenterContainer/Panel/VBox/MusicRow/MusicSlider
@onready var sfx_slider: HSlider = $CenterContainer/Panel/VBox/SFXRow/SFXSlider
@onready var theme_button: Button = $CenterContainer/Panel/VBox/ThemeRow/ThemeButton
@onready var breezy_toggle: CheckButton = $CenterContainer/Panel/VBox/BreezyRow/BreezyToggle


func _ready() -> void:
	_load_settings()


func _load_settings() -> void:
	# Audio settings
	if music_slider:
		music_slider.value = AudioManager.music_volume * 100
	if sfx_slider:
		sfx_slider.value = AudioManager.sfx_volume * 100
	
	# Theme
	if theme_button:
		theme_button.text = "🎨 Theme: " + ThemeManager.get_theme_name()
	
	# Breezy mode
	if breezy_toggle:
		breezy_toggle.button_pressed = SaveManager.get_value("breezy_mode", false)


func _on_music_slider_value_changed(value: float) -> void:
	AudioManager.music_volume = value / 100.0
	SaveManager.set_value("music_volume", value / 100.0)


func _on_sfx_slider_value_changed(value: float) -> void:
	AudioManager.sfx_volume = value / 100.0
	SaveManager.set_value("sfx_volume", value / 100.0)


func _on_theme_button_pressed() -> void:
	ThemeManager.toggle_theme()
	if theme_button:
		theme_button.text = "🎨 Theme: " + ThemeManager.get_theme_name()


func _on_breezy_toggle_toggled(toggled_on: bool) -> void:
	SaveManager.set_value("breezy_mode", toggled_on)
	SaveManager.save_game()


func _on_close_pressed() -> void:
	SaveManager.save_game()
	queue_free()
