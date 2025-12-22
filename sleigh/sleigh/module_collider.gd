extends Node3D
class_name ModuleCollider

@export var body : RigidBody3D
@export var timer : Timer
@export var audio_bounce : AudioStreamPlayer2D

signal collided(b:Building)

func _ready() -> void:
	timer.wait_time = Global.config.collision_shield_duration
	call_deferred("prepare_body")

func prepare_body() -> void:
	body.contact_monitor = true
	body.max_contacts_reported = 2
	body.body_entered.connect(_on_body_entered)

func _on_body_entered(body_hit:Node) -> void:
	if not (body_hit is Building): return
	_on_hit_building(body_hit)

func _on_hit_building(b:Building) -> void:
	var is_visiting := b.area_contains(body)
	if is_visiting: return
	
	if timer.time_left > 0.03: return
	
	print("Hit building!", b)
	collided.emit(b)
	timer.start()
	audio_bounce.pitch_scale = AudioManager.get_pitch_shift_semitones()
	audio_bounce.play()
