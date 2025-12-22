extends Resource
class_name MapData

var bounds : Vector3
var buildings : Array[Building]
var gifts : Array[Gift]
var gifts_to_deliver := 0
var sleigh : Sleigh

func reset() -> void:
	buildings = []
	gifts = []
	sleigh = null
