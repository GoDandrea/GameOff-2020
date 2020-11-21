extends Node

func _ready():
	randomize()

# gets either a name or nothing
func play(sound = null):
	
	# if it gets a name, it will play the AudioStream or Library with that name 
	if sound:
		get_node(sound).play()
	
	# if it gets nothing, it will play a sound at random
	else:
		var c = randi() % get_child_count()
		get_child(c).play()
