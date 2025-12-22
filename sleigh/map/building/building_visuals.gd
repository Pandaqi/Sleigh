extends Node3D
class_name BuildingVisuals

@export var sprite_background : Sprite3D
@export var sprite_type : Sprite3D

@export var part_roof : PackedScene
@export var part_window : PackedScene
@export var part_bricks : PackedScene
@export var part_light : PackedScene

var color : Color
var parts : Array[Sprite3D]

func set_type(tp:Gift.Type) -> void:
	sprite_type.frame = Gift.get_gift_frame_for_type(tp)
	color = Gift.get_gift_color_for_type(tp)

func generate(size:Vector3) -> void:
	generate_background(size)
	generate_interior(size)

func generate_background(size:Vector3) -> void:
	var base_size := 256 / 100.0
	sprite_background.set_scale(Vector3(size.x, size.y, 1.0) / base_size)
	sprite_background.position.z -= 0.5*size.z
	sprite_background.position.y = 0.5*size.y
	sprite_background.modulate = color

func generate_interior(size:Vector3) -> void:
	var grid_cell_size := 0.5
	var grid_size := Vector2i(floori(size.x/grid_cell_size), floori(size.y/grid_cell_size) - 1)
	var base_size := 256 / 100.0
	
	var half_size := -0.5 * size.x + 0.5*grid_cell_size
	var offset_in_front := 0.025 # how much the details are in front of the BG to make sure they're visible
	var z_pos := sprite_background.position.z + offset_in_front
	
	# the scale needed to make one sprite fit exactly on one grid cell
	var base_scale := grid_cell_size / base_size 
	var part_scale_factor := 0.9 # to leave some white space at edge
	
	# roof
	# @NOTE: These are scaled up just so they "extend" a little bit at the edge and leave no gaps + they're not modulated to keep the white "snow" color
	var num_pieces_needed := grid_size.x
	for i in range(num_pieces_needed):
		var part = part_roof.instantiate()
		part.scale = Vector3.ONE * base_scale * 1.2
		part.position = Vector3(half_size + i*grid_cell_size, size.y - 0.5*grid_cell_size, z_pos)
		add_child(part)
	
	# windows/bricks
	var all_locations = []
	for x in range(grid_size.x):
		for y in range(grid_size.y):
			all_locations.append(Vector2i(x,y))
	all_locations.shuffle()
	
	var num_special_elements := floori(randf_range(0.3, 0.6)*all_locations.size())
	
	var light_probability := 0.15
	
	parts = []
	for i in range(num_special_elements):
		var make_window := randf() <= 0.5
		var part
		if make_window: part = part_window.instantiate()
		else: part = part_bricks.instantiate()
		
		part.scale = Vector3.ONE * base_scale * part_scale_factor
		
		var grid_pos : Vector2i = all_locations.pop_back()
		part.position = Vector3(half_size + grid_pos.x*grid_cell_size, grid_pos.y*grid_cell_size + 0.5*grid_cell_size, z_pos)
		part.modulate = color
		add_child(part)
		parts.append(part)
		
		var add_light := make_window and randf() <= light_probability
		if add_light:
			var l = part_light.instantiate()
			l.position = Vector3(part.position.x, part.position.y + 0.375*grid_cell_size, z_pos + 0.03)
			add_child(l)
	
	# make sure type sprite is in center and overlaps all
	sprite_type.position.y = sprite_background.position.y
	sprite_type.position.z = z_pos + 0.06

func _on_collided() -> void:
	for part in parts:
		Global.tween.play_popup_tween(part)
		Global.tween.play_rotate_tween(part, randf_range(0.1, 0.3))
