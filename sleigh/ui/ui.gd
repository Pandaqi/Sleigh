extends CanvasLayer
class_name UI

@export var score : Score
@export var map_data : MapData
@export var game_over_menu : GameOverMenu
@export var audio_victory : AudioStreamPlayer
@export var audio_loss : AudioStreamPlayer

@export var margin_container : MarginContainer
@export var background_node : TextureRect
@export var minimap_node : Control
@export var health_node : HBoxContainer
@export var overlay_node : TextureRect

@export var score_label : Label
@export var score_progress : TextureProgressBar
@export var health_label : Label
@export var health_progress : TextureProgressBar

@export var game_over_data : GameOverDataCustom

var game_over := false

func _ready() -> void:
	score.changed.connect(_on_score_changed)
	
	update_visibility_for_mode()
	
	var sleigh := map_data.sleigh
	sleigh.module_health.depleted.connect(_on_health_depleted)
	sleigh.module_gifts.all_delivered.connect(_on_all_gifts_delivered)
	sleigh.module_health.changed.connect(_on_health_changed)
	
	_on_health_changed(1.0)
	_on_score_changed(0.0)

func update_visibility_for_mode() -> void:
	var is_3d := Global.config.in_mode_3d()
	background_node.set_visible(is_3d)
	minimap_node.set_visible(is_3d)
	health_node.set_visible(is_3d)
	overlay_node.set_visible(is_3d)
	
	if not is_3d:
		margin_container.custom_minimum_size = 2.0*Vector2(256, 128) + 2.0*Vector2(16, 16)
		score_progress.custom_minimum_size = 2.0 * Vector2(136, 12)
		score_label.add_theme_font_size_override("font_size", 18)
		score_label.custom_minimum_size = Vector2(42, 0)

func _on_health_depleted() -> void:
	goto_game_over(false)

func _on_all_gifts_delivered() -> void:
	goto_game_over(true)

func _on_health_changed(h:float) -> void:
	var health : int = clampi(floori(h * 100.0), 0, 99)
	health_label.set_text(str(health))
	health_progress.value = health

func _on_score_changed(s:float) -> void:
	var max_score_displayed := 9999 if Global.config.in_mode_2d() else 99
	var score_safe := clampi(floori(s), 0, max_score_displayed)
	score_label.set_text(str(score_safe))
	score_progress.value = get_progress_to_objective_ratio() * 100.0

func get_progress_to_objective_ratio() -> float:
	var num_gifts := map_data.gifts_to_deliver
	if num_gifts <= 0: return 0
	var val := map_data.sleigh.module_gifts.num_delivered / float(num_gifts)
	return clamp(val, 0.0, 1.0)

func goto_game_over(good := false) -> void:
	if game_over: return
	
	print("GAME OVER! Good? ", good)
	game_over = true
	
	if good: audio_victory.play()
	else: audio_loss.play()
	
	var win_bonus := Global.config.score_bonus_win if good else 0.0
	var final_score := ceili(score.score + win_bonus)
	
	game_over_data.game_over_good = good
	game_over_data.score = final_score
	game_over_data.time_played = floori((Time.get_ticks_msec() - score.time_started) / 1000.0)
	game_over_data.gifts_delivered = map_data.sleigh.module_gifts.num_delivered
	
	game_over_menu.activate()
