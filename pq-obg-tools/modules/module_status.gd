class_name ModuleStatus extends Node2D

var alive := false
var team := -1

@onready var entity = get_parent()
@export var input : ModuleInput
@export var free_on_death := true

signal revived()
signal died()

func get_id() -> String:
	if not input: return ""
	return input.button.get_input_map_key()

func set_team(t:int) -> void:
	team = t

func get_team() -> int:
	return team

func revive() -> void:
	set_alive(true)

func die() -> void:
	set_alive(false)
	
	if free_on_death:
		input.player_data.remove_player(entity)
		entity.queue_free()

func set_alive(val:bool) -> void:
	alive = val
	
	if not val: died.emit()
	else: revived.emit()
