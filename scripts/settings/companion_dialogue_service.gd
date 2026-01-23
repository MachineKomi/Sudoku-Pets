## CompanionDialogueService - Provides encouraging, kid-friendly dialogue
## The cat girl companion reacts to game events!
class_name CompanionDialogueService
extends RefCounted


## Dialogue lines by event type and emotion
const DIALOGUE := {
	"number_placed_correct": [
		{"text": "Great job! You're so smart!", "emotion": "happy"},
		{"text": "Yay! That's right!", "emotion": "excited"},
		{"text": "You're doing amazing!", "emotion": "proud"},
		{"text": "Wow! Keep going!", "emotion": "happy"},
	],
	"mistake_made": [
		{"text": "Oops! That's okay, try again!", "emotion": "encouraging"},
		{"text": "Almost! You can do it!", "emotion": "supportive"},
		{"text": "Don't worry, mistakes help us learn!", "emotion": "kind"},
		{"text": "Hmm, let's try another number!", "emotion": "thoughtful"},
	],
	"puzzle_solved": [
		{"text": "WOW! You did it! Amazing!", "emotion": "ecstatic"},
		{"text": "INCREDIBLE! You're a Sudoku star!", "emotion": "excited"},
		{"text": "You solved it! I knew you could!", "emotion": "proud"},
		{"text": "HOORAY! You're the best!", "emotion": "celebrating"},
	],
	"hint_used": [
		{"text": "Here's a little help, friend!", "emotion": "helpful"},
		{"text": "Let me show you something!", "emotion": "curious"},
		{"text": "Look at this spot!", "emotion": "pointing"},
	],
	"pet_evolved": [
		{"text": "Look at your pet! So cool!", "emotion": "amazed"},
		{"text": "Wow! Your pet evolved!", "emotion": "excited"},
		{"text": "Amazing transformation!", "emotion": "proud"},
	],
	"pet_acquired": [
		{"text": "A new friend! How exciting!", "emotion": "happy"},
		{"text": "Welcome to the family!", "emotion": "joyful"},
		{"text": "So cute! I love them!", "emotion": "adoring"},
	],
	"idle": [
		{"text": "I believe in you! Take your time~", "emotion": "patient"},
		{"text": "You've got this!", "emotion": "encouraging"},
		{"text": "No rush, puzzles are fun!", "emotion": "relaxed"},
		{"text": "I'm here cheering for you!", "emotion": "supportive"},
	],
	"welcome": [
		{"text": "Welcome back! Ready to play?", "emotion": "happy"},
		{"text": "Yay! You're here! Let's have fun!", "emotion": "excited"},
		{"text": "Hi! I missed you!", "emotion": "warm"},
	]
}


## Get a random dialogue for an event
func get_dialogue(event_type: String) -> Dictionary:
	var lines: Array = DIALOGUE.get(event_type, DIALOGUE["idle"])
	return lines[randi() % lines.size()]


## Get dialogue text
func get_dialogue_text(event_type: String) -> String:
	return get_dialogue(event_type).get("text", "")


## Get dialogue emotion
func get_dialogue_emotion(event_type: String) -> String:
	return get_dialogue(event_type).get("emotion", "happy")


## React to a domain event
func react_to_event(event: DomainEvent) -> Dictionary:
	match event.event_type:
		"NumberPlaced":
			var placed_event: NumberPlacedEvent = event as NumberPlacedEvent
			if placed_event and placed_event.is_correct:
				return get_dialogue("number_placed_correct")
			else:
				return get_dialogue("mistake_made")
		"PuzzleSolved":
			return get_dialogue("puzzle_solved")
		"PetAcquired":
			return get_dialogue("pet_acquired")
		"PetLeveledUp":
			var level_event: PetLeveledUpEvent = event as PetLeveledUpEvent
			if level_event and level_event.evolved:
				return get_dialogue("pet_evolved")
			return {}
	
	return {}
