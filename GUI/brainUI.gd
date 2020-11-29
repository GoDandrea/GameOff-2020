extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var gauge = $Background/Gauge
onready var pointer = $Background/Pointer

onready var pointer_angle = 0	# pointer angle in degrees


func _ready():
	gauge.hide()
	pointer.hide()
	globals.brainUI = self
	

func _process(_delta):
	
	if pointer_angle >= 90 or pointer_angle <= -90:
		pass
		# reset()
	


func reset():
	icon.set_rotation(0)
	icon.show()
	gauge.set_rotation(0)
	pointer.set_rotation(0)
	gauge.hide()
	pointer.hide()

func show_gauge():
	icon.hide()
	gauge.show()
	pointer.show()

func set_pointer(value):
	pointer.set_rotation(deg2rad(value))
