extends Node3D
class_name ModuleMiniMap

@export var color := Color.BLACK
@export var size := Vector3.ONE
@export var custom_scale := 1.0

func set_size(s:Vector3) -> void:
	size = s

func get_color() -> Color:
	return color

func get_rect(rescale:Vector2) -> Rect2:
	var size_2d := Vector2(size.x, size.z) * rescale * custom_scale
	var pos_3d := global_position * Vector3(rescale.x, 1, rescale.y)
	var pos_2d := Vector2(pos_3d.x, pos_3d.z)
	return Rect2(pos_2d - 0.5*size_2d, size_2d)
