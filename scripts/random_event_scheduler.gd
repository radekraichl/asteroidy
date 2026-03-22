# random_event_scheduler.gd
class_name RandomEventScheduler
extends Node

signal event_triggered(event_event_name: String)

class RandomEvent extends RefCounted:
	var event_name: String
	var min_interval: float
	var max_interval: float
	var callback: Callable
	var timer: Timer
	var enabled: bool = true

	func _init(p_event_name: String, p_min: float, p_max: float, p_callback: Callable) -> void:
		event_name = p_event_name
		min_interval = p_min
		max_interval = p_max
		callback = p_callback

var _events: Dictionary = {}

# Registers and starts a new random event
func add_event(event_name: String, min_interval: float, max_interval: float, callback: Callable, fire_immediately: bool = false) -> void:
	if _events.has(event_name):
		push_warning("RandomEventScheduler: event '%s' already exists." % event_name)
		return
	var event := RandomEvent.new(event_name, min_interval, max_interval, callback)
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

# Removes an event and frees its timer
func remove_event(event_name: String) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.timer.stop()
	event.timer.queue_free()
	_events.erase(event_name)

# Pauses or resumes a specific event
func set_enabled(event_name: String, enabled: bool) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.enabled = enabled
	if enabled:
		_schedule(event)
	else:
		event.timer.stop()

# Pauses or resumes all events
func set_all_enabled(enabled: bool) -> void:
	for key in _events:
		set_enabled(key, enabled)

# Changes the interval at runtime (takes effect on next cycle)
func set_interval(event_name: String, min_interval: float, max_interval: float) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.min_interval = min_interval
	event.max_interval = max_interval

# Forces immediate firing and reschedules
func trigger_now(event_name: String) -> void:
	if not _events.has(event_name):
		return
	var event: RandomEvent = _events[event_name]
	event.timer.stop()
	_fire(event)

func _schedule(event: RandomEvent) -> void:
	event.timer.start(randf_range(event.min_interval, event.max_interval))

func _fire(event: RandomEvent) -> void:
	event.callback.call()
	event_triggered.emit(event.event_name)
	if event.enabled:
		_schedule(event)

func _on_timer_timeout(event: RandomEvent) -> void:
	_fire(event)
