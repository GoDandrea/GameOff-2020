extends Timer

signal sprint_failed	# sprinting is to be interrupted in a failed state

enum {
	IDLE,
	SPRINT,
	REFRESH,
	FAIL,
}

const INITIAL_INTERVAL = 1.2			# Interval between heartbeats at first
const LOW_STRESS_BASE_VOL = -30 		# Initial volume on starting sprint
const LOW_STRESS_MAX_VOL = 0 			# Loudest  volume for circulation
const FADE_IN = 4.50 
const FADE_OUT = 5.00

onready var state = IDLE
onready var root = get_parent().get_parent()
onready var input_received = false

onready var low_stress_current_vol = LOW_STRESS_BASE_VOL
onready var tween_fade = get_node("Tween")
onready var refresh_window = 0.6 		# Time window to refresh the sprint
onready var interval = INITIAL_INTERVAL	# Variable interval between heartbeats


func _ready():
	set_one_shot(true)
	self.connect("timeout", self, "_on_timeout")
	root.connect("sprint_failed", self, "force_fail")
	root.connect("input_heartbeat", self, "beat_heart")


func beat_heart():
	input_received = true


func force_fail():
	state = FAIL


func _on_timeout():
	state = FAIL
	emit_signal("sprint_failed")

	tween_fade.interpolate_property($LowStressCirculation, "volume_db", 
			low_stress_current_vol, -80, FADE_OUT, 1, Tween.EASE_IN, 0) # Fade out
	tween_fade.start()
	low_stress_current_vol = LOW_STRESS_BASE_VOL # Reset Volume


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
		
		if !$LowStressCirculation.is_playing(): 
			$LowStressCirculation.set_volume_db(-80) 
			$LowStressCirculation.play() 
		
		if $LowStressCirculation.get_volume_db() == -80: # Fade in if not already 
			tween_fade.interpolate_property($LowStressCirculation, "volume_db", -80,
					LOW_STRESS_BASE_VOL, FADE_IN, 1, Tween.EASE_IN, 0) # Fade in
			tween_fade.start()
		
		start(INITIAL_INTERVAL)
		state = SPRINT


func sprint_state():
	if get_time_left() < refresh_window:
		state = REFRESH
		if root.sprint_duration > root.TimeToHighState:
			$HighSystole.play()
		else:
			$LowSystole.play()
		globals.heartUI.systole()
		if $LowStressCirculation.get_volume_db() < LOW_STRESS_MAX_VOL: # Increase circulation volume if less than max
			tween_fade.interpolate_property($LowStressCirculation, "volume_db", 
					low_stress_current_vol, low_stress_current_vol +1, FADE_IN, 1, Tween.EASE_IN, 0) 
			tween_fade.start()
			low_stress_current_vol += 1
	elif input_received:
		input_received = false
		emit_signal("sprint_failed")
		state = FAIL


func refresh_state():
	if input_received:
		input_received = false
		if root.sprint_duration > root.TimeToHighState:
			$HighDiastole.play()
		else: 
			$LowDiastole.play()
		globals.heartUI.diastole()
		start(interval)
		state = SPRINT


func fail_state():
	stop()
	globals.heartUI.reset()
	state = IDLE
