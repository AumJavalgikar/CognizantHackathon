extends Node2D
@onready var tile_map = get_tree().get_root().get_node("Map/TileMap")
@onready var dad = get_tree().get_root().get_node("Map/Dad")
@onready var camera: Camera2D = get_tree().get_root().get_node("Map/Character2DAdam").get_node('Camera2D')
@onready var temp = get_tree().get_root().get_node("Map/TileMap").get('size')
@onready var aStar = get_tree().get_root().get_node("Map/TileMap").get('aStar')
var customEndIdx = null
var customStartIdx = null
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _input(event):
	if event is InputEventMouseButton:
		customStartIdx = tile_map.local_to_map(dad.global_position)
		customEndIdx =  tile_map.local_to_map(event.position)
		queue_redraw()

func has_collision_polygon(i, j):
	var is_colliding
	for layer in range(0, tile_map.get_layers_count()):
		var tile_data: TileData = tile_map.get_cell_tile_data(layer, Vector2i(i, j))
		if tile_data == null:
			continue
		#print('Found tile data for ', i, ' ', j, ' in layer ', layer)		
		is_colliding = tile_data.get_collision_polygons_count(0) > 0 or tile_data.get_collision_polygons_count(1) > 0 
		#print('collision count for ', i, ' ', j, ' :', collision_count, ' in layer ', layer)
		if is_colliding:
			return is_colliding
	return is_colliding

func _draw():
	var marked_cells = []
	for i in temp.x:
		for j in temp.y:
			var is_colliding = has_collision_polygon(i, j)
			if !is_colliding:
				var new_label = Label.new()
				var local_coords = tile_map.map_to_local(Vector2i(i, j))
				new_label.text = str(i) + ',' + str(j)
				new_label.position = local_coords
				new_label.z_index = 10
				get_parent().add_child(new_label)
				#draw_circle(tile_map.map_to_local(Vector2i(i, j)), 5, Color.GREEN)
				marked_cells.append([i, j])	
							
	for cell in marked_cells:
		var i = cell[0]
		var j = cell[1]
		for vNeighborCell in [[i,j-1],[i,j+1],[i-1,j],[i+1,j]]:
			if vNeighborCell in marked_cells:
				draw_line(tile_map.map_to_local(Vector2i(i, j)), tile_map.map_to_local(Vector2i(vNeighborCell[0], vNeighborCell[1])), Color.GREEN)
	if customEndIdx != null:
		var startIdx = tile_map.getAStarCellId(customStartIdx)
		var endIdx = tile_map.getAStarCellId(customEndIdx)
		if aStar.has_point(startIdx) and aStar.has_point(endIdx):
			var path = Array(aStar.get_point_path(startIdx, endIdx))
			var last_node = path.pop_front()
			if last_node != null:
				#draw_circle(Vector2(last_node[0], last_node[1]), 5, Color.RED)			
				for node in path:
					#draw_circle(Vector2(node[0], node[1]), 5, Color.RED)			
					draw_line(Vector2(node[0], node[1]), Vector2(last_node[0], last_node[1]), Color.RED)
					last_node = node
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
