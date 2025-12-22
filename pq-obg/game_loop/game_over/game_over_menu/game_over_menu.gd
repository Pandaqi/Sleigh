extends Control
class_name GameOverMenu

@export var label_header : Label
@export var label_explanation : Label
@export var forward_btn : Button
@export var anim_player : AnimationPlayer
@export var overlay : Control

func _ready():
	overlay.modulate.a = Global.config_system.ui_overlay_alpha
	process_mode = Node.PROCESS_MODE_ALWAYS
	set_visible(false)

func activate():
	set_visible(true)
	
	label_header.add_theme_font_override("font", Global.theme.get_font(ThemeManager.FontType.HEADING))
	
	var game_over_data := Global.config_system.game_over_data
	if game_over_data:
		label_header.text = game_over_data.get_header()
		label_explanation.text = game_over_data.get_message()

	anim_player.play("go_fade")
	
	await anim_player.animation_finished
	
	get_tree().paused = true
	forward_btn.grab_focus()

func _on_backward_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://pq-obg/game_loop/menu/menu.tscn")

func _on_forward_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
