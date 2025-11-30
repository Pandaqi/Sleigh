extends RigidBody3D
class_name Gift

enum Type
{
	SQUARE,
	CIRCLE,
	TRIANGLE
}

enum State
{
	NONE,
	FREE,
	SLEIGH
}

var type := Type.SQUARE
var state := State.NONE

@export var col_shape : CollisionShape3D
@export var sprite : Sprite3D
@export var map_data : MapData

@export var module_mini_map : ModuleMiniMap

func _ready() -> void:
	change_state(State.FREE)

func set_type(tp:Type) -> void:
	type = tp
	# @TODO: set sprite frame

func is_grabbable() -> bool:
	return state == State.FREE

func change_state(s:State) -> void:
	var already_set := state == s
	if already_set: return
	
	state = s
	freeze = (state == State.FREE)

func kill(good := false) -> void:
	# @TODO: animate/tween/react more
	map_data.gifts.erase(self)
	queue_free()
