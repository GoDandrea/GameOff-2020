extends Node

enum {
	IDLE,
	BLINKING,
	NOT_BLINKING,
	FAIL,
}

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var camera = root.get_node("Camera")
onready var viewport = get_viewport()
onready var viewport_container = viewport.get_parent()

var DEFAULT_SCALE = 2
var current_scale = 2
var time_to_resolution_downscale = 0
var downscale_delay = 1


func _ready():
	
	root.connect("sprint_failed", self, "force_fail")
	root.connect("start_eyes", self, "_on_Player_blink_start")
	root.connect("input_blink_pressed", self, "do_blink")
	root.connect("input_blink_released", self, "undo_blink")
	root.connect("sprint_ready", self, "_on_sprint_ready")


func _on_Player_blink_start():
	if state == IDLE:
		state = NOT_BLINKING


func do_blink():
	if state == NOT_BLINKING:
		state = BLINKING


func undo_blink():
	if state == BLINKING:
		state = NOT_BLINKING


func force_fail():
	state = FAIL
	viewport_container.set_stretch_shrink(DEFAULT_SCALE)
	current_scale = DEFAULT_SCALE


func _process(delta):
	
	match state:
		IDLE:
			idle_state()
		BLINKING:
			blinking_state()
		NOT_BLINKING:
			not_blinking_state(delta)
		FAIL:
			fail_state()


func idle_state():
	pass


func blinking_state():
	viewport_container.set_stretch_shrink(DEFAULT_SCALE)
	current_scale = DEFAULT_SCALE


func not_blinking_state(delta):
	time_to_resolution_downscale += delta
	if time_to_resolution_downscale >= downscale_delay:
		time_to_resolution_downscale = 0
		current_scale += 1
		viewport_container.set_stretch_shrink(current_scale)


func fail_state():
	pass


func _on_sprint_ready():
	if state == FAIL:
		state = IDLE
