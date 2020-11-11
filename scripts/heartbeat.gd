extends Timer

signal sprint_fail
signal heartbeat

enum {
	IDLE,
	SPRINT,
	REFRESH,
	FAIL
}

onready var state = IDLE
onready var parent = get_parent()
onready var SPEED = parent.get_SPEED()
onready var SPRINT_MOD = parent.get_SPRINT()
onready var ACCEL = parent.ACCEL

func _ready():
	set_one_shot(true)
	parent.connect("interrrupt", self, "force_fail")

func force_fail():
	state = FAIL

func _on_Heartbeat_timeout():
	state = FAIL
	emit_signal("sprint_fail")

func interpolate(valA, valB, ratio):
	return (valA * 1-ratio) + (valB * ratio)


func _process(delta):
	print(state)
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
	if Input.is_action_just_pressed("heartbeat"):
		state = SPRINT

func sprint_state():
	if is_stopped():
		start(1.2)
	elif get_time_left() < 0.4:
		state = REFRESH
		emit_signal("heartbeat")
	elif Input.is_action_just_pressed("heartbeat"):
		emit_signal("sprint_fail")
		state = FAIL
	parent.set_SPEED(interpolate(parent.get_SPEED(), SPEED*SPRINT, 0.05))

func refresh_state():
	if Input.is_action_just_pressed("heartbeat"):
		stop()
		state = SPRINT

func fail_state():
	parent.set_SPEED(SPEED)
	yield(get_parent(), "sprint_ready")
	state = IDLE
