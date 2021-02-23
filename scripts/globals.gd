extends Node

var player
var viewport_container
var res_scale

# UI variables
var heartUI
var lungUI
var brainUI
var eyeUI
var portraitUI

# Custom mouse cursors
var arrow = load("res://sprites/mouse_cursors/arrow.png")
var beam = load("res://sprites/mouse_cursors/arrow.png")
var pointing_hand = load("res://sprites/mouse_cursors/arrow.png")

const QUAD_SIZE = 2
const CHUNK_QUAD_COUNT = 50
const CHUNK_SIZE = QUAD_SIZE * CHUNK_QUAD_COUNT

func _ready():
	
	Input.set_custom_mouse_cursor(arrow)
	Input.set_custom_mouse_cursor(beam, Input.CURSOR_IBEAM)
	Input.set_custom_mouse_cursor(pointing_hand, Input.CURSOR_POINTING_HAND)
