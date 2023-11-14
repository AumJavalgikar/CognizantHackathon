extends TileMap

var aStar:AStar2D

func getAStarCellId(vCell:Vector2)->int:
	return int(vCell.y+vCell.x*self.get_used_rect().size.y)

func _ready():
	var size = self.get_used_rect().size
	aStar = AStar2D.new()
	aStar.reserve_space(size.x * size.y)
	
	for i in size.x:
		for j in size.y:
			print(i,' ', j)
			#var idx = getAStarCellId(Vector2(i,j))
			#aStar.add_point(idx, Vector2(i,j))
