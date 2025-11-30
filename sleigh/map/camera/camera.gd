extends Camera3D

@export var map_data : MapData
@export var zoom_speed := 8.0
@export var move_speed := 8.0
@export var size_margin := 1.0

func _process(delta: float) -> void:
	var bounds := map_data.bounds
	if not bounds: return
	
	# @NOTE: keep_aspect is set to keep_width, so X is leading
	var vp := get_viewport().get_visible_rect().size
	var height_width_ratio := vp.x / vp.y
	var desired_size_x := bounds.x
	var desired_size_y := height_width_ratio * bounds.y
	var desired_size : float = max(desired_size_x, desired_size_y) + size_margin
	size = desired_size
	
	var desired_position := Vector3(0, 0.5*size*(1.0/height_width_ratio), 5.0*bounds.z)
	position = desired_position
