extends Resource
class_name ConfigData

@export var play_mode := "2D" # 2D or 3D; did not use an enum for easier settings/strings

@export_group("Map")
@export var floor_is_lava := true

@export_subgroup("Generator")
@export var map_size_base := Vector2i(20,10)
@export var map_size_factor := 1.0 # used in player-facing settings
@export var map_size_scale_2d := 1.0
@export var building_height_min := 1.0
@export var building_height_max := 8.0
@export var num_buildings : int = 10
@export var num_gifts_factor := 1.0 # ~num_buildings

@export_group("Sleigh")
@export var sleigh_mass := 1.0
@export var sleigh_lift_force := 25.0
@export var sleigh_move_force := 10.0
@export var sleigh_damping := 2.3

@export_subgroup("Arrows")
@export var arrow_speed_factor := 1.0
@export var arrow_flip_interval := 5.0
@export var arrow_rotate_speed := 1.0
@export var arrow_sway_speed := 2.0
@export var arrow_flip_speed := 1.0
@export var arrow_max_sway := 0.75
@export var arrow_rotate_on_mode_2d := true

@export_subgroup("Damage")
## this prevents animations/tweens from firing far too quickly + is just nicer to players
@export var damage_enabled := true
@export var collision_shield_duration := 0.4 
@export var turn_off_damage_in_2d := true
@export var collision_damage_factor := 50.0

@export_group("Gifts")
@export var gift_mass := 0.2
@export var gift_size := 0.5

@export_group("Objective")
@export_subgroup("Score")
@export var score_per_gift := 6.0
@export var score_bonus_win := 35.0
## maximum multiplier for quicker deliveries
@export var score_time_bonus := 2.0
## if you waited this long, time_bonus is reduced to nothing (1.0)
@export var max_time_between_deliveries := 10.0
## divides final score for next gift by this
@export var score_penalty_per_collision := 2.0

func in_mode_2d() -> bool:
	return play_mode == "2D"

func in_mode_3d() -> bool:
	return play_mode == "3D"
