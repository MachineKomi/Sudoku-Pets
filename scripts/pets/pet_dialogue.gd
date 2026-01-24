## PetDialogue - Dialogue pools for pet companions based on personality
class_name PetDialogue
extends RefCounted


## Dialogue categories
enum Category {
	GREETING,
	ENCOURAGEMENT,
	CORRECT_MOVE,
	WRONG_MOVE,
	HINT,
	LINE_COMPLETE,
	PUZZLE_COMPLETE,
	IDLE,
	FED,
}

## Dialogue pools by personality type
const DIALOGUE_POOLS: Dictionary = {
	# CHEERFUL personality
	PetPersonality.PersonalityType.CHEERFUL: {
		Category.GREETING: [
			"Hi there, friend! 🌟",
			"Yay, puzzle time!",
			"Let's have fun today!",
			"So happy to see you! 💕",
		],
		Category.ENCOURAGEMENT: [
			"You've got this!",
			"Keep going, you're amazing!",
			"I believe in you! ✨",
			"You're doing great!",
		],
		Category.CORRECT_MOVE: [
			"Woohoo! Nice one!",
			"That's the spirit!",
			"Brilliant move! 🎉",
			"You're on fire!",
		],
		Category.WRONG_MOVE: [
			"Oops! That's okay!",
			"No worries, try again!",
			"We all make mistakes! 💪",
			"You'll get it next time!",
		],
		Category.LINE_COMPLETE: [
			"Amazing!! A whole line! 🌈",
			"You did it! So proud!",
			"Look at you go!",
			"Incredible work!",
		],
		Category.PUZZLE_COMPLETE: [
			"WE DID IT! 🎊🎉",
			"You're a puzzle master!",
			"That was beautiful! 💖",
			"Victory dance time!",
		],
		Category.IDLE: [
			"*bounces excitedly*",
			"La la la~ 🎵",
			"What a lovely day!",
			"I love puzzles!",
		],
		Category.FED: [
			"Yummy! Thank you! 🍰",
			"Nom nom nom!",
			"This is delicious!",
			"You're the best!",
		],
	},
	
	# SHY personality
	PetPersonality.PersonalityType.SHY: {
		Category.GREETING: [
			"H-hello... 👉👈",
			"Oh, hi there...",
			"*waves shyly*",
			"Nice to see you...",
		],
		Category.ENCOURAGEMENT: [
			"You can do it...",
			"I believe in you... 🌸",
			"Take your time...",
			"No rush... you've got this",
		],
		Category.CORRECT_MOVE: [
			"Y-yay! Good job!",
			"That was really good...",
			"*happy squeak*",
			"So smart... 💫",
		],
		Category.WRONG_MOVE: [
			"It's okay... really...",
			"Don't worry... 🍀",
			"Mistakes are okay...",
			"Try again... I'm here...",
		],
		Category.LINE_COMPLETE: [
			"W-wow! Amazing!",
			"You're so talented...",
			"*happy wiggle*",
			"That was incredible...",
		],
		Category.PUZZLE_COMPLETE: [
			"You... you did it! 🌟",
			"So amazing... wow...",
			"*happy tears*",
			"I knew you could...",
		],
		Category.IDLE: [
			"*quietly watches*",
			"...",
			"💭",
			"*soft humming*",
		],
		Category.FED: [
			"Th-thank you... 🥺",
			"So kind of you...",
			"*nibbles happily*",
			"Delicious...",
		],
	},
	
	# SASSY personality
	PetPersonality.PersonalityType.SASSY: {
		Category.GREETING: [
			"Finally, you're here! 💅",
			"About time!",
			"Ready to impress me?",
			"Let's see what you've got!",
		],
		Category.ENCOURAGEMENT: [
			"Come on, show me!",
			"I know you can do better~",
			"Don't disappoint me! 😼",
			"Let's go, champ!",
		],
		Category.CORRECT_MOVE: [
			"Not bad, not bad!",
			"Okay, I'm impressed! 😸",
			"That's what I'm talking about!",
			"Finally, some skill!",
		],
		Category.WRONG_MOVE: [
			"Hmph, try again!",
			"Was that on purpose? 🙄",
			"I expected more...",
			"You can do better!",
		],
		Category.LINE_COMPLETE: [
			"Now THAT'S more like it! 👏",
			"Okay okay, impressive!",
			"See? You CAN do it!",
			"About time! Great job!",
		],
		Category.PUZZLE_COMPLETE: [
			"YES! That's my human! 🏆",
			"I never doubted you... much!",
			"Perfection! As expected!",
			"We make a great team! 😼",
		],
		Category.IDLE: [
			"*files claws*",
			"Waiting... 💅",
			"Any day now...",
			"*dramatic sigh*",
		],
		Category.FED: [
			"Finally, proper tribute! 👑",
			"Acceptable offering!",
			"Mmm, not bad!",
			"You DO care! 💝",
		],
	},
	
	# WISE personality
	PetPersonality.PersonalityType.WISE: {
		Category.GREETING: [
			"Greetings, young one 🦉",
			"Ah, a new puzzle awaits",
			"The journey begins anew",
			"Welcome, seeker of patterns",
		],
		Category.ENCOURAGEMENT: [
			"Patience reveals all paths",
			"Trust your intuition",
			"The answer lies within 🌙",
			"Logic is your ally",
		],
		Category.CORRECT_MOVE: [
			"Wisdom guides your hand",
			"Indeed, well reasoned",
			"A fine deduction ✨",
			"Your mind grows sharper",
		],
		Category.WRONG_MOVE: [
			"Every error teaches",
			"Reflect, then try again",
			"The wise learn from mistakes",
			"A lesson, not a failure 📚",
		],
		Category.LINE_COMPLETE: [
			"Excellence achieved 🏛️",
			"Your mastery grows",
			"A testament to skill",
			"Truly enlightened!",
		],
		Category.PUZZLE_COMPLETE: [
			"Magnificent! 🎓",
			"You have proven worthy",
			"A master puzzler indeed",
			"The stars celebrate! ⭐",
		],
		Category.IDLE: [
			"*contemplates deeply*",
			"Hmm... 🤔",
			"*strokes chin*",
			"Interesting patterns...",
		],
		Category.FED: [
			"Most generous 🙏",
			"Sustenance for thought",
			"My thanks, young one",
			"A kind offering",
		],
	},
	
	# ENERGETIC personality
	PetPersonality.PersonalityType.ENERGETIC: {
		Category.GREETING: [
			"LET'S GOOO!! 🚀",
			"PUZZLE TIME WOOOO!",
			"I'M SO EXCITED!!",
			"READY SET GO!!",
		],
		Category.ENCOURAGEMENT: [
			"YOU CAN DO THIS!!",
			"GO GO GO!! 💪",
			"NEVER GIVE UP!!",
			"FULL POWER!!",
		],
		Category.CORRECT_MOVE: [
			"YEEEES!! 🎯",
			"BOOM! NAILED IT!",
			"UNSTOPPABLE!!",
			"THAT'S THE STUFF!!",
		],
		Category.WRONG_MOVE: [
			"NO PROBLEM!!",
			"SHAKE IT OFF!! 💥",
			"NEXT ONE!!",
			"KEEP THAT ENERGY!!",
		],
		Category.LINE_COMPLETE: [
			"ABSOLUTELY INCREDIBLE!! 🌟",
			"CHAMPION MOVES!!",
			"LEGENDARY!!",
			"MAXIMUM POWER!!",
		],
		Category.PUZZLE_COMPLETE: [
			"VICTORY SCREECH!! 🎉🎊",
			"WE ARE THE CHAMPIONS!!",
			"UNBEATABLE!!",
			"WORLD RECORD!! 🏆",
		],
		Category.IDLE: [
			"*zooms around*",
			"CAN'T STOP WON'T STOP!",
			"⚡⚡⚡",
			"*parkour noises*",
		],
		Category.FED: [
			"FUEL FOR VICTORY!! 🍖",
			"POWER UP!!",
			"YUMMY ENERGY!!",
			"MAX POWER BOOST!!",
		],
	},
	
	# DREAMY personality
	PetPersonality.PersonalityType.DREAMY: {
		Category.GREETING: [
			"Oh... hello there ☁️",
			"*floats in*",
			"What a magical day...",
			"The stars brought us together~",
		],
		Category.ENCOURAGEMENT: [
			"Follow the sparkles... ✨",
			"Let your mind wander...",
			"The answer drifts near...",
			"Dream the solution... 🌌",
		],
		Category.CORRECT_MOVE: [
			"Like stardust falling... ⭐",
			"Beautiful...",
			"The cosmos approve~",
			"Magic in motion...",
		],
		Category.WRONG_MOVE: [
			"A cloud passes by...",
			"The mist confused you... 🌫️",
			"Stars realign...",
			"Dream again...",
		],
		Category.LINE_COMPLETE: [
			"A constellation forms! 🌠",
			"Galaxy bright...",
			"Ethereal beauty...",
			"The moon smiles... 🌙",
		],
		Category.PUZZLE_COMPLETE: [
			"A universe complete... ✨🌌",
			"Truly magical...",
			"Written in the stars...",
			"Dreams do come true... 💫",
		],
		Category.IDLE: [
			"*daydreams*",
			"☁️💭✨",
			"*stargazing*",
			"So many possibilities...",
		],
		Category.FED: [
			"Mmm... moonbeam flavor~ 🌙",
			"Ethereal deliciousness...",
			"Like eating a cloud...",
			"Thank you, dear friend~",
		],
	},
}

## Get a random dialogue for a species and category
static func get_dialogue(species_id: String, category: Category) -> String:
	var personality: PetPersonality.PersonalityType = PetPersonality.get_personality(species_id)
	
	var pool: Dictionary = DIALOGUE_POOLS.get(personality, {})
	var messages: Array = pool.get(category, ["..."])
	
	return messages[randi() % messages.size()]

## Get greeting dialogue
static func get_greeting(species_id: String) -> String:
	return get_dialogue(species_id, Category.GREETING)

## Get encouragement dialogue
static func get_encouragement(species_id: String) -> String:
	return get_dialogue(species_id, Category.ENCOURAGEMENT)

## Get correct move dialogue
static func get_correct_move(species_id: String) -> String:
	return get_dialogue(species_id, Category.CORRECT_MOVE)

## Get wrong move dialogue
static func get_wrong_move(species_id: String) -> String:
	return get_dialogue(species_id, Category.WRONG_MOVE)

## Get line complete dialogue
static func get_line_complete(species_id: String) -> String:
	return get_dialogue(species_id, Category.LINE_COMPLETE)

## Get puzzle complete dialogue
static func get_puzzle_complete(species_id: String) -> String:
	return get_dialogue(species_id, Category.PUZZLE_COMPLETE)

## Get fed dialogue
static func get_fed(species_id: String) -> String:
	return get_dialogue(species_id, Category.FED)

## Get idle dialogue
static func get_idle(species_id: String) -> String:
	return get_dialogue(species_id, Category.IDLE)
