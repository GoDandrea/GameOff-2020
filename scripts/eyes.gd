extends Node

signal downscale
signal refresh_scale

enum {
	IDLE,
	BLINKING,
	NOT_BLINKING,
	FAIL,
}

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var camera = root.get_node("Camera")

var current_scale = 2
var time_to_resolution_downscale = 0
var downscale_delay = 2


func _ready():
	root.connect("sprint_failed", self, "force_fail")
	root.connect("start_eyes", self, "_on_Plyer_blink_start")
	root.connect("input_blink_pressed", self, "do_blink")
	root.connect("input_blink_released", self, "undo_blink")


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
	emit_signal("refresh_scale")
	current_scale = 2
	state = FAIL


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
	emit_signal("refresh_scale")
	current_scale = 2


func not_blinking_state(delta):
	time_to_resolution_downscale += delta
	if time_to_resolution_downscale >= downscale_delay:
		time_to_resolution_downscale = 0
		current_scale += 1
		emit_signal("downscale", current_scale)


func fail_state():
	state = IDLE
