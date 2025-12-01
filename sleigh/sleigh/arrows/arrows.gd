extends Node2D
class_name Arrows

var arrows : Array[Arrow]
var arrow_dirs := [Vector3.RIGHT, Vector3.DOWN, Vector3.LEFT, Vector3.UP, Vector3.FORWARD, Vector3.BACK]

@export var arrow_scene : PackedScene
@export var arrow_container : Node2D
@export var player_data : PlayerData
@export var map_data : MapData

@export var timer : Timer
@export var use_flip_arrows_instant_method := false

var z_arrows_flipped := false
var flip_time_tracker := 0.0
var rotation_time_tracker := 0.0

func _ready() -> void:
	Global.input.buttons_changed.connect(_on_buttons_changed)
	start_timer()

func start_timer() -> void:
	timer.timeout.connect(flip_arrows_instant)
	timer.wait_time = Global.config.arrow_flip_interval
	timer.start()

func create(ui_container:CanvasLayer) -> void:
	for dir in arrow_dirs:
		var a : Arrow = arrow_scene.instantiate()
		arrows.append(a)
		a.set_vector(dir)
		arrow_container.add_child(a)
	
	for i in range(4):
		arrows[i].make_rotatable()
		arrows[i].set_rotation(i * 0.5 * PI)
	
	for i in range(4,6):
		arrows[i].make_flippable()
	
	arrow_container.get_parent().remove_child(arrow_container)
	ui_container.add_child(arrow_container)

func get_vector() -> Vector3:
	var vec := Vector3.ZERO
	var flip_rot := PI if is_flipped() else 0.0
	for arrow in arrows:
		var arrow_vec := arrow.get_vector()
		if arrow.is_rotatable: arrow_vec = arrow_vec.rotated(Vector3.FORWARD, rotation)
		if arrow.is_flippable: arrow_vec = arrow_vec.rotated(Vector3.RIGHT, flip_rot)
		vec += arrow_vec 
	return vec

# refresh/distribute buttons over players
func _on_buttons_changed() -> void:
	var num_players := player_data.count()
	if num_players <= 0: return
	
	var players : Array[PlayerSystem] = player_data.players.duplicate()
	players.shuffle()
	
	for p in players:
		(p as Player).module_arrows.clear()
	
	var rot_arrows := get_rotating_arrows()
	var fl_arrows := get_flipping_arrows()
	var arrows_to_assign := arrows
	
	# up, front/back
	if num_players <= 2:
		arrows_to_assign = [rot_arrows[3], fl_arrows[0]]
	
	# up, right, left, front/back
	if num_players > 2 and num_players <= 4:
		arrows_to_assign = [rot_arrows[3], rot_arrows[0], rot_arrows[2], fl_arrows[0]]
	
	var counter := 0
	for arrow in arrows_to_assign:
		var player := players[counter % num_players]
		counter += 1
		(player as Player).module_arrows.add(arrow)

func arrow_dir_to_2d(dir:Vector3) -> Vector2:
	var has_z_component := absf(dir.z) > 0.03
	if has_z_component: return Vector2(dir.z, 0)
	return Vector2(dir.x, -dir.y)

func _physics_process(delta: float) -> void:
	keep_arrows_on_sleigh()
	rotate_arrows(delta)
	flip_arrows(delta)

func get_rotating_arrows() -> Array[Arrow]:
	return arrows.slice(0,4)

func get_flipping_arrows() -> Array[Arrow]:
	return arrows.slice(4,6)

func rotate_arrows(delta: float) -> void:
	var speed := delta * Global.config.arrow_rotate_speed
	rotation_time_tracker += speed
	set_rotation(Global.config.arrow_max_sway * sin(rotation_time_tracker) * 0.5 * PI)
	# rotate(speed)

func flip_arrows(delta:float) -> void:
	var speed := delta * Global.config.arrow_flip_speed
	flip_time_tracker += speed

func is_flipped() -> bool:
	return get_arrow_flip_ratio() < 0

func get_arrow_flip_ratio() -> float:
	if use_flip_arrows_instant_method: 
		return -1.0 if z_arrows_flipped else 1.0
	return sin(flip_time_tracker)

func flip_arrows_instant() -> void:
	if not use_flip_arrows_instant_method: return
	
	z_arrows_flipped = not z_arrows_flipped
	for arrow in get_flipping_arrows():
		arrow.is_flipped = z_arrows_flipped

func keep_arrows_on_sleigh() -> void:
	var sleigh_pos := map_data.sleigh.global_position
	var camera := get_viewport().get_camera_3d()
	var pos_2d := camera.unproject_position(sleigh_pos)
	set_position(pos_2d)
	
	var offset_from_sleigh := 64.0 # @TODO: how to calculate this automatically?
	for arrow in get_rotating_arrows():
		arrow.position = arrow_dir_to_2d(arrow.vec) * offset_from_sleigh
	
	var offset_on_sleigh := 32.0 # @TODO: how to calculate this automatically?
	for arrow in get_flipping_arrows():
		arrow.global_position = pos_2d + get_arrow_flip_ratio() * arrow_dir_to_2d(arrow.vec) * offset_on_sleigh
		arrow.rotation = -rotation # compensate for rotation of container to stay upright
