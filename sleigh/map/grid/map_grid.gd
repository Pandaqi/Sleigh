class_name MapGrid

var grid
var grid_flat : Array[GridCell]
var size : Vector2i

func print_grid() -> void:
	print("### MAP GENERATOR ###")

	for y in range(size.y):
		var outputs := []
		for x in range(size.x):
			outputs.append(get_cell_at(Vector2(x,y)).print_pretty())
		var string := " | ".join(outputs)
		print(string)
	
	print("###")

func create() -> void:
	var starting_state : Dictionary[GridCell.ContentType, bool] = {
		GridCell.ContentType.BUILDING: true,
		GridCell.ContentType.GIFT: true
	}
	
	grid = []
	grid_flat = []
	for y in range(size.y):
		grid.append([])
		
		for x in range(size.x):
			var cell := GridCell.new(Vector2i(x,y))
			grid[y].append(cell)
			grid_flat.append(cell)
			
			cell.set_possible_contents(starting_state.duplicate())

func get_cells() -> Array[GridCell]:
	return grid_flat

func get_row(idx:int) -> Array[GridCell]:
	var arr : Array[GridCell] = []
	for x in range(size.x):
		arr.append(get_cell_at(Vector2(x, idx)))
	return arr

func get_column(idx:int) -> Array[GridCell]:
	var arr : Array[GridCell] = []
	for y in range(size.y):
		arr.append(get_cell_at(Vector2(idx, y)))
	return arr

func get_edge_cells() -> Array[GridCell]:
	var top := get_row(0)
	var bottom := get_row(grid.size() - 1)
	var left := get_column(0)
	var right := get_column(grid[0].size() - 1)
	return top + bottom + left + right

func get_grid_size() -> Vector2i:
	return size

func has_cell_at(pos:Vector2i) -> bool:
	return pos.x >= 0 and pos.x < size.x and pos.y >= 0 and pos.y < size.y

func get_cell_at(pos:Vector2i) -> GridCell:
	return grid[pos.y][pos.x]

func get_all_cells_for_content(tp:GridCell.ContentType) -> Array[GridCell]:
	return grid_flat.filter(func(c): return c.accepts_content(tp))

func get_cells_in_dir(pos:Vector2i, dir:Vector2) -> Array[GridCell]:
	var pos_exists := true
	var dir_clamped = Vector2i(dir.normalized())
	var arr : Array[GridCell] = []
	while pos_exists:
		pos += dir_clamped
		if not has_cell_at(pos): 
			pos_exists = false
			break
		arr.append(get_cell_at(pos))
	return arr

func get_cells_along_line(pos:Vector2i, dir:Vector2) -> Array[GridCell]:
	var cells : Array[GridCell] = [get_cell_at(pos)]
	cells += get_cells_in_dir(pos, dir)
	cells += get_cells_in_dir(pos, -dir)
	return cells

func get_neighbors_for(cell:GridCell) -> Array[GridCell]:
	var NB_DIRS := [Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.UP]
	var nbs : Array[GridCell] = []
	for nb_dir in NB_DIRS:
		var new_pos : Vector2i = cell.pos + nb_dir
		if not has_cell_at(new_pos): continue
		nbs.append(get_cell_at(new_pos))
	return nbs

func get_all_neighbors_for(cells:Array[GridCell]) -> Array[GridCell]:
	var nbs : Array[GridCell] = []
	for cell in cells:
		var cell_nbs := get_neighbors_for(cell)
		for cell_nb in cell_nbs:
			if nbs.has(cell_nb): continue
			nbs.append(cell_nb)
	return nbs

func get_square_around(pos:Vector2i, square_size:Vector2i) -> Array[GridCell]:
	var arr : Array[GridCell] = []
	for x in range(square_size.x):
		for y in range(square_size.y):
			var new_pos := pos + Vector2i(x,y)
			if not has_cell_at(new_pos): continue
			arr.append(get_cell_at(new_pos))
	return arr

func get_valid_cells_for(square_size:Vector3, type:GridCell.ContentType) -> Array[GridCell]:
	var arr : Array[GridCell] = []
	var expected_square_size := square_size.x * square_size.z
	for cell in grid_flat:
		if not cell.accepts_content(type): continue
		var square_cells := get_square_around(cell.pos, Vector2i(square_size.x, square_size.z))
		if square_cells.size() < expected_square_size: continue
		var bad_cells := square_cells.filter(func(nb): return not nb.accepts_content(type))
		if bad_cells.size() > 0: continue
		arr.append(cell)
	return arr
			
func get_front_back_ratio(pos:Vector2i) -> float:
	return clampf(1.0 - pos.y / float(size.y), 0.0, 1.0)
