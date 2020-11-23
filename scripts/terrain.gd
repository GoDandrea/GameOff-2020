extends Spatial

var threads: Array
var chunks = {}
var generating_chunks = {}
var noise: OpenSimplexNoise

export var material: Material

onready var player = globals.player
var player_chunk_grid_pos: Vector2


func _ready():
	randomize()
	noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 7
	noise.persistence = 0.2

	player_chunk_grid_pos = get_chunk_grid_pos_for(player.translation)
	generate_chunk([Chunk.new(player_chunk_grid_pos, noise, material), null])
	generate_chunks_around(player_chunk_grid_pos)


func _process(delta):
	var old_player_chunk_grid_pos = player_chunk_grid_pos
	player_chunk_grid_pos  = get_chunk_grid_pos_for(player.translation)
	if old_player_chunk_grid_pos != player_chunk_grid_pos:
		generate_chunks_around(player_chunk_grid_pos)
		call_deferred("cleanup_old_chunks",  player_chunk_grid_pos)


func generate_chunk(arr):
	var chunk = arr[0]
	var thread = arr[1]

	chunk.generate()
	call_deferred("finished_generating_chunk", thread, chunk)


func generate_chunks_around(grid_pos):
	
	start_generating_chunk(Vector2(grid_pos.x + 1, grid_pos.y + 0))
	start_generating_chunk(Vector2(grid_pos.x + 1, grid_pos.y + 1))
	start_generating_chunk(Vector2(grid_pos.x + 1, grid_pos.y - 1))
	start_generating_chunk(Vector2(grid_pos.x + 0, grid_pos.y + 1))
	start_generating_chunk(Vector2(grid_pos.x - 1, grid_pos.y + 0))
	start_generating_chunk(Vector2(grid_pos.x - 1, grid_pos.y - 1))
	start_generating_chunk(Vector2(grid_pos.x - 1, grid_pos.y + 1))
	start_generating_chunk(Vector2(grid_pos.x - 0, grid_pos.y - 1))


func start_generating_chunk(grid_pos: Vector2):
	var chunk = Chunk.new(grid_pos, noise, material)

	if not chunks.has(chunk.key) and not generating_chunks.has(chunk.key):
		var thread = Thread.new()
		generating_chunks[chunk.key]  = chunk
		thread.start(self,  "generate_chunk", [chunk, thread])
		threads.push_back(thread)


func finished_generating_chunk(thread, chunk):
	chunks[chunk.key] = chunk
	generating_chunks.erase(chunk.key)

	# chunk.create_collider()
	call_deferred("add_child", chunk)
	chunk.call_deferred("set_owner", self)

	if not thread:
		return

	thread.wait_to_finish()
	var index = threads.find(thread)
	if index != -1:
		threads.remove(index)


func get_chunk_grid_pos_for(position):
	var start = Vector2(position.x, position.z)
	
	if start.x > 0:
		start.x += globals.CHUNK_SIZE / 2.0
	elif start.x < 0:
		start.x -= globals.CHUNK_SIZE / 2.0
	
	if start.y > 0:
		start.y += globals.CHUNK_SIZE / 2.0
	elif start.y < 0:
		start.y -= globals.CHUNK_SIZE / 2.0

	return Vector2(
			int(start.x / globals.CHUNK_SIZE),
			int(start.y / globals.CHUNK_SIZE)
		)


func cleanup_old_chunks(center_grid_pos: Vector2):
	
	var valid_chunks = [
		"TerrainChunk_%d_%d" % [center_grid_pos.x + 1, center_grid_pos.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_pos.x + 1, center_grid_pos.y + 0],
		"TerrainChunk_%d_%d" % [center_grid_pos.x + 1, center_grid_pos.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_pos.x + 0, center_grid_pos.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_pos.x + 0, center_grid_pos.y + 0],
		"TerrainChunk_%d_%d" % [center_grid_pos.x + 0, center_grid_pos.y - 1],
		"TerrainChunk_%d_%d" % [center_grid_pos.x - 1, center_grid_pos.y + 1],
		"TerrainChunk_%d_%d" % [center_grid_pos.x - 1, center_grid_pos.y + 0],
		"TerrainChunk_%d_%d" % [center_grid_pos.x - 1, center_grid_pos.y - 1]
	]

	var keys_to_erase = []
	for key in chunks.keys():
		if not valid_chunks.has(key):
			keys_to_erase.push_back(key)
	for key in keys_to_erase:
		chunks[key].queue_free()
		chunks.erase(key)
		
