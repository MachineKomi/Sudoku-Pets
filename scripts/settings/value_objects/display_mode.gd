## DisplayMode - Value object for visual theme
class_name DisplayMode
extends RefCounted


enum Mode {
	NORMAL,  ## Colorful gems, anime UI, companion visible
	ZEN      ## Clean pencil-on-paper, minimal UI, no pets
}


var mode: Mode


func _init(display_mode: Mode = Mode.NORMAL) -> void:
	mode = display_mode


func get_name() -> String:
	match mode:
		Mode.NORMAL:
			return "Normal"
		Mode.ZEN:
			return "Zen"
	return "Unknown"


func is_zen() -> bool:
	return mode == Mode.ZEN


## Get description for settings menu
func get_description() -> String:
	match mode:
		Mode.NORMAL:
			return "Colorful gems, cute companion, and fun effects!"
		Mode.ZEN:
			return "Clean and simple, like pencil on paper."
	return ""
