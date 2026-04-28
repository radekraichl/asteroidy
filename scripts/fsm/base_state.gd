class_name BaseState
extends Node

var state_machine: StateMachine
var actor: Node

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func state_process(_delta: float) -> void:
	pass

func state_physics_process(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func unhandled_input(_event: InputEvent) -> void:
	pass

func unhandled_key_input(_event: InputEvent) -> void:
	pass

func transition_to(state_script: GDScript, msg: Dictionary = {}) -> void:
	state_machine.transition_to(state_script, msg)
