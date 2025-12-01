extends Node2D
class_name Arrows

var arrows : Array[Arrow]
var arrow_dirs := [Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD, Vector3.BACK, Vector3.UP, Vector3.DOWN]

@export var arrow_scene : PackedScene
@export var arrow_container : Node2D
@export var player_data : PlayerData

func _ready() -> void:
	Global.input.buttons_changed.connect(_on_buttons_changed)

func create(ui_container:CanvasLayer) -> void:
	for dir in arrow_dirs:
		var a : Arrow = arrow_scene.instantiate()
		a.set_vector(dir)
		arrow_container.add_child(a)
	arrow_container.get_parent().remove_child(arrow_container)
	ui_container.add_child(arrow_container)

func get_vector() -> Vector3:
	var vec := Vector3.ZERO
	for arrow in arrows:
		vec += arrow.get_vector()
	return vec

# refresh/distribute buttons over players
func _on_buttons_changed() -> void:
	var num_players := player_data.count()
	if num_players <= 0: return
	
	var players : Array[PlayerSystem] = player_data.players.duplicate()
	players.shuffle()
	
	for p in players:
		(p as Player).module_arrows.clear()
	
	for i in range(arrows.size()):
		var arrow := arrows[i]
		var player := players[i % num_players]
		(player as Player).module_arrows.add(arrow)
