extends Node

signal sprint_failed	# sprinting is to be interrupted in a failed state

enum {
	IDLE,
	BALANCING,
	FAIL,
}

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var camera = root.get_node("Camera")
onready var width = get_viewport().get_size().x			# screen width

# How much the character is tilting (in degrees). 0 is perpendicular to floor
# Is meant to be between -18 and +18
onready var current_tilt = 0 setget set_tilt

var mouse_drag
var mouse_pos
var relative_x		# mouse x value relative to the screen width


func _ready():
	randomize()
	root.connect("start_brain", self, "_on_Player_balance_start")
	root.connect("sprint_failed", self, "force_fail")



func _process(_delta):
	
	if current_tilt > 18 or current_tilt < -18:
		emit_signal("sprint_failed")


func _physics_process(_delta):
	
	mouse_pos = get_viewport().get_mouse_position()
	match state:
		IDLE:
			idle_state()
		BALANCING:
			balancing_state()
		FAIL:
			fail_state()


func idle_state():
	pass


func balancing_state():
	
	var screen_width = get_viewport().get_size().x
	var viewport_scale = globals.viewport_container.get_stretch_shrink()
	var screen_center = (screen_width * viewport_scale) / 2 
	
	relative_x = (mouse_pos.x - screen_center)
	add_tilt(relative_x/2048 * viewport_scale * 1.5)

	globals.brainUI.set_pointer(current_tilt * 5)
	get_viewport().warp_mouse(mouse_pos + Vector2(relative_x/32, 0))


func fail_state():
	
	globals.brainUI.reset()
	set_tilt(0)
	globals.viewport_container.set_stretch_shrink(2)
	state = IDLE


func _on_Player_balance_start():
	
	var screen_width = get_viewport().get_size().x
	var viewport_scale = globals.viewport_container.get_stretch_shrink()
	var screen_center = (screen_width * viewport_scale) / 2 
	
	if (randi() & 1) == 0:
		get_viewport().warp_mouse(Vector2(screen_center + 64, 0))
	else:
		get_viewport().warp_mouse(Vector2(screen_center - 64, 0))
	
	globals.brainUI.show_gauge()
	state = BALANCING


func force_fail():
	state = FAIL


func add_tilt(tilt):
	set_tilt(current_tilt + tilt)


func set_tilt(tilt):
	current_tilt = tilt
	camera.set_rotation_degrees(Vector3(0, 0, current_tilt))
