extends Node2D
class_name MiniMap

const SIZE := Vector2i(256, 128)

@export var map_data : MapData

func _draw() -> void:
	var map_size := map_data.bounds
	var size_pixels := Vector2(SIZE) 
	var map_scale := size_pixels / Vector2(map_size.x, map_size.z)

	draw_rect(Rect2(-0.5*size_pixels, size_pixels), Color.WHITE, true)

	for b in map_data.buildings:
		draw_rect(b.module_mini_map.get_rect(map_scale), b.module_mini_map.get_color(), true)
	
	var sleigh_mm := map_data.sleigh.module_mini_map
	draw_rect(sleigh_mm.get_rect(map_scale), sleigh_mm.get_color(), true)

func _physics_process(_delta: float) -> void:
	queue_redraw()
