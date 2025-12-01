extends Node3D
class_name ModuleGifts

var gifts : Array[Gift]
var max_gifts_allowed : int

@export var map_data : MapData

signal collected(g:Gift)
signal delivered(g:Gift)
signal all_delivered()

func _ready() -> void:
	var gift_mass := Global.config.gift_mass
	var gravity := 9.8
	var lift_force := Global.config.sleigh_lift_force
	max_gifts_allowed = floori(lift_force/gravity/gift_mass)

func get_all() -> Array[Gift]:
	return gifts.duplicate()

func count() -> int:
	return gifts.size()

func is_full() -> bool:
	return count() >= max_gifts_allowed

func is_empty() -> bool:
	return count() <= 0

func collect_gift(g:Gift) -> void:
	gifts.append(g)
	collected.emit(g)

func deliver_gifts(arr:Array[Gift]) -> void:
	for gift in arr:
		gifts.erase(gift)
		gift.kill(true)
		delivered.emit(gift)
	
	var num_gifts_left := map_data.gifts.size()
	if num_gifts_left <= 0:
		all_delivered.emit()
