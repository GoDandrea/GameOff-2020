extends Control

const MOON_LEVEL = "res://levels/Moon.tscn"

func _ready():
	for button in $ColorRect/Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.on_press_command])


func _on_Button_pressed(button_command):
	
	match button_command:
		"new game":
			transition_to(MOON_LEVEL)
		"continue":
			transition_to(MOON_LEVEL)
		"options":
			continue
		"quit":
			get_tree().quit()


func transition_to(target_scene):
	$ColorRect/AnimationPlayer.play("transition_to_game")
	yield($ColorRect/AnimationPlayer, "animation_finished")
	get_tree().change_scene(target_scene)
