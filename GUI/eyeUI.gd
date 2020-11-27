extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var anim = $AnimationPlayer
onready var upper_eyelid = $Background/UpperEyelid
onready var lower_eyelid = $Background/LowerEyelid


func _ready():
	globals.eyeUI = self

func _process(_delta):
	pass

func close_eye():
	anim.play("close")

func open_eye():
	anim.play("open")

func set_closed():
	upper_eyelid.set_value(100)
	lower_eyelid.set_value(100)

func set_open():
	upper_eyelid.set_value(0)
	lower_eyelid.set_value(0)
