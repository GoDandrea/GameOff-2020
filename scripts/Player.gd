extends KinematicBody

var GRAVITY = -24.8
var vel = Vector3()
const MOVE_SPEED = 3
const SPRINT_MOD = 1.5
const DEACCEL = 5

var MOUSE_SENS = 0.5
var ROT_SENS = 2

var movement_vec = Vector3()
var rot_degrees = 0

var is_sprinting = false
var stress = 0
 
onready var anim_player = $AnimationPlayer
onready var raycast = $RayCast
 
onready var cursor = load("res://sprites/crosshair.png")

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
	Input.set_custom_mouse_cursor(cursor)
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
	if Input.is_action_pressed("heartbeat"):
		if not is_sprinting:
			is_sprinting = true
	else:
		is_sprinting = false

func process_movement(delta):
	
	movement_vec = movement_vec.normalized()
	if is_sprinting:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y) * SPRINT_MOD
		rotation_degrees.y += rot_degrees/2
	else:
		movement_vec = movement_vec.rotated(Vector3(0, 1, 0), rotation.y)
		rotation_degrees.y += rot_degrees
	move_and_collide(movement_vec * MOVE_SPEED * delta)
	
	if Input.is_action_pressed("shoot") and !anim_player.is_playing():
		anim_player.play("shoot")
		var coll = raycast.get_collider()
		if raycast.is_colliding() and coll.has_method("kill"):
			coll.kill()

func process_UI(delta):
	pass
 

func kill():
	get_tree().reload_current_scene()
