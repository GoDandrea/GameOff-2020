extends KinematicBody

var GRAVITY = -24.8
var vel = Vector3()
var SPEED = 3 setget set_SPEED, get_SPEED
const SPRINT_MOD = 1.5
const DEACCEL = 5

var MOUSE_SENS = 0.5
var ROT_SENS = 2

var movement_vec = Vector3()
var rot_degrees = 0

var is_sprinting = false
var stress = 0
 
var Heartbeat
var Breath
var Balance
var Blink

signal interrupt
signal sprint_ready

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
	if Input.is_action_pressed("restart"):
		kill()
 
func _physics_process(delta):
	process_input(delta)
	process_movement(delta)
	process_UI(delta)


func process_input(delta):
	
	# Walking #################################
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

	# Sprinting ###############################
	

func process_movement(delta):
	
	movement_vec = movement_vec.normalized()
	if is_sprinting:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y) * SPRINT_MOD
		rotation_degrees.y += rot_degrees/2
	else:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y)
		rotation_degrees.y += rot_degrees
	move_and_collide(movement_vec * SPEED * delta)
	
	if Input.is_action_pressed("shoot") and !anim_player.is_playing():
		anim_player.play("shoot")
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill"):
			coll.kill()

func process_UI(delta):
	pass

func set_SPEED(value):
	SPEED = value

func get_SPEED():
	return SPEED

func kill():
	get_tree().reload_current_scene()

func abort_sprint():
	emit_signal("interrupt")
	$Cooldown.start(5)


func _on_Cooldown_timeout():
	emit_signal("sprint_ready")
