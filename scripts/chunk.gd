extends MeshInstance
class_name Chunk

var position: Vector2
var grid_pos: Vector2
var key: String
var noise: OpenSimplexNoise
var material: Material

var vertices = []
var uvs = []

# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
# warning-ignore:shadowed_variable
func _init(grid_pos: Vector2, noise: OpenSimplexNoise, material: Material):
    self.grid_pos = grid_pos
    self.position = Vector2(
        grid_pos.x * globals.CHUNK_SIZE - globals.CHUNK_SIZE / 2.0,
        grid_pos.y * globals.CHUNK_SIZE - globals.CHUNK_SIZE / 2.0
    )
    self.key = "TerrainChunk_%d_%d" % [grid_pos.x, grid_pos.y]
    self.noise = noise
    self.material = setup_material(material)


# warning-ignore:shadowed_variable
func setup_material(material: Material):
    if material:
        return material

    var mat = SpatialMaterial.new()
    mat.albedo_color = Color(1.0, 1.0, 0.0)
    return mat


func generate():
    var st = SurfaceTool.new()

    for x in range (globals.CHUNK_QUAD_COUNT):
        for z in range (globals.CHUNK_QUAD_COUNT):
            generate_quad(
                Vector3(position.x + x * globals.QUAD_SIZE, 0, position.y + z * globals.QUAD_SIZE),
                Vector2(globals.QUAD_SIZE, globals.QUAD_SIZE)
                )

    st.begin(Mesh.PRIMITIVE_TRIANGLES)
    st.set_material(material)
    for i in range(vertices.size()):
        st.add_uv(uvs[i])
        st.add_vertex(vertices[i])

    st.generate_normals()
    var mesh = st.commit()

    self.set_name(key)
    self.mesh = mesh
    self.cast_shadow = 1


# warning-ignore:shadowed_variable
func generate_quad(position: Vector3, size: Vector2):
    vertices.push_back(create_vertex(position.x, position.z + size.y))
    vertices.push_back(create_vertex(position.x, position.z))
    vertices.push_back(create_vertex(position.x + size.x, position.z))

    vertices.push_back(create_vertex(position.x, position.z + size.y))
    vertices.push_back(create_vertex(position.x + size.x, position.z))
    vertices.push_back(create_vertex(position.x + size.x, position.z + size.y))

    uvs.push_back(Vector2(0,0))
    uvs.push_back(Vector2(0,1))
    uvs.push_back(Vector2(1,1))

    uvs.push_back(Vector2(0,0))
    uvs.push_back(Vector2(0,1))
    uvs.push_back(Vector2(1,1))

func create_vertex(x, z):
    var y = noise.get_noise_2d(x, z) * 3
    return Vector3(x, y, z)
