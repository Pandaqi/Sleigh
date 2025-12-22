extends Node3D
class_name ModuleHealth

@export var body : RigidBody3D
@export var health := 1.0
@export var max_health := 1.0

signal changed(health:float)
signal depleted()

func _on_collided(_b:Building) -> void:
	var damage_factor := 1.0 / Global.config.collision_damage_factor
	var damage := body.linear_velocity.length() * damage_factor
	change(-damage)

func change(dh:float) -> void:
	if not Global.config.damage_enabled: return
	if Global.config.in_mode_2d() and Global.config.turn_off_damage_in_2d: return
	
	health = clampf(health + dh, 0.0, max_health)
	changed.emit(health)
	
	if health <= 0:
		depleted.emit()
