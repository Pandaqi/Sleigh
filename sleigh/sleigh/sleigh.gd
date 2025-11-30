extends RigidBody3D
class_name Sleigh

@export var move_force := 10.0
@export var lift_force := 25.0
@export var debug_input := true
@export var module_mini_map : ModuleMiniMap

func _input(_ev:InputEvent) -> void:
	pass

func _physics_process(_delta: float) -> void:
	debug_move()

func debug_move() -> void:
	if not debug_input: return
	if not OS.is_debug_build(): return
	
	var x := Input.get_axis("ui_left", "ui_right")
	var y := Input.get_axis("sleigh_down", "sleigh_up")
	var z := Input.get_axis("ui_up", "ui_down")
	
	apply_central_force(Vector3(x*move_force, y*lift_force, z*move_force))
