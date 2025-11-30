extends Node3D
class_name ModuleCollider

@export var body : RigidBody3D

signal collided(b:Building)

func _ready() -> void:
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
	
	print("Hit building!", b)
	collided.emit(b)
