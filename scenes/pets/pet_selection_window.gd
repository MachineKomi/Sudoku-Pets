## PetSelectionWindow - Modal for choosing a companion
class_name PetSelectionWindow
extends Control

signal pet_selected(pet_id: String)

@onready var grid: GridContainer = $CenterContainer/Panel/VBox/ScrollContainer/Grid
@onready var close_button: Button = $CenterContainer/Panel/VBox/Header/CloseButton

# Preload pet button/item scene? We can generate buttons in code.

func _ready() -> void:
    if close_button:
        close_button.pressed.connect(queue_free)
    
    _populate_grid()

func _populate_grid() -> void:
    # Clear existing
    for child in grid.get_children():
        child.queue_free()
        
    # Get owned pets (using SaveManager or PetCollection)
    # Since we don't have global access to runtime PetCollection easily here unless passed,
    # we'll read from SaveManager for now, essentially reconstructing the list.
    var pets_data: Array = SaveManager.get_value("owned_pets", [])
    
    if pets_data.is_empty():
        # Add default pet if none
        _add_pet_button({"id": "default", "species_id": "cat", "nickname": "Kitty"})
        return
        
    for pet_dict in pets_data:
        _add_pet_button(pet_dict)

func _add_pet_button(pet_dict: Dictionary) -> void:
    var params := {
        "id": pet_dict.get("id", ""),
        "species": pet_dict.get("species_id", "cat"),
        "name": pet_dict.get("nickname", "Pet")
    }
    
    var btn := Button.new()
    btn.custom_minimum_size = Vector2(100, 100)
    btn.text = params.name
    btn.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
    btn.vertical_icon_alignment = VERTICAL_ALIGNMENT_TOP
    btn.expand_icon = true
    
    # Load icon
    var icon_path := "res://assets/sprites/pets/%s.png" % params.species
    if ResourceLoader.exists(icon_path):
        btn.icon = load(icon_path)
    
    btn.pressed.connect(_on_pet_btn_pressed.bind(params.id))
    grid.add_child(btn)

func _on_pet_btn_pressed(pet_id: String) -> void:
    pet_selected.emit(pet_id)
    queue_free()
