extends Node3D
class_name Score

var score := 0.0
var time_started := 0.0

var time_last_delivery := 0.0
var num_collisions_since_last_delivery := 0

@export var map_data : MapData
@export var ui : UI

signal changed(s:float)

func _ready() -> void:
	time_started = Time.get_ticks_msec()
	
	var sleigh := map_data.sleigh
	sleigh.module_delivery.delivered.connect(_on_gifts_delivered)
	sleigh.module_collider.collided.connect(_on_sleigh_collided)

func _on_sleigh_collided(_b:Building) -> void:
	num_collisions_since_last_delivery += 1

func _on_gifts_delivered(gifts:Array[Gift], _b:Building) -> void:
	if gifts.size() <= 0: return
	
	var score_change := Global.config.score_per_gift * gifts.size()
	if num_collisions_since_last_delivery > 0:
		score_change /= Global.config.score_penalty_per_collision * num_collisions_since_last_delivery
	
	var time_since_last_delivery := (Time.get_ticks_msec() - time_last_delivery) / 1000.0
	var time_ratio := clampf(time_since_last_delivery / Global.config.max_time_between_deliveries, 0.0, 1.0)
	score_change *= lerpf(1.0, Global.config.score_time_bonus, time_ratio)
	
	score_change = ceilf(maxf(score_change, 1))
	
	change_score(score_change)
	
	num_collisions_since_last_delivery = 0
	time_last_delivery = Time.get_ticks_msec()

func change_score(ds:float) -> void:
	score = clampf(score + ds, 0.0, INF)
	changed.emit(score)
