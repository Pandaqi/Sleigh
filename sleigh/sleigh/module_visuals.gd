extends Node3D
class_name ModuleVisuals

@export var body : Sleigh
@export var module_health : ModuleHealth
@export var module_collider : ModuleCollider
@export var anim_player : AnimationPlayer
@export var sprite : Sprite3D
@export var particles_move : CPUParticles3D

func _ready() -> void:
	module_health.changed.connect(_on_health_changed)
	module_collider.collided.connect(_on_collided)

func _physics_process(_delta:float) -> void:
	make_visuals_match_speed()

func make_visuals_match_speed() -> void:
	var vel := body.linear_velocity
	sprite.flip_h = vel.x < 0
	particles_move.emitting = vel.length() > 0.5

func _on_health_changed(_h:float) -> void:
	if anim_player.is_playing(): return
	anim_player.play("damage")

func _on_collided(b:Building) -> void:
	Global.tween.play_popup_tween(sprite)
	b._on_collided()
