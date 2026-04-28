class_name BaseState
extends Node

var state_machine: StateMachine
var actor: Node

func enter(_msg: Dictionary = {}) -> void:
	pass

func exit() -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float) -> void:
	pass

func input(_event: InputEvent) -> void:
	pass

func unhandled_input(_event: InputEvent) -> void:
	pass

func unhandled_key_input(_event: InputEvent) -> void:
	pass

func change_state(state_script: GDScript, msg: Dictionary = {}) -> void:
	state_machine.change_state(state_script, msg)
