extends TileMap


func update_map_array(tilemap_wid, tilemap_len):
	var map_array = []
	for y in tilemap_len:
		for x in tilemap_wid:
			map_array.append(Vector2i(x, y))
	
	return map_array


func update_tile_map(matrix, map_wid, map_len, map_array):
	var tile_vec = null
	print(map_array)
	for x in map_wid:
		for y in map_len:
			tile_vec = map_array[matrix[x][y] - 1]
			set_cell(0, Vector2(x,y), 0, tile_vec)


func generate_new_map(matrix, map_wid, map_len, tilemap_wid, tilemap_len):
	var map_array = update_map_array(tilemap_wid, tilemap_len)
	update_tile_map(matrix, map_wid, map_len, map_array)
	print("New map created!")


func _ready():
	#var ts_atlas = TileSetAtlasSource.new()
	#map_array = update_map_array(6, 6)
	#var matrix = [[14, 14], [14, 14]]
	#create_tile_map(matrix, 2, 2)
	pass


func _process(delta):
	pass



