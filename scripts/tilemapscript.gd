extends TileMap

@export var size = self.get_used_rect().size
var aStar:AStar2D

func getAStarCellId(vCell:Vector2)->int:
	return int(vCell.y+vCell.x*self.get_used_rect().size.y)

func has_collision_polygon(i, j):
	var collision_count = 0
	for layer in range(get_layers_count()):
		var tile_data: TileData = get_cell_tile_data(layer, Vector2i(i, j))
		if tile_data == null:
			continue
		#print('Found tile data for ', i, ' ', j, ' in layer ', layer)		
		collision_count = tile_data.get_collision_polygons_count(0)
		#print('collision count for ', i, ' ', j, ' :', collision_count, ' in layer ', layer)
		if collision_count != 0:
			return collision_count
	return collision_count

# Called when the node enters the scene tree for the first time.
func _ready():
	initiate_astar()
	
func initiate_astar():
	aStar = AStar2D.new()
	aStar.reserve_space(size.x * size.y)
	var marked_cells = []
	for i in size.x:
		for j in size.y:
			var collison_count = has_collision_polygon(i, j)
			if collison_count == 0:
				var idx = getAStarCellId(Vector2(i,j))
				aStar.add_point(idx, map_to_local(Vector2(i,j)))
				marked_cells.append([i, j])
	
	for cell in marked_cells:
		var i = cell[0]
		var j = cell[1]
		for vNeighborCell in [[i,j-1],[i,j+1],[i-1,j],[i+1,j]]:
			var idx=getAStarCellId(Vector2(i,j))
			var idxNeighbor=getAStarCellId(Vector2(vNeighborCell[0],vNeighborCell[1]))
			if vNeighborCell in marked_cells:
				aStar.connect_points(idx, idxNeighbor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
