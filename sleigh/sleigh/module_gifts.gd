extends Node3D
class_name ModuleGifts

var gifts : Array[Gift]

func get_all() -> Array[Gift]:
	return gifts.duplicate()

func collect_gift(g:Gift) -> void:
	gifts.append(g)

func deliver_gifts(arr:Array[Gift]) -> void:
	for gift in arr:
		gifts.erase(gift)
		gift.kill(true)

func drop_random_gift(_b:Building) -> void:
	print("Should drop random gift")
	# @TODO: pick random point nearby (within map bounds, not overlapping any building)
	pass
