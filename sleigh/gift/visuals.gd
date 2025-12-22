extends Node3D

@export var gift : Gift
@export var anim_player : AnimationPlayer
@export var twinkle : Sprite3D

func _ready() -> void:
	anim_player.speed_scale = randf_range(0.5, 1.5)
	gift.state_changed.connect(_on_state_changed)

func _on_state_changed(s:Gift.Condition) -> void:
	anim_player.stop()
	twinkle.hide()
	if s == Gift.Condition.FREE:
		twinkle.show()
		anim_player.play("twinkly_idle")
