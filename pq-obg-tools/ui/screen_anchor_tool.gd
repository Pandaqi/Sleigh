class_name ScreenAnchorTool extends Node2D

enum Anchor
{
	CENTER,
	TOP,
	RIGHT,
	BOTTOM,
	LEFT,
	CORNERS
}

var anchor := Anchor.CENTER
var element_size := Vector2(128, 128)
var element_scale := 1.0
var margin := Vector2.ZERO
var elements : Array = []

func _init(a:Anchor, s := Vector2(128,128), sc := 1.0, m := Vector2.ZERO) -> void:
	anchor = a
	element_size = s
	element_scale = sc
	margin = m

func set_control_node(c:Control) -> void:
	c.set_anchors_preset(get_control_preset(), false)

func _ready() -> void:
	get_tree().get_root().size_changed.connect(refresh)
	refresh()

func refresh() -> void:
	show_elements(elements)

func show_elements(new_elements:Array) -> void:
	for elem in elements:
		elem.hide()
	
	var num := new_elements.size()
	var positions := get_element_positions(num)
	for i in range(num):
		var elem : Node2D = new_elements[i]
		elem.show()
		elem.set_scale(Vector2.ONE * element_scale)
		elem.set_position(positions[i])

func get_offset_per_element() -> Vector2:
	return element_size * element_scale

func get_anchor_pos() -> Vector2:
	var vp_size := get_viewport().get_visible_rect().size
	
	if anchor == Anchor.CENTER:
		return 0.5 * vp_size
	if anchor == Anchor.TOP:
		return Vector2(0.5*vp_size.x, margin.y)
	if anchor == Anchor.BOTTOM:
		return Vector2(0.5*vp_size.x, vp_size.y - margin.y)
	if anchor == Anchor.LEFT:
		return Vector2(margin.x, 0.5*vp_size.y)
	if anchor == Anchor.RIGHT:
		return Vector2(vp_size.x - margin.x, 0.5*vp_size.y)
	return Vector2.ZERO

func get_layout_direction() -> Vector2:
	if anchor == Anchor.TOP or anchor == Anchor.BOTTOM or anchor == Anchor.CENTER:
		return Vector2.RIGHT
	if anchor == Anchor.LEFT or anchor == Anchor.RIGHT:
		return Vector2.DOWN
	return Vector2.ZERO

func get_element_positions(num:int) -> Array[Vector2]:
	# corners are unique case
	if anchor == Anchor.CORNERS:
		return get_anchor_positions_corners(num)
	
	# the others are just a basic centered list around a point
	var anchor_pos := get_anchor_pos()
	var layout_dir := get_layout_direction()
	
	var offset_per_element := get_offset_per_element()
	var global_offset := -0.5 * (num - 1) * (offset_per_element * layout_dir)
	
	var arr : Array[Vector2] = []
	for i in range(num):
		arr.append(anchor_pos + global_offset + i * offset_per_element * layout_dir)
	return arr

func get_anchor_positions_corners(num:int) -> Array[Vector2]:
	var vp_size := get_viewport().get_visible_rect().size
	var arr : Array[Vector2] = [
		margin,
		Vector2(vp_size.x - margin.x, margin.y),
		vp_size - margin,
		Vector2(margin.x, vp_size.y - margin.y)
	]
	return arr.slice(0, num)

func get_control_preset() -> Control.LayoutPreset:
	if anchor == Anchor.CENTER: return Control.PRESET_CENTER
	if anchor == Anchor.LEFT: return Control.PRESET_LEFT_WIDE
	if anchor == Anchor.RIGHT: return Control.PRESET_RIGHT_WIDE
	if anchor == Anchor.TOP: return Control.PRESET_TOP_WIDE
	if anchor == Anchor.BOTTOM: return Control.PRESET_BOTTOM_WIDE
	if anchor == Anchor.CORNERS: return Control.PRESET_TOP_LEFT
	return Control.PRESET_CENTER
