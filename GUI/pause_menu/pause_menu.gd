extends Control


func _ready():
	for button in $CenterContainer/VBoxContainer.get_children():
		button.connect("pressed", self, "_on_Button_pressed", [button.on_press_command])


func _input(event):
	if event.is_action_pressed("pause"):
		var new_pause_state = not get_tree().paused
		get_tree().paused = new_pause_state
		visible = new_pause_state


func _on_Button_pressed(button_command):
	
	match button_command:
		"resume":
			get_tree().paused = false
			visible = false
		"options":
			print("Options")
		"quit":
			get_tree().quit()

