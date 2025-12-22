extends RigidBody3D
class_name Gift

enum Type
{
	SQUARE,
	STAR,
	CIRCLE,
	TRIANGLE
}

enum Condition
{
	NONE,
	FREE,
	SLEIGH
}

var type := Type.SQUARE
var state := Condition.NONE

@export var col_shape : CollisionShape3D
@export var visuals : Node3D
@export var sprite : Sprite3D
@export var map_data : MapData

@export var module_mini_map : ModuleMiniMap
@export var audio_positive : AudioStreamPlayer2D

signal state_changed(s:Condition)

static func get_gift_frame_for_type(tp:Type) -> int:
	if tp == Type.SQUARE: return 0
	if tp == Type.STAR: return 1
	if tp == Type.CIRCLE: return 2
	if tp == Type.TRIANGLE: return 3
	return -1

static func get_gift_color_for_type(tp:Type) -> Color:
	if tp == Type.SQUARE: return Color.RED
	if tp == Type.STAR: return Color.YELLOW
	if tp == Type.CIRCLE: return Color.BLUE
	if tp == Type.TRIANGLE: return Color.GREEN
	return Color.PURPLE

func _ready() -> void:
	mass = Global.config.gift_mass
	change_state(Condition.FREE)

func set_size(s:float) -> void:
	var random_size_modification := randf_range(-1,1) * 0.33 * s
	s += random_size_modification
	
	var base_size := 256.0 / 100.0
	visuals.set_scale(s / base_size * Vector3.ONE)
	
	var new_shape := BoxShape3D.new()
	new_shape.size = s * Vector3.ONE
	col_shape.shape = new_shape
	
	module_mini_map.set_size(s * Vector3.ONE)

func set_type(tp:Type) -> void:
	type = tp
	sprite.frame = get_gift_frame_for_type(tp)

func is_grabbable() -> bool:
	return state == Condition.FREE

func is_in_sleigh() -> bool:
	return state == Condition.SLEIGH

func change_state(s:Condition) -> void:
	var already_set := state == s
	if already_set: return
	
	state = s
	freeze = (state == Condition.FREE)
	state_changed.emit(state)

func _on_grabbed() -> void:
	Global.tween.play_popup_tween(visuals)
	audio_positive.pitch_scale = AudioManager.get_pitch_shift_semitones()
	audio_positive.play()

func kill(_good := false) -> void:
	col_shape.set_deferred("enabled", false)
	map_data.gifts.erase(self)
	
	var tw : Tween = Global.tween.play_popup_tween(visuals)
	await tw
	
	queue_free()
