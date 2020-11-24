extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var hilight = $Background/Hilight
onready var progress = $Background/ProgressBar


func _ready():
	hilight.hide()
	progress.hide()
	globals.portraitUI = self

