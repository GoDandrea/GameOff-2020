extends Node

signal sprint_fail	# sprinting is to be interrupted in a failed state

enum {
	IDLE,
	LEFT,
	RIGHT,
	FAIL
}

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var camera = root.get_node("Camera")
onready var width = get_viewport().get_size().x			# screen width

# How much the character is tilting (in degrees). 0 is perpendicular to floor
# Is meant to be between -22 and +22
onready var tilt = 0

var mouse_drag
var mouse_pos
var relative_x		# mouse x value relative to the screen width
var x
var y

func _ready():
	randomize()
	root.connect("interrupt", self, "force_fail")
#	root.connect("lean_left", self, "leaning_left")
#	root.connect("lean_right", self, "leaning_right")

func force_fail():
	state = FAIL

func tilt_camera():
	camera.set_rotation_degrees(Vector3(0, 0, tilt))


func _process():
	
	if tilt > 22 or tilt < -22:
		force_fail()
	
	mouse_pos = get_viewport().get_mouse_position()
	if state == LEFT or state == RIGHT:
		if tilt < 0:
			state = LEFT
		else:
			state = RIGHT
		x = randf()
		y = randf()
		x *= x
		y *= y
		mouse_drag = Vector2(x, y) * 10
	
	match state:
		IDLE:
			idle_state()
		LEFT:
			left_state()
		RIGHT:
			right_state()
		FAIL:
			fail_state()

func idle_state():
	pass

func left_state():
	relative_x = 2 * mouse_pos.x - width
	relative_x /= width * 8
	mouse_drag += Vector2(relative_x, 0)
	tilt += relative_x
	globals.brainUI.set_pointer(tilt * 4)
	tilt_camera()
	get_viewport().warp_mouse(mouse_pos + mouse_drag - Vector2(1, 0))

func right_state():
	relative_x = 2 * mouse_pos.x - width
	relative_x /= width * 8
	mouse_drag += Vector2(relative_x, 0)
	tilt += relative_x
	globals.brainUI.set_pointer(tilt * 4)
	tilt_camera()
	get_viewport().warp_mouse(mouse_pos + mouse_drag + Vector2(1, 0))

func fail_state():
	globals.brainUI.reset()
	tilt = 0
	tilt_camera()
	yield(root, "sprint_ready")
	state = IDLE

func _on_Player_balance_start():
	globals.brainUI.show_gauge()
	if randf() > 0.5:
		state = RIGHT
	else:
		state = LEFT
