## Base class for all domain events
## Events are immutable data containers that describe something that happened
class_name DomainEvent
extends RefCounted


## Unique identifier for this event instance
var event_id: String = ""

## When this event occurred (Unix timestamp)
var timestamp: float = 0.0

## Type of event for filtering/routing
var event_type: String = ""


func _init(type: String = "") -> void:
	event_id = _generate_id()
	timestamp = Time.get_unix_time_from_system()
	event_type = type


## Generate a simple unique ID
func _generate_id() -> String:
	return str(randi()) + "_" + str(Time.get_ticks_msec())


## Override in subclasses to provide event data as dictionary
func to_dict() -> Dictionary:
	return {
		"event_id": event_id,
		"timestamp": timestamp,
		"event_type": event_type
	}
