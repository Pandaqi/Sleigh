extends Node2D
class_name Arrows

var arrows : Array[Arrow]
var arrow_dirs := [Vector3.RIGHT, Vector3(1,-1,0), Vector3.DOWN, Vector3(-1,-1,0), Vector3.LEFT, Vector3(-1,1,0), Vector3.UP, Vector3(1,1,0), Vector3.FORWARD, Vector3.BACK]

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
		a.hide()
		arrow_container.add_child(a)
	
	var counter := 0
	for arrow in get_rotating_arrows():
		arrow.make_rotatable()
		arrow.set_rotation(counter * 0.25 * PI)
		counter += 1
	
	for arrow in get_flipping_arrows():
		arrow.make_flippable()
	
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
	
	var arrows_to_assign := determine_arrows_to_assign()
	
	var counter := 0
	for arrow in arrows_to_assign:
		var player := players[counter % num_players]
		counter += 1
		(player as Player).module_arrows.add(arrow)
	
	# only show those actually used
	for arrow in arrows:
		arrow.set_visible(arrows_to_assign.has(arrow))

func determine_arrows_to_assign() -> Array[Arrow]:
	var num_players := player_data.count()
	
	var rot_arrows := get_rotating_arrows()
	var fl_arrows := get_flipping_arrows()
	
	## 3D MODE ##
	if Global.config.in_mode_3d():
		# up, front/back
		if num_players <= 2:
			return [rot_arrows[6], fl_arrows[0]]
		
		# up, right, left, front/back
		if num_players <= 4:
			return [rot_arrows[6], rot_arrows[0], rot_arrows[4], fl_arrows[0]]
		
		return arrows
	
	## 2D MODE ##
	# No flipping arrows; more diagonal options
	if Global.config.in_mode_2d():
		if num_players <= 2:
			return [rot_arrows[6], rot_arrows[0]]
		
		if num_players <= 4:
			return [rot_arrows[0], rot_arrows[2], rot_arrows[4], rot_arrows[6]]
		
		return rot_arrows
	
	return arrows

func arrow_dir_to_2d(dir:Vector3) -> Vector2:
	var has_z_component := absf(dir.z) > 0.03
	if has_z_component: return Vector2(dir.z, 0)
	return Vector2(dir.x, -dir.y)

func _physics_process(delta: float) -> void:
	keep_arrows_on_sleigh()
	rotate_arrows(delta)
	flip_arrows(delta)

func get_rotating_arrows() -> Array[Arrow]:
	return arrows.slice(0,8)

func get_flipping_arrows() -> Array[Arrow]:
	return arrows.slice(8,10)

func rotate_arrows(delta: float) -> void:
	# rotation is simpler but only possible in 2D
	var should_rotate := Global.config.in_mode_2d() and Global.config.arrow_rotate_on_mode_2d
	if should_rotate:
		rotate(delta * Global.config.arrow_rotate_speed * Global.config.arrow_speed_factor)
		return
	
	# "swaying" is the default
	var speed := delta * Global.config.arrow_sway_speed * Global.config.arrow_speed_factor
	rotation_time_tracker += speed
	set_rotation(Global.config.arrow_max_sway * sin(rotation_time_tracker) * 0.5 * PI)

func flip_arrows(delta:float) -> void:
	var speed := delta * Global.config.arrow_flip_speed * Global.config.arrow_speed_factor
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
		var arrow_vec_conv := get_arrow_flip_ratio() * arrow_dir_to_2d(arrow.vec)
		arrow.global_position = pos_2d + arrow_vec_conv * offset_on_sleigh
		var target_rotation := 0.5*PI if arrow_vec_conv.x > 0 else -0.5*PI
		arrow.rotation = target_rotation - rotation # compensate for rotation of container to stay upright
