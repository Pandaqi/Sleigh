extends Node3D
class_name ModuleGrabber

@export var sleigh : RigidBody3D
@export var area : Area3D
@export var module_gifts : ModuleGifts

func _ready() -> void:
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body:Node) -> void:
	if not (body is Gift): return
	if not body.is_grabbable(): return
	if module_gifts.is_full(): return
	
	call_deferred("collect_gift", body)

func collect_gift(body:Gift) -> void:
	print("Wanna grab gift")
	
	# track that we have it
	module_gifts.collect_gift(body)
	body.change_state(Gift.State.SLEIGH)
	
	# physically stick it to us
	var joint := PinJoint3D.new()
	joint.node_a = sleigh.get_path()
	joint.node_b = body.get_path()
	add_child(joint)
	
	#var joint := ConeTwistJoint3D.new()
