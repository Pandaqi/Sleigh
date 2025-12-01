extends Node3D
class_name Floor

@export var sprite : Sprite3D
@export var thickness := 0.5
@export var map_data : MapData

@export var area : Area3D
@export var col_shape : CollisionShape3D
var damage_per_second := 0.1

func _physics_process(delta: float) -> void:
	damage_sleigh_if_here(delta)

func set_size(s:Vector2i) -> void:
	var base_scale := 128.0 / 100.0
	var sprite_scale := Vector3(s.x, thickness, 0) / base_scale
	sprite.set_scale(sprite_scale)
	sprite.position.y = -0.5*thickness
	
	# @NOTE: we purposely don't move this one to be lower, because we WANT the area to stick out a little bit so it can register the sleigh landing on/near the floor
	var new_shape := BoxShape3D.new()
	new_shape.size = Vector3(s.x, thickness, s.y)
	col_shape.shape = new_shape

func damage_sleigh_if_here(delta: float) -> void:
	var sleigh_is_here := area.get_overlapping_bodies().find(map_data.sleigh) != -1
	if not sleigh_is_here: return
	
	# @TODO: if not Global.config.floor_is_lava: return
	
	var damage := damage_per_second * delta
	map_data.sleigh.module_health.change(-damage)
