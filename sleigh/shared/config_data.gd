extends Resource
class_name ConfigData

@export_group("Map")
@export var floor_is_lava := true

@export_subgroup("Generator")
@export var map_size_base := Vector2i(20,10)
@export var map_size_factor := 1.0 # used in player-facing settings
@export var building_height_min := 1.0
@export var building_height_max := 8.0
@export var num_buildings : int = 10
@export var num_gifts_factor := 1.0 # ~num_buildings

@export_group("Sleigh")
@export var sleigh_mass := 1.0
@export var sleigh_lift_force := 25.0
@export var sleigh_move_force := 10.0
@export var sleigh_damping := 2.3
@export var collision_damage_factor := 50.0
@export var arrow_flip_interval := 5.0
@export var arrow_rotate_speed := 2.0
@export var arrow_flip_speed := 1.0
@export var arrow_max_sway := 0.75

@export_group("Gifts")
@export var gift_mass := 0.2
@export var gift_size := 0.5

@export_group("Objective")
@export_subgroup("Target")
@export var gifts_target_min : int = 10
@export var gifts_target_max : int = 40
@export var gifts_target_factor := 1.0

@export_subgroup("Score")
@export var score_per_gift := 10.0
@export var score_bonus_win := 100.0
## maximum multiplier for quicker deliveries
@export var score_time_bonus := 3.0
## if you waited this long, time_bonus is reduced to nothing (1.0)
@export var max_time_between_deliveries := 10.0
## divides final score for next gift by this
@export var score_penalty_per_collision := 2.0
