## PetSelectionWindow - Modal for choosing a companion
class_name PetSelectionWindow
extends Control

signal pet_selected(pet_id: String)

@onready var grid: GridContainer = $CenterContainer/Panel/VBox/ScrollContainer/Grid
@onready var close_button: Button = $CenterContainer/Panel/VBox/Header/CloseButton

## Species to display name mapping
const SPECIES_NAMES: Dictionary = {
	"cat": "Phoenix Cat",
	"bunny": "Fluffy Bunny",
	"owl": "Wise Owl",
	"fox": "Sparkle Fox",
	"dragon": "Fluffdragon",
	"whisker_cat": "Whisker Cat",
	"hoot_owl": "Hoot Owl",
	"fluffy_bunny": "Fluffy Bunny",
	"gobbo": "Gobbo",
	"sparkle_fish": "Sparkle Fish",
	"moon_moth": "Moon Moth",
	"crystal_deer": "Crystal Deer",
	"rainbow_bird": "Rainbow Bird",
	"fluffdragon": "Fluffdragon",
	"thunder_lion": "Thunder Lion",
	"ice_phoenix": "Ice Phoenix",
	"starlight_kirin": "Starlight Kirin",
	"galaxy_whale": "Galaxy Whale",
	"dream_phoenix": "Dream Phoenix",
}

func _ready() -> void:
	if close_button:
		close_button.pressed.connect(queue_free)
	
	_populate_grid()

func _populate_grid() -> void:
	# Clear existing
	for child in grid.get_children():
		child.queue_free()
	
	# PS-1: Get unique species from PetManager collection
	var seen_species: Dictionary = {}
	var pets: Array[Pet] = PetManager.get_all_pets()
	
	for pet in pets:
		if pet.species_id in seen_species:
			continue  # Skip duplicates
		seen_species[pet.species_id] = true
		_add_pet_button(pet)
	
	# If no pets, add default
	if seen_species.is_empty():
		var default_pet = Pet.new()
		default_pet.id = "default"
		default_pet.species_id = "cat"
		default_pet.nickname = "Phoenix"
		_add_pet_button(default_pet)

func _add_pet_button(pet: Pet) -> void:
	var display_name: String = SPECIES_NAMES.get(pet.species_id, pet.nickname)
	
	var btn := Button.new()
	btn.custom_minimum_size = Vector2(100, 130)
	# btn.text = display_name # Don't use button text, we'll use a label
	
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE # Let click pass to button
	vbox.add_theme_constant_override("separation", 5)
	vbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	# Icon
	var icon_rect := TextureRect.new()
	icon_rect.custom_minimum_size = Vector2(80, 80)
	icon_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	var icon_path := "res://assets/sprites/pets/%s.png" % pet.species_id
	if ResourceLoader.exists(icon_path):
		icon_rect.texture = load(icon_path)
	
	vbox.add_child(icon_rect)
	
	# Label
	var label := Label.new()
	label.text = display_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.add_theme_font_size_override("font_size", 12)
	vbox.add_child(label)
	
	btn.add_child(vbox)
	
	btn.pressed.connect(_on_pet_btn_pressed.bind(pet.id))
	grid.add_child(btn)


func _on_pet_btn_pressed(pet_id: String) -> void:
	pet_selected.emit(pet_id)
	queue_free()

