extends Node
class_name ModuleArrows

var arrows : Array[Arrow]

@export var module_input : ModuleInput

func _ready() -> void:
	module_input.pressed.connect(_on_pressed)
	module_input.released.connect(_on_released)

func _physics_process(_delta: float) -> void:
	keep_visualizers_with_arrows()

func keep_visualizers_with_arrows() -> void:
	var visualizers := module_input.button_visualizers
	var offset_from_arrow := 32.0
	for i in range(arrows.size()):
		var arrow := arrows[i]
		var vis := visualizers[i]
		vis.rotation = -arrow.global_rotation
		vis.position = Vector2.RIGHT * offset_from_arrow

func clear():
	arrows = []
	module_input.clear_button_visualizers()

func add(a:Arrow) -> void:
	arrows.append(a)
	
	var vis := module_input.add_button_visualizer()
	vis.get_parent().remove_child(vis)
	a.add_child(vis)

func _on_pressed() -> void:
	for arrow in arrows:
		arrow._on_pressed()

func _on_released(_dur:float) -> void:
	for arrow in arrows:
		arrow._on_released()
