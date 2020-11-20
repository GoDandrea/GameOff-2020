extends KinematicBody

var GRAVITY = -24.8
var SPEED = 2.5 setget set_SPEED, get_SPEED
var SPRINT_MOD = 1.5 setget set_SPRINT, get_SPRINT
var ACCEL = 0.01

var MOUSE_SENS = 0.5
var ROT_SENS = 1.2

var movement_vec = Vector3()
var rot_degrees = 0
var collision

var is_sprinting = false
var stress = 0

# these will be assigned the nodes for each part of the sprint system
var Heartbeat
var Breath
var Balance
var Blink

signal interrupt		# if a sprint system fails, tells the other systems to force_fail()
signal sprint_ready		# tells when the sprint cooldowwn is over
signal input_heartbeat	# tells Heartbeat the player pressed shift

onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast
 
onready var cursor = load("res://sprites/crosshair.png")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(cursor)
	
	Heartbeat = get_node("Heartbeat")
	Breath = get_node("Breath")
	Balance = get_node("Balance")
	Blink = get_node("Blink")
	
	Heartbeat.connect("sprint_fail", self, "abort_sprint")
	
	yield(get_tree(), "idle_frame")
	get_tree().call_group("zombies", "set_player", self)


func _process(_delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
 
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_UI(delta)


func process_input(_delta):
	
	if Input.is_action_just_pressed("heartbeat"):
		# avoid queing input signals
		if $Cooldown.is_stopped():
			emit_signal("input_heartbeat")
	
	movement_vec = Vector3()
	rot_degrees = 0
	if Input.is_action_pressed("move_forward"):
		movement_vec.z -= 1
	if Input.is_action_pressed("move_backward"):
		movement_vec.z += 1
	if Input.is_action_pressed("move_left"):
		rot_degrees += ROT_SENS
	if Input.is_action_pressed("move_right"):
		rot_degrees -= ROT_SENS
	

func process_movement(delta):
	
	movement_vec = movement_vec.normalized()
	if is_sprinting:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y) * SPRINT_MOD
		rotation_degrees.y += rot_degrees/2
	else:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y)
		rotation_degrees.y += rot_degrees

	# this collision data can be used to make better collision failures eventurally
	collision = move_and_collide(movement_vec * SPEED * delta)
	if collision and SPEED > 2.5:
		abort_sprint()

func process_UI(_delta):
	pass

func abort_sprint():
	emit_signal("interrupt")
	$Cooldown.start(5)

func _on_Cooldown_timeout():
	emit_signal("sprint_ready")

# SETGET FUNCTIONS #############################################################
# SPEED
func set_SPEED(value):
	SPEED = value

func get_SPEED():
	return SPEED

# SPRINT_MOD
func set_SPRINT(value):
	SPRINT_MOD = value

func get_SPRINT():
	return SPRINT_MOD
