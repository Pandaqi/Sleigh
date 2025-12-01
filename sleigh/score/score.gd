extends Node3D
class_name Score

var score := 0.0
var time_started := 0.0

var time_last_delivery := 0.0
var num_collisions_since_last_delivery := 0

const MAX_TIME_BETWEEN_DELIVERIES := 10.0
const TIME_BONUS := 3.0
const PENALTY_PER_COLLISION := 2.0 # divides by this
const SCORE_PER_GIFT := 10.0

@export var map_data : MapData
@export var ui : UI

signal changed(s:float)

func _ready() -> void:
	time_started = Time.get_ticks_msec()
	
	var sleigh := map_data.sleigh
	sleigh.module_delivery.delivered.connect(_on_gifts_delivered)
	sleigh.module_collider.collided.connect(_on_sleigh_collided)

func _on_sleigh_collided(b:Building) -> void:
	num_collisions_since_last_delivery += 1

func _on_gifts_delivered(gifts:Array[Gift], b:Building) -> void:
	var score_change := SCORE_PER_GIFT * gifts.size()
	score_change /= PENALTY_PER_COLLISION * num_collisions_since_last_delivery
	
	var time_since_last_delivery := (Time.get_ticks_msec() - time_last_delivery) / 1000.0
	var time_ratio : float = clamp(time_since_last_delivery / MAX_TIME_BETWEEN_DELIVERIES, 0.0, 1.0)
	score_change *= lerp(1.0, TIME_BONUS, time_ratio)
	
	score_change = ceil(max(score_change, 1))
	
	change_score(score_change)
	
	num_collisions_since_last_delivery = 0
	time_last_delivery = Time.get_ticks_msec()

func change_score(ds:float) -> void:
	score = clamp(score + ds, 0.0, INF)
	changed.emit(score)
