## PetPersonality - Defines personality types and traits for pets
class_name PetPersonality
extends RefCounted


## Available personality types
enum PersonalityType {
	CHEERFUL,    # Upbeat, encouraging
	SHY,         # Quiet, gentle encouragement
	SASSY,       # Playful teasing, confident
	WISE,        # Thoughtful, philosophical
	ENERGETIC,   # Excited, lots of exclamations
	DREAMY,      # Whimsical, imaginative
}

## Available traits (each pet can have multiple)
enum Trait {
	CURIOUS,
	PLAYFUL,
	SUPPORTIVE,
	HUNGRY,
	SLEEPY,
	ADVENTUROUS,
	BOOKWORM,
	FOODIE,
	STARGAZER,
	NATURE_LOVER,
}

## Species to personality mapping
const SPECIES_PERSONALITIES: Dictionary = {
	"cat": PersonalityType.SASSY,
	"bunny": PersonalityType.SHY,
	"owl": PersonalityType.WISE,
	"fox": PersonalityType.ENERGETIC,
	"dragon": PersonalityType.DREAMY,
	"whisker_cat": PersonalityType.CHEERFUL,
	"hoot_owl": PersonalityType.WISE,
	"fluffy_bunny": PersonalityType.SHY,
	"gobbo": PersonalityType.ENERGETIC,
	"sparkle_fish": PersonalityType.DREAMY,
	"moon_moth": PersonalityType.DREAMY,
	"sparkle_fox": PersonalityType.SASSY,
	"crystal_deer": PersonalityType.SHY,
	"rainbow_bird": PersonalityType.CHEERFUL,
	"fluffdragon": PersonalityType.DREAMY,
	"thunder_lion": PersonalityType.ENERGETIC,
	"ice_phoenix": PersonalityType.WISE,
	"starlight_kirin": PersonalityType.WISE,
	"galaxy_whale": PersonalityType.DREAMY,
	"dream_phoenix": PersonalityType.DREAMY,
}

## Species to traits mapping (array of Trait enums)
const SPECIES_TRAITS: Dictionary = {
	"cat": [Trait.CURIOUS, Trait.PLAYFUL, Trait.ADVENTUROUS],
	"bunny": [Trait.SUPPORTIVE, Trait.NATURE_LOVER, Trait.SLEEPY],
	"owl": [Trait.BOOKWORM, Trait.CURIOUS, Trait.STARGAZER],
	"fox": [Trait.ADVENTUROUS, Trait.PLAYFUL, Trait.CURIOUS],
	"dragon": [Trait.FOODIE, Trait.ADVENTUROUS, Trait.STARGAZER],
}


## Get personality for a species
static func get_personality(species_id: String) -> PersonalityType:
	return SPECIES_PERSONALITIES.get(species_id, PersonalityType.CHEERFUL)

## Get traits for a species
static func get_traits(species_id: String) -> Array:
	return SPECIES_TRAITS.get(species_id, [Trait.SUPPORTIVE, Trait.PLAYFUL])
