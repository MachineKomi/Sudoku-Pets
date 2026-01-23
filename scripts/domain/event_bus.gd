## EventBus - Central hub for domain event pub/sub
## Enables loose coupling between bounded contexts
extends Node

## Signal emitted for ALL events (listeners filter by type)
signal event_emitted(event: DomainEvent)

## Type-specific signals for common events
signal number_placed(event: DomainEvent)
signal mistake_made(event: DomainEvent)
signal puzzle_solved(event: DomainEvent)
signal currency_earned(event: DomainEvent)
signal pet_acquired(event: DomainEvent)
signal pet_leveled_up(event: DomainEvent)
signal level_completed(event: DomainEvent)

## Event history for debugging (limited size)
var _event_history: Array[DomainEvent] = []
const MAX_HISTORY := 100


## Publish an event to all subscribers
func emit_event(event: DomainEvent) -> void:
	# Add to history
	_event_history.append(event)
	if _event_history.size() > MAX_HISTORY:
		_event_history.pop_front()
	
	# Emit generic signal
	event_emitted.emit(event)
	
	# Emit type-specific signal
	match event.event_type:
		"NumberPlaced":
			number_placed.emit(event)
		"MistakeMade":
			mistake_made.emit(event)
		"PuzzleSolved":
			puzzle_solved.emit(event)
		"CurrencyEarned":
			currency_earned.emit(event)
		"PetAcquired":
			pet_acquired.emit(event)
		"PetLeveledUp":
			pet_leveled_up.emit(event)
		"LevelCompleted":
			level_completed.emit(event)
	
	# Debug logging
	if OS.is_debug_build():
		print("[EventBus] %s: %s" % [event.event_type, event.to_dict()])


## Get recent events (for debugging)
func get_recent_events(count: int = 10) -> Array[DomainEvent]:
	var start := maxi(0, _event_history.size() - count)
	return _event_history.slice(start)


## Clear event history
func clear_history() -> void:
	_event_history.clear()
