extends Node

var player

const QUAD_SIZE = 2
const CHUNK_QUAD_COUNT = 50
const CHUNK_SIZE = QUAD_SIZE * CHUNK_QUAD_COUNT

func _ready():
    player = get_tree().get_root().find_node("Player", true, false)

