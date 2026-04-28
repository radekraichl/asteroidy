class_name StateMachine
extends Node

@export var initial_state: BaseState
var current_state: BaseState
var states: Dictionary[GDScript, BaseState] = {}

func _ready() -> void:
	for child in get_children():
		if child is BaseState:
			states[child.get_script()] = child
			child.state_machine = self
			child.actor = get_parent()
	if initial_state:
		transition_to(initial_state.get_script())

func _process(delta: float) -> void:
	if current_state:
		current_state.state_process(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_physics_process(delta)

func _input(event: InputEvent) -> void:
	if current_state:
		current_state.input(event)

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.unhandled_input(event)

func _unhandled_key_input(event: InputEvent) -> void:
	if current_state:
		current_state.unhandled_key_input(event)

func transition_to(state_script: GDScript, msg: Dictionary = {}) -> void:
	if not states.has(state_script):
		push_error("StateMachine: state not found: %s" % state_script.resource_path)
		return
	if current_state:
		current_state.exit()
	current_state = states[state_script]
	current_state.enter(msg)
