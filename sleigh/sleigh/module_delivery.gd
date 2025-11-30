extends Node3D
class_name ModuleDelivery

signal visited(b:Building)
signal delivered(b:Building)

@export var module_gifts : ModuleGifts

func get_matching_gifts(all_gifts:Array[Gift], b:Building) -> Array[Gift]:
	return all_gifts.filter(func(g): return g.type == b.type_wanted)

func _on_visit_building(b:Building) -> void:
	print("Visited building! ", b)
	visited.emit(b)
	
	var matching_gifts := get_matching_gifts(module_gifts.get_all(), b)
	if matching_gifts.size() <= 0: return
	
	module_gifts.deliver_gifts(matching_gifts)
	# @TODO: score points??
	delivered.emit(b)
