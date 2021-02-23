extends Timer

signal sprint_failed	# sprinting is to be interrupted in a failed state
#signal inspire			# player holding space; time counting up
#signal expire			# player released space; time counting down
signal exhale_low
signal inhale_low
signal exhale_high
signal inhale_high

enum {
	IDLE,
	INSPIRE,
	EXPIRE,
	FAIL,
}

const TIME_UNTIL_HIGH = 10

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var input_pressed = false
onready var time = 0.0
onready var default_size = 99

onready var inhale_switch = 1
onready var exhale_switch = 0
onready var is_breathing = false
onready var Verb = AudioServer.get_bus_effect(AudioServer.get_bus_index("MoonBreath"), 0)


func _ready():
	
	set_one_shot(true)
	
	self.connect("timeout", self, "_on_timeout")
	self.connect("exhale_high", $HighExhale, "play")
	self.connect("exhale_low", $LowExhale, "play")
	self.connect("inhale_high", $HighInhale, "play")
	self.connect("inhale_low", $LowInhale, "play")
	
	root.connect("start_lungs", self, "_on_Player_breathing_start")
	root.connect("sprint_failed", self, "force_fail")
	root.connect("input_breath_pressed", self, "inhale")
	root.connect("input_breath_released", self, "exhale")
	root.connect("sprint_ready", self, "_on_sprint_ready")
	
#	Verb.dry = 0.5
#	Verb.wet = 0.1
#	Verb.room_size = 1
#	Verb.predelay_msec = 1
#	Verb.damping = 1


func force_fail():
	
	state = FAIL
	globals.lungUI.progress.set_value(default_size)
	globals.lungUI.progress.hide()
	globals.lungUI.space_icon.hide()
	is_breathing = false


func inhale():
	#print("inspire")
	input_pressed = true
	if state == EXPIRE:
		state = INSPIRE
		if exhale_switch == 0:
			exhale_switch = 1

	if inhale_switch == 1 && is_breathing == true:
		if root.sprint_duration > TIME_UNTIL_HIGH: 
			emit_signal("inhale_high")
		else: 
			emit_signal("inhale_low")
		#print("Play Inhale")
		inhale_switch = 0


func exhale():
	#print("expire")
	input_pressed = false
	if state == INSPIRE:
		state = EXPIRE
		if inhale_switch == 0: 
			inhale_switch = 1
	if exhale_switch == 1 && is_breathing == true:
		if root.sprint_duration > TIME_UNTIL_HIGH:
			emit_signal("exhale_high")
		else:
			emit_signal("exhale_low")
		exhale_switch = 0


func _on_timeout():
	state = FAIL
	emit_signal("sprint_failed")
	is_breathing = false
	#print("failstate")
	if root.sprint_duration > TIME_UNTIL_HIGH:
		$HighFail.play()
	else:
		$LowFail.play()


func _on_Player_breathing_start():
	globals.lungUI.progress.show()
	globals.lungUI.space_icon.show()
	state = EXPIRE
	if is_breathing == false:
		emit_signal("exhale_low")
	is_breathing = true


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
	pass


func _on_sprint_ready():
	if state == FAIL:
		state = IDLE

