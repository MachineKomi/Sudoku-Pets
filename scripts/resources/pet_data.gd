## PetData - Resource defining a pet species
class_name PetData
extends Resource

enum Rarity { COMMON, RARE, EPIC, LEGENDARY }

@export var id: String = ""
@export var display_name: String = ""
@export var species: String = ""  # cat, owl, bunny, etc.
@export var rarity: Rarity = Rarity.COMMON
@export var description: String = ""

@export_group("Visuals")
@export var sprite: Texture2D
@export var idle_frames: SpriteFrames
@export var color_primary: Color = Color.WHITE
@export var color_secondary: Color = Color.WHITE

@export_group("Evolution")
@export var evolves_at_level: int = 0  # 0 = doesn't evolve
@export var evolves_into: PetData = null

@export_group("Dialogue")
@export var greeting_lines: Array[String] = []
@export var encouragement_lines: Array[String] = []
@export var celebration_lines: Array[String] = []


func get_random_greeting() -> String:
	if greeting_lines.is_empty():
		return "Hi there!"
	return greeting_lines[randi() % greeting_lines.size()]


func get_random_encouragement() -> String:
	if encouragement_lines.is_empty():
		return "You can do it!"
	return encouragement_lines[randi() % encouragement_lines.size()]


func get_random_celebration() -> String:
	if celebration_lines.is_empty():
		return "Yay!"
	return celebration_lines[randi() % celebration_lines.size()]
