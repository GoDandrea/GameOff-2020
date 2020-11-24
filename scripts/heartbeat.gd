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

onready var LSCirculationBaseVolume = -30 #Initial volume on starting sprint
onready var LSCirculationMaxVolume = 0 #Loudest  volume for circulation
onready var LSCirculationCurrentVolume = LSCirculationBaseVolume
onready var FadeInTime = 4.50 
onready var FadeOutTime = 5.00
onready var TweenFade = get_node("Tween")

const INITIAL_DURATION = 1.2				# heartbeat duration when sprint starts
onready var REFRESH_WINDOW = 0.6 			# time window to refresh the sprint
onready var DURATION = INITIAL_DURATION		# heartbeat duration that shrinks over time


func _ready():
	set_one_shot(true)
	root.connect("interrupt", self, "force_fail")
	root.connect("input_heartbeat", self, "beat_heart")
	#connect("systole", globals.heartUI, "systole")
	#connect("diastole", globals.heartUI, "diastole")

func beat_heart():
	input_received = true

func force_fail():
	state = FAIL


func _on_Heartbeat_timeout():
	state = FAIL
	TweenFade.interpolate_property($LowStressCirculation, "volume_db", LSCirculationCurrentVolume, -80, FadeOutTime, 1, Tween.EASE_IN, 0) #Fade out
	TweenFade.start()
	LSCirculationCurrentVolume = LSCirculationBaseVolume #Reset Volume
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
		if !$LowStressCirculation.is_playing(): 
			$LowStressCirculation.set_volume_db(-80) 
			$LowStressCirculation.play() 
		if $LowStressCirculation.get_volume_db() == -80: #Fade in if not already 
			TweenFade.interpolate_property($LowStressCirculation, "volume_db", -80, LSCirculationBaseVolume, FadeInTime, 1, Tween.EASE_IN, 0) #Fade in
			TweenFade.start()
		start(INITIAL_DURATION)
		state = SPRINT

func sprint_state():
	if get_time_left() < REFRESH_WINDOW:
		state = REFRESH
		emit_signal("systole")
		globals.heartUI.systole()
		if $LowStressCirculation.get_volume_db() < LSCirculationMaxVolume: #Increase circulation volume if less than max
			TweenFade.interpolate_property($LowStressCirculation, "volume_db", LSCirculationCurrentVolume, LSCirculationCurrentVolume +1, FadeInTime, 1, Tween.EASE_IN, 0) 
			TweenFade.start()
			LSCirculationCurrentVolume += 1
			print ($LowStressCirculation.get_volume_db())
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
		globals.heartUI.diastole()
		start(DURATION)
		state = SPRINT

func fail_state():
	root.set_SPEED(SPEED) # returns them to not-sprinting speed
	globals.heartUI.reset()
	yield(root, "sprint_ready")
	state = IDLE
