extends StaticBody3D
class_name Building

@export var col_shape : CollisionShape3D
@export var sprite : Sprite3D
@export var module_mini_map : ModuleMiniMap
var size : Vector3

func _ready() -> void:
	set_size(size)

func set_size(s:Vector3) -> void:
	size = s
	
	var shape := BoxShape3D.new()
	shape.size = s
	col_shape.shape = shape
	col_shape.position.y = 0.5*s.y
	
	var base_size := 128 / 100.0
	sprite.set_scale(Vector3(s.x, s.y, 0) / base_size)
	sprite.position.y = 0.5*s.y
	
	module_mini_map.set_size(s)
