extends RigidBody3D
class_name Sleigh

@export var module_mini_map : ModuleMiniMap
@export var module_delivery : ModuleDelivery
@export var module_collider : ModuleCollider
@export var module_gifts : ModuleGifts
@export var module_health : ModuleHealth
@export var module_grabber : ModuleGrabber
@export var module_mover : ModuleMover

func _ready() -> void:
	module_collider.collided.connect(module_health._on_collided)
