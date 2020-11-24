extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var hilight = $Background/CenterContainer/ColorRect

func _ready():
	hilight.hide()
	globals.heartUI = self

func reset():
	icon.set_scale(Vector2(1,1))
	#hilight.hide()

func systole():
	icon.set_scale(Vector2(1.1, 1.1))
	#hilight.show()

func diastole():
	icon.set_scale(Vector2(1,1))
	#hilight.hide()
