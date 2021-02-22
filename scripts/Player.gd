extends KinematicBody


# Signals
signal sprint_failed			# tells SprintStates that sprint has failed
signal sprint_ready				# sprint cooldown is over
signal input_heartbeat			# tell Heart the player pressed shift

signal start_lungs				# start Lungs state machine
signal input_breath_pressed		# tell Lungs space is held down
signal input_breath_released	# tell Lungs space was released

signal start_brain				# start Brain state machine

signal start_eyes				# start Eyes state machine
signal input_blink_pressed		# tell Eyes mouse1 is held down
signal input_blink_released		# tell Eyes mouse1 was released

signal player_stumbled
signal player_fell

# Enums
enum {
	STANDING,
	WALKING,
	STUMBLING,
	FALLING,
	SPRINT_HEART,
	SPRINT_LUNGS,
	SPRINT_BRAIN,
	SPRINT_EYES,
}

# Constants
const LUNGS_START = 5
const BRAIN_START = 9
const EYES_START = 15

const GRAVITY = -24.8
const SPEED = 2.5
const SPRINT_MOD = 2
const ACCEL = 0.01

# User-defined variables
var MOUSE_SENS = 0.5
var ROT_SENS = 1.2

# Movement variables
var movement_vec = Vector3()
var rot_degrees = 0
var is_moving = false
var collision
var sprint_duration = 0.0
var is_sprinting = false
var stress = 0
var player_state = STANDING

var TimeToHighState = 10

var in_cooldown = false
var has_stumbled = false
var is_down = false

# Onready variables (can only be assigned nodes once Player is in Node-tree)
onready var node_heart = $SprintStates/Heart
onready var node_lungs = $SprintStates/Lungs
onready var node_brain = $SprintStates/Brain
onready var node_eyes = $SprintStates/Eyes
onready var node_cooldown = $Cooldown

onready var raycast = $RayCast
onready var animator = $AnimationPlayer

onready var cursor = load("res://sprites/crosshair.png")


# Called when this object is first created
func _init():
	pass


# Called when all this object's children were created and are ready
func _ready():

	globals.player = self
	
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(cursor)
	
	node_heart.connect("sprint_failed", self, "abort_sprint", ["heart"])
	node_lungs.connect("sprint_failed", self, "abort_sprint", ["lung"])
	node_brain.connect("sprint_failed", self, "abort_sprint", ["brain"])
	
	node_cooldown.connect("timeout", self, "_on_Cooldown_timeout")


# Called every frame, with no regular interval between them (hence "delta")
func _process(delta):
	
	if is_sprinting:
		sprint_duration += delta
		
		match player_state:
			SPRINT_HEART:
				if sprint_duration > LUNGS_START:
					player_state = SPRINT_LUNGS
					emit_signal("start_lungs")
			SPRINT_LUNGS:
				if sprint_duration > BRAIN_START:
					player_state = SPRINT_BRAIN
					emit_signal("start_brain")
			SPRINT_BRAIN:
				if sprint_duration > EYES_START:
					player_state = SPRINT_EYES
					emit_signal("start_eyes")
	
	if Input.is_action_pressed("exit"):
		get_tree().quit()


# Called in regular intervals (~60 times per second)
func _physics_process(delta):
	
	movement_vec = Vector3()
	rot_degrees = 0
	
	var move_speed = SPEED
	if is_sprinting:
		move_speed *= SPRINT_MOD
	
	if Input.is_action_pressed("move_forward"):
		movement_vec.z -= move_speed
	if Input.is_action_pressed("move_backward"):
		movement_vec.z += move_speed
	if Input.is_action_pressed("move_left"):
		rot_degrees += ROT_SENS
	elif Input.is_action_pressed("move_right"):
		rot_degrees -= ROT_SENS
	else:
		rot_degrees = 0
	
	movement_vec = movement_vec.normalized()
	if movement_vec.z == 0:
		if player_state == WALKING:
			player_state = STANDING
	elif player_state == STANDING:
		player_state = WALKING
	
	if player_state >= SPRINT_HEART:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y) * SPRINT_MOD
		rotation_degrees.y += rot_degrees/2
	else:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y)
		rotation_degrees.y += rot_degrees
	
	match player_state:
		STANDING:
			animator.stop(true)
		WALKING:
			animator.play("walk")
		SPRINT_HEART:
			animator.play("low_sprint")
		SPRINT_LUNGS, SPRINT_BRAIN, SPRINT_EYES:
			animator.play("high_sprint")
	
	# this collision data can be used to make better collision failures eventually
	if is_down == false:
		collision = move_and_collide(movement_vec * SPEED * delta)
	if collision and SPEED > 2.5:
		abort_sprint("collision")


#### TODO:
# Get action from input event, get the action's name as string, and use match
# to get the action without using so many ifs.
# Maybe it's faster, but it's definitely less ugly. 


# Called only when a key input isn't handled by something else (like UI)
func _unhandled_key_input(_event):
	
	if Input.is_action_just_pressed("heartbeat"):
		if player_state == WALKING:
			player_state = SPRINT_HEART
		is_sprinting = true
		emit_signal("input_heartbeat")
	
	if Input.is_action_pressed("breathe"):
		emit_signal("input_breath_pressed")
	elif Input.is_action_just_released("breathe"):
		emit_signal("input_breath_released")
	


# Same as _unhandled_key_input, but will be used for mouse events only
#func _unhandled_input(_event):
func _input(_event):
	
	if Input.is_action_just_pressed("left_click"):
		pass
		#emit_signal("input_blink_pressed")
		#globals.eyeUI.close_eye()
		#print("close eye")
	elif Input.is_action_just_released("left_click"):
		pass
		#emit_signal("input_blink_released")
		#globals.eyeUI.open_eye()
		#print("open eye")

func do_stumble():
	has_stumbled = true

func stand_up():
	is_down = false

func abort_sprint(_reason):
	
	# Reasons:
	# collision
	# heart
	# lung
	# brain
	
	if in_cooldown == false:
		is_sprinting = false
		in_cooldown = true
		
		globals.portraitUI.hilight.show()
		emit_signal("sprint_failed")
		
		if sprint_duration < TimeToHighState and has_stumbled == false:
			$Cooldown.start(3)
			player_state = STUMBLING
			animator.play("stumble")
			emit_signal("player_stumbled")
		
		elif has_stumbled == false:
			$Cooldown.start(5)
			player_state = FALLING
			is_down = true
			animator.play("fall_down")
			emit_signal("player_fell")
		
		sprint_duration = 0.0

func _on_Cooldown_timeout():
	
	globals.portraitUI.hilight.hide()
	in_cooldown = false
	player_state = STANDING
	has_stumbled = false
	emit_signal("sprint_ready")


