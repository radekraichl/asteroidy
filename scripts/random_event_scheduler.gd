# random_event_scheduler.gd
class_name RandomEventScheduler
extends Node

signal event_triggered(event_name: String)

class RandomEvent extends RefCounted:
	var event_name: String
	var min_interval: float
	var max_interval: float
	var callback: Callable
	var timer: Timer
	var enabled: bool = true
	var max_count: int = -1
	var fire_count: int = 0
	func _init(p_event_name: String, p_min: float, p_max: float, p_callback: Callable, p_max_count: int = -1) -> void:
		event_name = p_event_name
		min_interval = p_min
		max_interval = p_max
		callback = p_callback
		max_count = p_max_count

var _events: Dictionary = {}

## Returns true if an event with the given name exists.
func has_event(event_name: String) -> bool:
	return _events.has(event_name)

## Registers and starts a new random event.
func add_event(event_name: String, callback: Callable, min_interval: float, max_interval: float, fire_immediately: bool = false, max_count: int = -1) -> void:
	if _events.has(event_name):
		push_warning("RandomEventScheduler: event '%s' already exists." % event_name)
		return
	var event := RandomEvent.new(event_name, min_interval, max_interval, callback, max_count)
	var timer := Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_timer_timeout.bind(event))
	timer.name = event_name
	add_child(timer)
	event.timer = timer
	_events[event_name] = event
	if fire_immediately:
		_fire(event)
	else:
		_schedule(event)

## Removes an event and frees its timer.
func remove_event(event_name: String) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.timer.stop()
	event.timer.queue_free()
	_events.erase(event_name)

## Pauses or resumes a specific event.
func set_enabled(event_name: String, enabled: bool) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.enabled = enabled
	if enabled:
		_schedule(event)
	else:
		event.timer.stop()

## Pauses or resumes all events.
func set_all_enabled(enabled: bool) -> void:
	for key in _events:
		set_enabled(key, enabled)

## Changes the interval, optionally resets fire_count and restarts the event.
func set_interval(event_name: String, min_interval: float, max_interval: float, fire_immediately: bool = false, max_count: int = -1) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.min_interval = min_interval
	event.max_interval = max_interval
	event.max_count = max_count
	event.fire_count = 0
	event.enabled = true
	event.timer.stop()
	if fire_immediately:
		_fire(event)
	else:
		_schedule(event)

## Forces immediate firing and reschedules the event.
func trigger_now(event_name: String) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.timer.stop()
	_fire(event)

func _schedule(event: RandomEvent) -> void:
	event.timer.start(randf_range(event.min_interval, event.max_interval))

func _fire(event: RandomEvent) -> void:
	event.fire_count += 1
	event.callback.call()
	event_triggered.emit(event.event_name)
	if event.enabled:
		if event.max_count != -1 and event.fire_count >= event.max_count:
			event.enabled = false
			event.timer.stop()
		else:
			_schedule(event)

func _on_timer_timeout(event: RandomEvent) -> void:
	_fire(event)
