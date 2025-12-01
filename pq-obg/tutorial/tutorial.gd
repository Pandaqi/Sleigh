extends Control
class_name Tutorial 

var stages : Array[TutorialStage] = []

@export var container : Control
var sprite_scene : PackedScene = preload("res://pq-obg/tutorial/tutorial_sprite.tscn")
var sprites : Array[TutorialSprite] = []

var enabled := false
var active := false
var num_times_shown := 0

func _ready() -> void:
	enabled = Global.config_system.tutorial_enabled
	prepare_sprites()

func prepare_sprites() -> void:
	if not enabled: return
	
	# collect the right stages
	stages = Global.config_system.tutorials
	var debug_stages : Array[TutorialStage] = Global.config_system.tutorials_debug
	if debug_stages.size() > 0: stages = debug_stages
	
	# create objects for them
	for i in range(count()):
		var t : TutorialSprite = sprite_scene.instantiate()
		container.add_child(t)
		sprites.append(t)
		t.refresh_size(Global.config_system.tutorial_scale)
		t.set_stage(stages[i])

func set_active(val:bool) -> void:
	if not enabled: return
	if Global.config_system.tutorial_only_once and num_times_shown > 0: 
		set_visible(false)
		return
	
	active = val
	set_visible(val)
	if val:
		appear()

func appear() -> void:
	num_times_shown += 1
	# make them pop into view one by one
	for sprite in sprites:
		sprite.appear()
		await get_tree().create_timer(Global.config_system.tutorial_delay).timeout

func count() -> int:
	return stages.size()

#func prepare_anchor_tool() -> void:
	#var anchor_tool := ScreenAnchorTool.new(
		#Global.config_system.tutorial_anchor,
		#sprite_size, 0.1*Global.config_system.tutorial_sprite_scale
	#)
	#add_child(anchor_tool)
	#anchor_tool.show_elements(sprites)
