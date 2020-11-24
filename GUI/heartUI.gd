extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var hilight = $Background/Hilight
onready var progress = $Background/ProgressBar

func _ready():
	hilight.hide()
	progress.hide()
	globals.heartUI = self

func reset():
	icon.set_scale(Vector2(1,1))
	hilight.hide()

func systole():
	icon.set_scale(Vector2(0.9, 0.9))
	hilight.show()

func diastole():
	icon.set_scale(Vector2(1,1))
	hilight.hide()
