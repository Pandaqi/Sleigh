extends Resource
class_name MapData

var bounds : Vector3
var buildings : Array[Building]
var sleigh : Sleigh

func reset() -> void:
	buildings = []
	sleigh = null
