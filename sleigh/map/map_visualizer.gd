extends Node3D
class_name MapVisualizer

@export var building_scene : PackedScene
@export var floor_scene : PackedScene
@export var map_data : MapData
@export var sleigh : Sleigh
@export var bg : Sprite3D

func visualize(g:MapGenerator) -> void:
	var map_size := g.get_size()
	var map_half_size := Vector3(0.5*map_size.x, 0, 0.5*map_size.y)
	var bounds := g.get_bounds()
	map_data.bounds = bounds
	map_data.sleigh = sleigh
	
	# solid bg
	bg.position.z = -1.5*bounds.z
	bg.set_scale(Vector3(2.0*bounds.x, 5.0*bounds.y, 1.0))
	
	# floor beneath it all
	var f : Floor = floor_scene.instantiate()
	f.set_size(map_size)
	add_child(f)
	
	# the buildings
	for i in range(g.count_buildings()):
		var b : Building = building_scene.instantiate()
		var pos := g.building_positions[i]
		b.position = Vector3(pos.x, 0, pos.y) - map_half_size
		b.set_size(g.building_sizes[i])
		add_child(b)
		map_data.buildings.append(b)
	
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
	
	
	
	
