extends Timer

signal sprint_fail	# sprinting is to be interrupted in a failed state
signal inspire		# player holding space; time counting up
signal expire		# player released space; time counting down

enum {
	IDLE,
	INSPIRE,
	EXPIRE,
	FAIL
}

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var input_pressed = false
onready var time = 0.0

const INITIAL_DURATION = 1.2				# heartbeat duration when sprint starts
onready var DURATION = INITIAL_DURATION		# heartbeat duration that shrinks over time


func _ready():
	set_one_shot(true)
	root.connect("interrupt", self, "force_fail")
	root.connect("input_breath_pressed", self, "breathing_start")
	root.connect("input_breath_released", self, "breathing_stop")

func force_fail():
	state = FAIL

func breathing_start():
	input_pressed = true

func breathing_stop():
	input_pressed = false

func _on_Breath_timeout():
	state = FAIL
	emit_signal("sprint_fail")


func _process(delta):
	time += delta
	match state:
		IDLE:
			idle_state()
		INSPIRE:
			inspire_state()
		EXPIRE:
			expire_state()
		FAIL:
			fail_state()

func idle_state():
	pass

func inspire_state():
	if get_time_left() < 0.4:
		state = REFRESH
		emit_signal("systole")
	elif input_received:
		input_received = false
		emit_signal("sprint_fail")
		state = FAIL


func expire_state():
	if input_received:
		input_received = false
		emit_signal("diastole")
		start(DURATION)
		state = SPRINT

func fail_state():
	root.set_SPEED(SPEED) # returns them to not-sprinting speed
	yield(root, "sprint_ready")
	state = IDLE
