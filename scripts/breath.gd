extends Timer

signal sprint_fail
signal inspire

enum {
	IDLE,
	INSPIRE,
	EXPIRE,
	FAIL
}

onready var state = IDLE
onready var parent = get_parent()

func _ready():
	set_one_shot(true)
	parent.connect("interrrupt", self, "force_fail")

func force_fail():
	state = FAIL

func _on_Breath_timeout():
	if state == INSPIRE:
		inspire_fail()
	else:
		expire_fail()
	emit_signal("sprint_fail")

func _process(delta):
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
