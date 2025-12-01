class_name ModuleScore extends Node2D

var score := 0.0
@export var minimum := 0.0
@export var maximum := 999.9

signal changed(new_score:float)

func change(ds:float) -> void:
	score = clamp(score + ds, minimum, maximum)
	changed.emit(score)

func get_score() -> float:
	return score
