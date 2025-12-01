extends CanvasLayer
class_name UI

@export var score : Score
@export var map_data : MapData

func _ready() -> void:
	score.changed.connect(_on_score_changed)
	
	var sleigh := map_data.sleigh
	sleigh.module_health.depleted.connect(_on_health_depleted)
	sleigh.module_gifts.all_delivered.connect(_on_all_gifts_delivered)
	sleigh.module_health.changed.connect(_on_health_changed)

func _on_health_depleted() -> void:
	goto_game_over(false)

func _on_all_gifts_delivered() -> void:
	goto_game_over(true)

func _on_health_changed(h:float) -> void:
	pass # @TODO: update UI for this

func _on_score_changed(s:float) -> void:
	pass # @TODO: update UI for this

func goto_game_over(good := false) -> void:
	print("GAME OVER! Good? ", good)
	map_data.score = int(ceil(score.score))
	map_data.time_played = int(ceil((Time.get_ticks_msec() - score.time_started) / 1000.0))
	# @TODO: activate the standard game over menu, reads those map_data entries to display
