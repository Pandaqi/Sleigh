extends Node3D
class_name MapGenerator

const MAP_SIZE := Vector2i(20, 10)
const NUM_BUILDINGS := 10

const BUILDING_HEIGHT_MIN := 1.0
const BUILDING_HEIGHT_MAX := 6.0

var building_positions : Array[Vector2i] = []
var building_sizes : Array[Vector3] = []
var building_types : Array[Gift.Type] = []

const NUM_GIFTS_FACTOR := 1.0 # ~num_buildings
var gift_positions : Array[Vector3] = []
var gift_types : Array[Gift.Type] = []

var num_attempts := 0
var failed := false

func generate() -> void:
	num_attempts += 1
	failed = false
	
	var grid := MapGrid.new()
	grid.size = MAP_SIZE
	grid.create()
	
	var num_buildings := NUM_BUILDINGS
	var possible_types = Gift.Type.values()
	if num_buildings < possible_types.size():
		possible_types = possible_types.slice(0, num_buildings)
	
	var all_types_buildings := []
	while all_types_buildings.size() < num_buildings:
		all_types_buildings += possible_types
	all_types_buildings.shuffle()
	
	for i in range(num_buildings):
		var size := get_random_building_size()
		var positions := grid.get_valid_cells_for(size, GridCell.ContentType.BUILDING)
		
		# if it's just too big to place, shrink and use that
		if positions.size() <= 0:
			size = Vector3.ONE
			positions = grid.get_valid_cells_for(size, GridCell.ContentType.BUILDING)
		
		var pos : Vector2i = positions.pick_random().pos
		
		# now make the buildings higher at the back (generally)
		size.y = get_height_from_ratio(grid.get_front_back_ratio(pos))
		
		# add all this to the array
		building_positions.append(pos)
		building_sizes.append(size)
		building_types.append(all_types_buildings.pop_back())
		
		# mark all filled buildings
		var all_cells_filled := grid.get_square_around(pos, Vector2i(size.x, size.z))
		for cell in all_cells_filled:
			cell.set_content(GridCell.ContentType.BUILDING)
		
		# forbid anything in straight line in front of us
		var cells_in_front := grid.get_cells_along_line(pos, Vector2.UP)
		for cell in cells_in_front:
			cell.forbid_content(GridCell.ContentType.BUILDING)
	
	var num_gifts := NUM_BUILDINGS * NUM_GIFTS_FACTOR
	var all_types = []
	while all_types.size() < num_gifts:
		all_types += possible_types
	all_types.shuffle()
	
	var positions_possible_gifts := grid.get_all_cells_for_content(GridCell.ContentType.GIFT)
	positions_possible_gifts.shuffle()
	
	for i in range(num_gifts):
		var pos : Vector2i = positions_possible_gifts.pop_back().pos
		var type : Gift.Type = all_types.pop_back()
		gift_positions.append(Vector3(pos.x, get_random_height(), pos.y))
		gift_types.append(type)
		grid.get_cell_at(pos).set_content(GridCell.ContentType.GIFT)

func get_random_height() -> float:
	return get_height_from_ratio(randf())

func get_size() -> Vector2i:
	return MAP_SIZE

func get_bounds() -> Vector3:
	return Vector3(MAP_SIZE.x, BUILDING_HEIGHT_MAX, MAP_SIZE.y)

func get_height_from_ratio(ratio:float) -> float:
	return ceil(lerp(BUILDING_HEIGHT_MIN, BUILDING_HEIGHT_MAX, ratio))

func get_random_building_size() -> Vector3:
	var x : float = randi_range(1,3)
	var y : float = get_random_height()
	var z : float = randi_range(1,3)
	return Vector3(x, y, z)

func count_buildings() -> int:
	return building_positions.size()

func count_gifts() -> int:
	return gift_positions.size()
