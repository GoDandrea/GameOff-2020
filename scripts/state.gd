# Base interface for all states
extends Node

signal finished(next_state_name)

# Initialize the state
func enter():
	return

# Clean up the state. Reinitialize values like a timer
func exit():
	return

func handle_input(event):
	return

func update(delta):
	return

func _on_animation_finished(anim_name):
	return
