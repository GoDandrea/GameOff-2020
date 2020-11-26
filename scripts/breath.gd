extends Timer

signal sprint_fail	# sprinting is to be interrupted in a failed state
#signal inspire		# player holding space; time counting up
#signal expire		# player released space; time counting down
signal ExhaleLow
signal InhaleLow
signal ExhaleHigh
signal InhaleHigh

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
onready var Verb = AudioServer.get_bus_effect(AudioServer.get_bus_index("MoonBreath"), 0)


func _ready():
	set_one_shot(true)
	root.connect("interrupt", self, "force_fail")
	root.connect("input_breath_pressed", self, "breathing_start")
	root.connect("input_breath_released", self, "breathing_stop")
#	Verb.dry = 0.5
#	Verb.wet = 0.1
#	Verb.room_size = 1
#	Verb.predelay_msec = 1
#	Verb.damping = 1


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
		if root.sprint_duration > root.TimeToHighState: emit_signal("InhaleHigh")
		else: emit_signal("InhaleLow")
		# print("Play Inhale")
		InhaleSwitch = 0

func breathing_stop():
	#print("expire")
	input_pressed = false
	if state == INSPIRE:
		state = EXPIRE
		if InhaleSwitch == 0: InhaleSwitch = 1

	if ExhaleSwitch == 1 && Started == 1:
		if root.sprint_duration > root.TimeToHighState:	emit_signal("ExhaleHigh")
		else: emit_signal("ExhaleLow")
		ExhaleSwitch = 0
		

func _on_Breath_timeout():
	state = FAIL
	emit_signal("sprint_fail")
	Started = 0
	print("failstate")
	#if root.sprint_duration > root.TimeToHighState: 
	$HighFail.play()
		#yield(get_tree().create_timer(5.0), "timeout")
		#$LowFail.play()
	#else: $LowFail.play()

func _on_Player_breathing_start():
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
	globals.lungUI.progress.set_value(default_size)
	globals.lungUI.progress.hide()
	yield(root, "sprint_ready")
	state = IDLE
	Started = 0



