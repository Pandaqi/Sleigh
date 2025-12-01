class_name MapBoundaries extends Node2D

@onready var top_left := $TopLeft
@onready var bottom_right := $BottomRight

@export var use_physics := false

func _ready() -> void:
	create_bodies()

func set_top_left(pos:Vector2) -> void:
	top_left.set_position(pos)

func set_bottom_right(pos:Vector2) -> void:
	bottom_right.set_position(pos)

func create_bodies() -> void:
	if not use_physics: return
	var bds := get_bounds()
	
	var positions := [
		bds.position, bds.position,
		bds.end, bds.end
	]
	
	var vectors := [
		Vector2.RIGHT, Vector2.DOWN,
		Vector2.LEFT, Vector2.UP
	]
	
	var mat := PhysicsMaterial.new()
	mat.bounce = 1
	mat.friction = 1
	
	for i in range(4):
		var body := StaticBody2D.new()
		body.physics_material_override = mat
		body.global_position = positions[i]
		add_child(body)
		
		var shp := CollisionShape2D.new()
		body.add_child(shp)
		
		var shp_bds := WorldBoundaryShape2D.new()
		shp.shape = shp_bds
		
		shp_bds.normal = vectors[i]

func get_bounds() -> Rect2:
	return Rect2(top_left.global_position, bottom_right.global_position - top_left.global_position)
