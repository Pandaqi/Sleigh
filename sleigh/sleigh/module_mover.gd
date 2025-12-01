extends Node3D
class_name ModuleMover

@export var body : RigidBody3D
@export var move_force := 10.0 # @TODO: Global.config.sleigh_move_force
@export var lift_force := 25.0 # @TODO: Global.config.sleigh_lift_force
@export var debug_input := true

@export var arrows : Arrows
var ui_container : UI

func _ready() -> void:
	body.mass = 1.0 # @TODO: Global.config.sleigh_mass
	body.damping = 2.3 # @TODO: Global.config.sleigh_damping
	arrows.create(ui_container)

func _physics_process(_delta: float) -> void:
	apply_arrow_input()
	debug_move()

func apply_arrow_input() -> void:
	move(arrows.get_vector())

func move(vec:Vector3) -> void:
	var vec_final := vec * Vector3(move_force, lift_force, move_force) * body.mass
	body.apply_central_force(vec_final)

func debug_move() -> void:
	if not debug_input: return
	if not OS.is_debug_build(): return
	
	var x := Input.get_axis("ui_left", "ui_right")
	var y := Input.get_axis("sleigh_down", "sleigh_up")
	var z := Input.get_axis("ui_up", "ui_down")
	
	body.apply_central_force(Vector3(x*move_force, y*lift_force, z*move_force))
