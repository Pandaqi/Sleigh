extends Resource
class_name MapData

var bounds : Vector3
var buildings : Array[Building]
var gifts : Array[Gift]
var sleigh : Sleigh

var score : int = 0
var time_played : int = 0
var win := false

func reset() -> void:
	buildings = []
	gifts = []
	sleigh = null
