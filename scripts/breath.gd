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
onready var default_size = 99

func _ready():
	set_one_shot(true)
	root.connect("interrupt", self, "force_fail")
	root.connect("input_breath_pressed", self, "breathing_start")
	root.connect("input_breath_released", self, "breathing_stop")

func force_fail():
	state = FAIL

func breathing_start():
	print("inspire")
	input_pressed = true
	if state == EXPIRE:
		state = INSPIRE

func breathing_stop():
	print("expire")
	input_pressed = false
	if state == INSPIRE:
		state = EXPIRE

func _on_Breath_timeout():
	state = FAIL
	emit_signal("sprint_fail")

func _on_Player_breathing_start() -> void:
	globals.lungUI.progress.show()
	state = EXPIRE

func _process(delta):
	
	match state:
		IDLE:
			idle_state()
		INSPIRE:
			inspire_state(delta)
		EXPIRE:
			expire_state(delta)
		FAIL:
			fail_state()

func idle_state():
	pass

func inspire_state(delta):
	globals.lungUI.inspire(delta)

func expire_state(delta):
	globals.lungUI.expire(delta)

func fail_state():
	globals.lungUI.progress.hide()
	globals.lungUI.progress.set_value(default_size)
	yield(root, "sprint_ready")
	state = IDLE



