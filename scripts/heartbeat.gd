extends Timer

signal sprint_fail
signal heartbeat

enum {
	IDLE,
	WAIT,
	REFRESH,
	FAIL
}

var state

func _ready():
	state = IDLE
	set_one_shot(true)
	get_parent().connect("interrrupt", self, "force_fail")

func _process(delta):
	match state:
		IDLE:
			idle_state()
		WAIT:
			wait_state()
		REFRESH:
			refresh_state()
		FAIL:
			fail_state()

func force_fail():
	state = FAIL

func idle_state():
	if Input.is_action_just_pressed("heartbeat"):
		state = WAIT

func wait_state():
	if is_stopped():
		start(1.2)
	elif get_time_left() < 0.4:
		state = REFRESH
		emit_signal("heartbeat")
	elif Input.is_action_just_pressed("heartbeat"):
		emit_signal("sprint_fail")
		state = FAIL

func refresh_state():
	if Input.is_action_just_pressed("heartbeat"):
		stop()
		state = WAIT

func fail_state():
	yield(get_parent(), "sprint_ready")
	state = IDLE


func _on_Heartbeat_timeout():
	state = FAIL
	emit_signal("sprint_fail")
