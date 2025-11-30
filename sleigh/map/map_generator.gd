extends Node3D
class_name MapGenerator

const MAP_SIZE := Vector2i(20, 10)
const NUM_BUILDINGS := 10

const CELL_SIZE := 1.0
const HEIGHT_INCREMENTS := 1.0
const BUILDING_SIZE_MIN := 0.5
const BUILDING_SIZE_MAX := 2.0
const BUILDING_HEIGHT_MIN := 1.0
const BUILDING_HEIGHT_MAX := 5.0

var building_positions : Array[Vector2] = []
var building_sizes : Array[Vector3] = []

var num_attempts := 0
var failed := false

func generate() -> void:
	num_attempts += 1
	failed = false
	
	for i in range(NUM_BUILDINGS):
		var pos := get_random_pos_nice()
		var size := get_random_size_nice()
		building_positions.append(pos)
		building_sizes.append(size)

func get_size() -> Vector2i:
	return MAP_SIZE

func get_bounds() -> Vector3:
	return Vector3(MAP_SIZE.x, BUILDING_HEIGHT_MAX, MAP_SIZE.y)

func get_random_pos() -> Vector2:
	return Vector2(MAP_SIZE) * Vector2(randf(), randf())

func get_random_pos_nice() -> Vector2:
	var pos := get_random_pos()
	pos.x = floor(pos.x / CELL_SIZE) * CELL_SIZE
	pos.y = floor(pos.y / CELL_SIZE) * CELL_SIZE
	return pos

func get_random_size() -> Vector3:
	var x : float = lerp(BUILDING_SIZE_MIN, BUILDING_SIZE_MAX, randf())
	var z : float = lerp(BUILDING_SIZE_MIN, BUILDING_SIZE_MAX, randf())
	var y : float = lerp(BUILDING_HEIGHT_MIN, BUILDING_HEIGHT_MAX, randf())
	return Vector3(x, y, z)

func get_random_size_nice() -> Vector3:
	var s := get_random_size()
	s.x = ceil(s.x / CELL_SIZE) * CELL_SIZE
	s.z = ceil(s.z / CELL_SIZE) * CELL_SIZE
	s.y = ceil(s.y / HEIGHT_INCREMENTS) * HEIGHT_INCREMENTS
	return s

func count_buildings() -> int:
	return building_positions.size()
