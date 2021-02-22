extends Node

signal sprint_failed	# sprinting is to be interrupted in a failed state
signal set_viewport_scale

enum {
	IDLE,
	BALANCING,
	FAIL,
}

# Besides the usual state machine, this script has a second one with six states. 
# They are used to make the mouse movement more interesting. 
enum {
	LEFT_SLOW,
	LEFT_MEDIUM,
	LEFT_FAST,
	RIGHT_SLOW,
	RIGHT_MEDIUM,
	RIGHT_FAST,
}

const RELATIVE_POSITION_WEIGHT = 1.5

var viewport_scale
var screen_width
var screen_height
var SHIFT_DELAY = 1
var shift_trend = LEFT_SLOW
var shift_timer = 0

var viewport_container = globals.viewport_container

onready var state = BALANCING
onready var player_root = get_parent().get_parent()
onready var camera = player_root.get_node("Camera")

# How much the character is tilting (in degrees). 0 is perpendicular to floor
# Is meant to be between -18 and +18
onready var current_tilt = 0 setget set_tilt

# Shift == shift of the pointer, causing it to move erratically
onready var shift_dir = Vector2(1, 0)	# Direction of the shift
onready var shift_rot = 0				# Ongoing rotation of shift vector

onready var mouse_pull					# How much the mouse is pulling the player to the sides
onready var mouse_pos = Vector2()		# Vector2 with mouse coordinates
onready var mouse_rel = Vector2()		# Vector2 with mouse position relative to the center of the screen


func _ready():
	
	randomize()
	player_root.connect("sprint_failed", self, "force_fail")
	player_root.connect("start_brain", self, "_on_Player_balance_start")


func _input(_event):
	
	if Input.is_action_just_pressed("left_click"):
		_on_Player_balance_start()
		#add_tilt(5)
	elif Input.is_action_just_released("right_click"):
		print(shift_rot)
		#add_tilt(-5)


func _process(_delta):
	
	var fps = Engine.get_frames_per_second()
	var lerp_interval = shift_dir / fps
	var lerp_position = mouse_pos + lerp_interval



# The change to the player's tilt has to be regular, so it's done by physics_process
func _physics_process(delta):
	
	match state:
		IDLE:
			idle_state()
		BALANCING:
			balancing_state(delta)
		FAIL:
			fail_state()


func idle_state():
	pass


func balancing_state(delta):
	
	var screen_width = get_viewport().get_size().x
	var screen_height = get_viewport().get_size().y
	var center_coord = Vector2(screen_width/2, screen_height/2)

	camera.set_rotation_degrees(Vector3(0, 0, current_tilt))

	#if current_tilt > 18 or current_tilt < -18:
	#	emit_signal("sprint_failed")

	mouse_pos = get_viewport().get_mouse_position()
	mouse_rel = mouse_pos
	mouse_rel.x -= screen_width/2
	mouse_rel.y -= screen_height/2
	
	# mouse_rel.x goes from about -500 to +500, so we'll change it to a [-10, 10],
	# which is easier to work with, then square it, so the borders of the screen
	# have much more impact than the middle when balancing the character.
	mouse_pull = (mouse_rel.x / 100)
	mouse_pull *= 5
	add_tilt(mouse_pull)
	
	shift_timer += delta
	if shift_timer >= SHIFT_DELAY:
		update_shift_trend()
		shift_timer = 0
	update_shift_dir(delta)
	shift_pointer(delta)


func fail_state():
	
	globals.brainUI.reset()
	current_tilt = 0
	set_tilt(0)
	yield(player_root, "sprint_ready")
	state = IDLE


# Changes the direction and speed of the shift vector rotation based on current trend
func update_shift_trend():
	match shift_trend:
		LEFT_SLOW:
			left_slow()
		LEFT_MEDIUM:
			left_medium()
		LEFT_FAST:
			left_fast()
		RIGHT_SLOW:
			right_slow()
		RIGHT_MEDIUM:
			right_medium()
		RIGHT_FAST:
			right_fast()


func update_shift_dir(delta):
	var current_angle = shift_dir.angle()
	var target_angle = current_angle
	target_angle += shift_rot*0.001
	#print(current_angle)
	
	var new_angle = lerp_angle(current_angle, target_angle, delta)
	shift_dir = shift_dir.rotated(new_angle)


func shift_pointer(delta):
	var shift_target = mouse_pos
	
	shift_target += shift_dir * 1000
	shift_target += mouse_rel * 1 #RELATIVE_POSITION_WEIGHT
	shift_target = lerp(mouse_pos, shift_target, delta)
	get_viewport().warp_mouse(shift_target)


func _on_Player_balance_start():
	globals.brainUI.show_gauge()
	if (randi() & 1) == 0:
		shift_trend = LEFT_SLOW
	else:
		shift_trend = RIGHT_SLOW
	state = BALANCING


func force_fail():
	state = FAIL


func add_tilt(tilt):
	current_tilt += tilt/10


func set_tilt(tilt):
	current_tilt = tilt


func left_slow():
	shift_rot = -PI*0.2
	var change = randi() % 100 + 1
	if change <= 10:
		shift_trend = RIGHT_MEDIUM	# Abrupt chnge of direction
	elif change <= 45:
		shift_trend = RIGHT_SLOW		# Change of direction
	elif change <= 65:
		shift_trend = LEFT_SLOW		# Constant rotation
	elif change <= 85:
		shift_trend = LEFT_MEDIUM		# Speed up rotation
	else:
		shift_trend = LEFT_FAST		# Speed up rotation even more

func left_medium():
	shift_rot = -PI*0.4
	var change = randi() % 100 + 1
	if change <= 10:
		shift_trend = RIGHT_SLOW		# Change of direction
	elif change <= 40:
		shift_trend = LEFT_SLOW		# Slow down rotation
	elif change <= 60:
		shift_trend = LEFT_MEDIUM		# Constant rotation
	else:
		change = LEFT_FAST		# Speed up rotation

func left_fast():
	shift_rot = -PI*0.8
	var change = randi() % 100 + 1
	if change <= 5:
		shift_trend = LEFT_SLOW		# Slow down rotation by a lot
	elif change <= 20:
		shift_trend = LEFT_MEDIUM		# Slow down rotation
	else:
		shift_trend = LEFT_FAST		# Constant rotation

func right_slow():
	shift_rot = PI*0.2
	var change = randi() % 100 + 1
	if change <= 10:
		shift_trend = LEFT_MEDIUM
	elif change <= 45:
		shift_trend = LEFT_SLOW
	elif change <= 65:
		shift_trend = RIGHT_SLOW
	elif change <= 85:
		shift_trend = RIGHT_MEDIUM	
	else:
		shift_trend = RIGHT_FAST

func right_medium():
	shift_rot = PI*0.4
	var change = randi() % 100 + 1
	if change <= 10:
		shift_trend = LEFT_SLOW
	elif change <= 40:
		shift_trend = RIGHT_SLOW
	elif change <= 60:
		shift_trend = RIGHT_MEDIUM	
	else:
		change = RIGHT_FAST

func right_fast():
	shift_rot = PI*0.8
	var change = randi() % 100 + 1
	if change <= 5:
		shift_trend = RIGHT_SLOW
	elif change <= 20:
		shift_trend = RIGHT_MEDIUM
	else:
		shift_trend = RIGHT_FAST



