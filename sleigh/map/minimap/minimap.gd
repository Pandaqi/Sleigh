extends Node2D
class_name MiniMap

const SIZE := Vector2i(192, 96)
const EDGE_MARGIN := 16

const MIN_ELEMENT_SIZE := 12.0
const MAX_ELEMENT_SIZE := 96.0

var top_left_world : Vector3
var bottom_right_world : Vector3

@export var map_data : MapData
@export var texture_assets : Texture

func _ready() -> void:
	get_viewport().size_changed.connect(_on_size_changed)
	_on_size_changed()
	set_visible(Global.config.in_mode_3d())

func _draw() -> void:
	var map_size := map_data.bounds
	var size_pixels := Vector2(SIZE) 
	var map_scale := size_pixels / Vector2(map_size.x, map_size.z)
	
	# BG
	var border_radius := 8
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(border_radius)
	style_box.bg_color = Color.WHITE
	draw_style_box(style_box, Rect2(-0.5*size_pixels, size_pixels))
	
	# BUILDINGS: rect for size, icon for type
	for b in map_data.buildings:
		draw_rect_rounded(b.module_mini_map, map_scale)
		draw_asset_texture(b.module_mini_map, map_scale, b.type_wanted)
	
	# GIFTS: type only --> @TODO: or just go back to vague circles?
	for g in map_data.gifts:
		if g.is_in_sleigh(): continue
		draw_asset_texture(g.module_mini_map, map_scale, g.type)
	
	# SLEIGH
	draw_rect_rounded(map_data.sleigh.module_mini_map, map_scale, true)

func draw_asset_texture(m:ModuleMiniMap, map_scale:Vector2, type: Gift.Type) -> void:
	var rect := m.get_rect(map_scale)
	var scale_down_factor := 0.8
	var min_size := minf(rect.size.x, rect.size.y)*scale_down_factor
	min_size = clampf(min_size, MIN_ELEMENT_SIZE, MAX_ELEMENT_SIZE)
	var square_size : Vector2 = min_size*Vector2.ONE
	var square_pos : Vector2 = rect.position + 0.5*rect.size - 0.5*square_size
	var rect_square := Rect2(square_pos, square_size)
	
	var rect_source := Rect2(Vector2(type*256.0, 0), Vector2(256, 256))
	draw_texture_rect_region(texture_assets, rect_square, rect_source)

func draw_rect_rounded(m:ModuleMiniMap, map_scale:Vector2, shadow := false) -> void:
	var border_radius := 4
	var style_box = StyleBoxFlat.new()
	style_box.set_corner_radius_all(border_radius)
	style_box.bg_color = m.get_color()
	
	if shadow:
		style_box.shadow_size = 3.0
		style_box.shadow_color = Color.from_hsv(0, 0, 0, 0.45)
		style_box.shadow_offset = Vector2.ZERO
	
	draw_style_box(style_box, m.get_rect(map_scale))

func _physics_process(delta: float) -> void:
	check_sleigh_behind_us(delta)
	queue_redraw()

func check_sleigh_behind_us(delta: float) -> void:
	if not map_data.sleigh: return
	var sleigh_pos := map_data.sleigh.global_position
	# @NOTE: y is flipped because 2D y goes _down_ and 3D y goes _up_
	var is_behind := sleigh_pos.x > top_left_world.x and sleigh_pos.x < bottom_right_world.x and sleigh_pos.y < top_left_world.y and sleigh_pos.y > bottom_right_world.y
	var target_alpha := 0.33 if is_behind else 1.0
	modulate.a = lerpf(modulate.a, target_alpha, delta*10.0)

func _on_size_changed() -> void:
	var vp := get_viewport().get_visible_rect().size
	var pos := Vector2(0.5*vp.x, 0.5*SIZE.y + EDGE_MARGIN)
	set_position(pos)
	
	var camera := get_viewport().get_camera_3d()
	var top_left_2d := Vector2(pos.x - 0.5*SIZE.x, -SIZE.y)
	top_left_world = camera.project_position(top_left_2d, camera.position.z)
	var bottom_right_2d := Vector2(pos.x + 0.5*SIZE.x, 0)
	bottom_right_world = camera.project_position(bottom_right_2d, camera.position.z)
