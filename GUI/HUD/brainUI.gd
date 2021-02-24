extends MarginContainer

onready var icon = $Background/CenterContainer/Icon
onready var gauge = $Background/Gauge
onready var pointer = $Background/Pointer
onready var mouse_pos_icon = get_parent().get_parent().get_node("HBoxContainer2/Control4/mouse_pos")

onready var pointer_angle = 0	# pointer angle in degrees


func _ready():
	gauge.hide()
	pointer.hide()
	globals.brainUI = self


func reset():
	icon.set_rotation(0)
	icon.show()
	gauge.set_rotation(0)
	pointer.set_rotation(0)
	mouse_pos_icon.hide()
	gauge.hide()
	pointer.hide()

func show_gauge():
	icon.hide()
	mouse_pos_icon.show()
	gauge.show()
	pointer.show()

func set_pointer(value):
	pointer.set_rotation(deg2rad(value))
