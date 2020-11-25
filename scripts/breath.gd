extends Timer

signal sprint_fail	# sprinting is to be interrupted in a failed state
signal inspire		# player holding space; time counting up
signal expire		# player released space; time counting down
signal ExhaleLow
signal InhaleLow

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

onready var InhaleSwitch = 1
onready var ExhaleSwitch = 0
onready var Started = 0


func _ready():
	set_one_shot(true)
	root.connect("interrupt", self, "force_fail")
	root.connect("input_breath_pressed", self, "breathing_start")
	root.connect("input_breath_released", self, "breathing_stop")

func force_fail():
	state = FAIL
	Started = 0

func breathing_start():
	#print("inspire")
	input_pressed = true
	if state == EXPIRE:
		state = INSPIRE
		if ExhaleSwitch == 0: ExhaleSwitch = 1
	if InhaleSwitch == 1 && Started == 1:
		emit_signal("InhaleLow")
		print("Play Inhale")
		InhaleSwitch = 0

func breathing_stop():
	#print("expire")
	input_pressed = false
	if state == INSPIRE:
		state = EXPIRE
		if InhaleSwitch == 0: InhaleSwitch = 1
		
	if ExhaleSwitch == 1 && Started == 1:
		emit_signal("ExhaleLow")
		print("Play Exhale")
		ExhaleSwitch = 0
		

func _on_Breath_timeout():
	state = FAIL
	emit_signal("sprint_fail")

func _on_Player_breathing_start() -> void:
	globals.lungUI.progress.show()
	state = EXPIRE
	if Started == 0: emit_signal("ExhaleLow")
	Started = 1

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
	Started = 0



