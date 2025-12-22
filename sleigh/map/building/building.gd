extends StaticBody3D
class_name Building

@export var col_shape : CollisionShape3D
@export var module_mini_map : ModuleMiniMap
var size : Vector3

@export var area_node : Area3D
@export var area_shape : CollisionShape3D
@export var area_thickness := 0.15

@export var particles_visit : CPUParticles3D
@export var visuals : BuildingVisuals

var type_wanted := Gift.Type.SQUARE

func _ready() -> void:
	area_node.body_entered.connect(_on_body_entered)

func set_type(tp:Gift.Type) -> void:
	type_wanted = tp
	visuals.set_type(tp)

func set_size(s:Vector3) -> void:
	size = s
	
	var shape := BoxShape3D.new()
	shape.size = s
	col_shape.shape = shape
	col_shape.position.y = 0.5*s.y
	
	module_mini_map.set_size(s)
	
	area_node.position.y = s.y + 0.5*area_thickness
	var shape_area := BoxShape3D.new()
	shape_area.size = Vector3(s.x, area_thickness, s.z)
	area_shape.shape = shape_area
	
	particles_visit.position = area_node.position
	
	visuals.generate(size)

func _on_body_entered(body:Node) -> void:
	if not (body is Sleigh): return
	body.module_delivery._on_visit_building(self)
	particles_visit.emitting = true

func area_contains(body:PhysicsBody3D) -> bool:
	return area_node.get_overlapping_bodies().has(body)

func _on_collided() -> void:
	visuals._on_collided()
