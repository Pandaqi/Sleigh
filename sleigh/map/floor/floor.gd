extends Node3D
class_name Floor

@export var sprite : Sprite3D
@export var thickness := 0.5

func set_size(s:Vector2i) -> void:
	var base_scale := 128.0 / 100.0
	var sprite_scale := Vector3(s.x, thickness, 0) / base_scale
	sprite.set_scale(sprite_scale)
	sprite.position.y = -0.5*thickness
