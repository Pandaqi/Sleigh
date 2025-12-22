extends Node3D
class_name ModuleMover

@export var body : RigidBody3D
@export var debug_input := true
@export var audio_bells : AudioStreamPlayer2D

@export var arrows : Arrows
var ui_container : UI

var move_force := Global.config.sleigh_move_force
var lift_force := Global.config.sleigh_lift_force

func _ready() -> void:
	body.mass = Global.config.sleigh_mass
	body.linear_damp = Global.config.sleigh_damping
	arrows.create(ui_container)

func _physics_process(_delta: float) -> void:
	apply_arrow_input()
	debug_move()

func apply_arrow_input() -> void:
	move(arrows.get_vector())

func move(vec:Vector3) -> void:
	var vec_final := vec * Vector3(move_force, lift_force, move_force) * body.mass
	body.apply_central_force(vec_final)
	
	var vel := body.linear_velocity
	var speed := vel.length()
	if speed > 0.5 and not audio_bells.playing:
		audio_bells.volume_db = lerpf(-9, 0, clamp(speed / 10.0, 0.0, 1.0))
		audio_bells.pitch_scale = AudioManager.get_pitch_shift_semitones()
		audio_bells.play()

func debug_move() -> void:
	if not debug_input: return
	if not OS.is_debug_build(): return
	
	var x := Input.get_axis("ui_left", "ui_right")
	var y := Input.get_axis("sleigh_down", "sleigh_up")
	var z := Input.get_axis("ui_up", "ui_down")
	
	body.apply_central_force(Vector3(x*move_force, y*lift_force, z*move_force))
