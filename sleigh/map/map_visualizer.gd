extends Node3D
class_name MapVisualizer

@export var building_scene : PackedScene
@export var floor_scene : PackedScene
@export var gift_scene : PackedScene
@export var sleigh_scene : PackedScene
@export var map_data : MapData
@export var ui : UI

func visualize(g:MapGenerator) -> void:
	if map_data.sleigh: map_data.sleigh.queue_free()
	
	var map_size := g.get_size()
	var map_half_size := Vector3(0.5*map_size.x, 0, 0.5*map_size.y)
	var bounds := g.get_bounds()
	map_data.bounds = bounds
	
	# place sleigh
	var sleigh : Sleigh = sleigh_scene.instantiate()
	map_data.sleigh = sleigh
	sleigh.position = g.get_best_sleigh_position() - map_half_size + Vector3(0.5, 0, 0.5)
	sleigh.module_mover.ui_container = ui
	add_child(sleigh)
	
	# solid bg
	#bg.position.z = -2*bounds.z
	#bg.set_scale(Vector3(2.0*bounds.x, 5.0*bounds.y, 1.0))
	
	# floor beneath it all
	var f : Floor = floor_scene.instantiate()
	f.set_size(map_size)
	add_child(f)
	
	# the buildings
	for i in range(g.count_buildings()):
		var b : Building = building_scene.instantiate()
		var pos := g.building_positions[i]
		var size := g.building_sizes[i]
		# need to compensate for fact sprite/col_shape is always centered
		b.position = Vector3(pos.x + 0.5*size.x, 0, pos.y + 0.5*size.z) - map_half_size
		b.set_type(g.building_types[i])
		b.set_size(size)
		add_child(b)
		map_data.buildings.append(b)
	
	# the gifts
	var gift_size := 0.5 # @TODO: Global.config.gift_size
	for i in range(g.count_gifts()):
		var gift : Gift = gift_scene.instantiate()
		var raw_pos := g.gift_positions[i] - map_half_size
		gift.position = randomize_position_within_cell(raw_pos)
		gift.set_size(gift_size)
		gift.set_type(g.gift_types[i])
		add_child(gift)
		map_data.gifts.append(gift)
	
	# boundary around the world
	var boundary_positions : Array[Vector3] = [
		Vector3(-0.5*bounds.x, 0, 0), # left
		Vector3(0.5*bounds.x, 0, 0), # right
		Vector3(0, 0, -0.5*bounds.z), # back
		Vector3(0, 0, 0.5*bounds.z), # front
		Vector3.ZERO, # bottom
		Vector3(0, bounds.y*2.5, 0), # top
	]
	var boundary_normals : Array[Vector3] = [
		Vector3.RIGHT,
		Vector3.LEFT,
		Vector3.BACK,
		Vector3.FORWARD,
		Vector3.UP,
		Vector3.DOWN
	]
	
	var boundary := StaticBody3D.new()
	for i in range(boundary_positions.size()):
		var shape_node := CollisionShape3D.new()
		shape_node.position = boundary_positions[i]
		
		var shape := WorldBoundaryShape3D.new()
		shape_node.shape = shape
		shape.plane = Plane(boundary_normals[i], 0)
		
		boundary.add_child(shape_node)
	add_child(boundary)

func randomize_position_within_cell(pos:Vector3) -> Vector3:
	return pos + Vector3(randf()-0.5, randf()-0.5, randf()-0.5)
