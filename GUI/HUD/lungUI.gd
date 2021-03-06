extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var hilight = $Background/Hilight
onready var progress = $Background/ProgressBar
onready var space_icon = get_parent().get_parent().get_node("HBoxContainer2/Control3/space")

onready var FILL_RATE = 45		# how much the bar fills per second
onready var EMPTY_RATE = 60		# how much is empties per second
onready var LEVEL = 99			# how full the bar is. Between 0 and 100; default 99
onready var SIZE = Vector2(1,1)	# current size of the lungs icon

func _ready():
	hilight.hide()
	progress.hide()
	globals.lungUI = self

func _process(_delta):
	LEVEL = progress.get_value()
	icon.set_scale(Vector2(1, 0.8 + LEVEL/500))
	if LEVEL == 0 or LEVEL == 100:
		globals.player.abort_sprint("breath")

func inspire(delta):
	progress.set_value(LEVEL + FILL_RATE * delta)

func expire(delta):
	progress.set_value(LEVEL - EMPTY_RATE * delta)
