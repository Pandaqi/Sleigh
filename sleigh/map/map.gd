extends Node3D
class_name Map

@export var generator : MapGenerator
@export var visualizer : MapVisualizer
@export var map_data : MapData

func _enter_tree() -> void:
	map_data.reset()

func _ready() -> void:
	generator.generate()
	visualizer.visualize(generator)
