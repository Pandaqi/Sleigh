extends Node2D
class_name Arrow

var vec : Vector3
var is_pressed := false

@export var sprite : Sprite2D

func _ready() -> void:
	_on_released()

func set_vector(v:Vector3) -> void:
	vec = v

func get_vector() -> Vector3:
	if not is_pressed: return Vector3.ZERO
	return vec

func _on_pressed() -> void:
	is_pressed = true
	sprite.modulate.a = 1.0

func _on_released() -> void:
	is_pressed = false
	sprite.modulate.a = 0.4
