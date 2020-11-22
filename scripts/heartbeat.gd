extends Timer

signal sprint_fail	# sprinting is to be interrupted in a failed state
signal systole		# heart contracts; waiting player to press shift
signal diastole		# player pressed shift; heart relaxes

enum {
	IDLE,
	SPRINT,
	REFRESH,
	FAIL
}

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var input_received = false
onready var SPEED = root.get_SPEED()
onready var SPRINT_MOD = root.get_SPRINT()
onready var ACCEL = root.ACCEL

const INITIAL_DURATION = 1.2				# heartbeat duration when sprint starts
onready var REFRESH_WINDOW = 0.4 			# time window to refresh the sprint
onready var DURATION = INITIAL_DURATION		# heartbeat duration that shrinks over time


func _ready():
	set_one_shot(true)
	root.connect("interrupt", self, "force_fail")
	root.connect("input_heartbeat", self, "beat_heart")

func beat_heart():
	input_received = true

func force_fail():
	state = FAIL


func _on_Heartbeat_timeout():
	state = FAIL
	emit_signal("sprint_fail")

# placeholder linear interp; used for the placeholder speed setter
func interpolate(valA, valB, ratio):
	return (valA * 1-ratio) + (valB * ratio)


func _process(_delta):
	
	match state:
		IDLE:
			idle_state()
		SPRINT:
			sprint_state()
		REFRESH:
			refresh_state()
		FAIL:
			fail_state()

func idle_state():
	if input_received:
		input_received = false
		start(INITIAL_DURATION)
		state = SPRINT

func sprint_state():
	if get_time_left() < REFRESH_WINDOW:
		state = REFRESH
		emit_signal("systole")
	elif input_received:
		input_received = false
		emit_signal("sprint_fail")
		state = FAIL
	
	# PLACEHOLDER changes character speed as he sprints 
	root.set_SPEED(interpolate(root.get_SPEED(), SPEED*SPRINT, 0.05))

func refresh_state():
	if input_received:
		input_received = false
		emit_signal("diastole")
		start(DURATION)
		state = SPRINT

func fail_state():
	root.set_SPEED(SPEED) # returns them to not-sprinting speed
	yield(root, "sprint_ready")
	state = IDLE
