extends Node
class_name ModuleArrows

var arrows : Array[Arrow]

@export var module_input : ModuleInput

func _ready() -> void:
	module_input.pressed.connect(_on_pressed)
	module_input.released.connect(_on_released)

func clear():
	arrows = []

func add(a:Arrow) -> void:
	arrows.append(a)

func _on_pressed() -> void:
	for arrow in arrows:
		arrow._on_pressed()

func _on_released(_dur:float) -> void:
	for arrow in arrows:
		arrow._on_released()
