extends Control


func _ready():
	for button in $ColorRect/Buttons.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.scene_to_load])


func _on_Button_pressed(target_scene):
	
	match target_scene:
		"options":
			continue
		"quit":
			get_tree().quit()
		_:
			transition_to(target_scene)


func transition_to(target_scene):
	$ColorRect/AnimationPlayer.play("transition_to_game")
	yield($ColorRect/AnimationPlayer, "animation_finished")
	get_tree().change_scene(target_scene)
