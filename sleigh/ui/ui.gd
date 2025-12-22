extends CanvasLayer
class_name UI

@export var score : Score
@export var map_data : MapData
@export var game_over_menu : GameOverMenu
@export var audio_victory : AudioStreamPlayer
@export var audio_loss : AudioStreamPlayer

var game_over := false

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
	if game_over: return
	
	print("GAME OVER! Good? ", good)
	game_over = true
	
	if good: audio_victory.play()
	else: audio_loss.play()
	
	map_data.game_over_good = good
	map_data.score = ceili(score.score + Global.config.score_bonus_win)
	map_data.time_played = ceili((Time.get_ticks_msec() - score.time_started) / 1000.0)
	game_over_menu.activate()
