extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var hilight = $Background/Hilight
onready var progress = $Background/ProgressBar

onready var FILL_RATE = 45		# how much the bar fills per second
onready var EMPTY_RATE = 60		# how much is empties per second
onready var LEVEL = 0			# how full the bar is. Between 0 and 100

func _ready():
	hilight.hide()
	progress.show()
	globals.lungUI = self

func _process(_delta):
	LEVEL = progress.get_value()

func inspire(delta):
	progress.set_value(LEVEL + FILL_RATE * delta)

func expire(delta):
	progress.set_value(LEVEL - EMPTY_RATE * delta)
