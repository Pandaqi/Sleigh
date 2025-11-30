extends StaticBody3D
class_name Building

@export var col_shape : CollisionShape3D
@export var sprite : Sprite3D
@export var module_mini_map : ModuleMiniMap
var size : Vector3

@export var area_node : Area3D
@export var area_shape : CollisionShape3D
@export var area_thickness := 0.15

var type_wanted := Gift.Type.SQUARE

func _ready() -> void:
	set_size(size)
	area_node.body_entered.connect(_on_body_entered)

func set_type(tp:Gift.Type) -> void:
	type_wanted = tp
	# @TODO: update frame

func set_size(s:Vector3) -> void:
	size = s
	
	var shape := BoxShape3D.new()
	shape.size = s
	col_shape.shape = shape
	col_shape.position.y = 0.5*s.y
	
	var base_size := 128 / 100.0
	sprite.set_scale(Vector3(s.x, s.y, 1.0) / base_size)
	sprite.position.z -= 0.5*s.z
	sprite.position.y = 0.5*s.y
	
	module_mini_map.set_size(s)
	
	area_node.position.y = s.y + 0.5*area_thickness
	var shape_area := BoxShape3D.new()
	shape_area.size = Vector3(s.x, area_thickness, s.z)
	area_shape.shape = shape_area

func _on_body_entered(body:Node) -> void:
	if not (body is Sleigh): return
	body.module_delivery._on_visit_building(self)

func area_contains(body:PhysicsBody3D) -> bool:
	return area_node.get_overlapping_bodies().has(body)
