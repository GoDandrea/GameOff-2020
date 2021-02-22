extends Control

onready var parent = get_parent()

var origin = Vector2(0, 0)

func _process(delta: float) -> void:
	update()

func _draw():
#    var center = Vector2(200, 200)
#    var radius = 80
#    var angle_from = 75
#    var angle_to = 195
#    var color = Color(1.0, 0.0, 0.0)
#    draw_circle_arc(center, radius, angle_from, angle_to, color)
	var shift_dir = parent.shift_dir
	print(origin,  "\t", shift_dir)
	#draw_line(new_coord(origin), new_coord(shift_dir * 5), Color(1,0,0))
	draw_circle(new_coord(Vector2(0, 0)), 5, Color(1.0, 0.0, 0.0))


func new_coord(old_coord):
	
	var screen_width = get_viewport().get_size().x
	var screen_height = get_viewport().get_size().y
	
	var new_coord = Vector2()
	new_coord.x = old_coord.x + screen_width/2
	new_coord.y = old_coord.y + screen_height/2
	return new_coord


func draw_circle_arc(center, radius, angle_from, angle_to, color):
    var nb_points = 32
    var points_arc = PoolVector2Array()

    for i in range(nb_points + 1):
        var angle_point = deg2rad(angle_from + i * (angle_to-angle_from) / nb_points - 90)
        points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

    for index_point in range(nb_points):
        draw_line(points_arc[index_point], points_arc[index_point + 1], color)
