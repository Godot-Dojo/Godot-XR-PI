extends StaticBody3D
class_name XRPIGrabFunction

@onready var joint = $Generic6DOFJoint3D

var closest_object : Node3D = null
var picked_up_object : Node3D = null
var grip_pressed : bool = false

## Grip controller axis
@export var pickup_axis_action : String = "grip"

## Controller
##TODO: Remove Dependency on godot-xr-tools
@onready var _controller := XRHelpers.get_xr_controller(self)

## Grip threshold (from configuration)
##TODO: Remove Dependency on godot-xr-tools
@onready var _grip_threshold : float = XRTools.get_grip_threshold()


# Collision Layer and Mask for picked up objects
@export_flags_3d_physics var picked_up_layers = pow(2, 17-1)

@export_flags_3d_physics var picked_up_mask = pow(2, 1-1) + pow(2, 2-1) + pow(2, 3-1) + pow(2, 17-1)




#Remember previous collision mask and layer
@onready var original_collision_layer : int
@onready var original_collision_mask : int



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var grip_value = _controller.get_float(pickup_axis_action)
	if (grip_pressed and grip_value < (_grip_threshold - 0.1)):
		grip_pressed = false
		_on_grip_release()
	elif (!grip_pressed and grip_value > (_grip_threshold + 0.1)):
		grip_pressed = true
		_on_grip_pressed()



func _on_grip_pressed():
	if closest_object:
		var point = closest_object.global_position - global_position
		var distance = abs(point.x) + abs(point.y) + abs(point.z)
		if distance <= 0.5:
			joint.node_b = closest_object.get_path()
			picked_up_object = closest_object
			if picked_up_object is XRPickable:
				picked_up_object.grab()
			else:
				original_collision_layer = picked_up_object.collision_layer
				original_collision_mask = picked_up_object.collision_mask
				picked_up_object.set_collision_layer(picked_up_layers)
				picked_up_object.set_collision_mask(picked_up_mask)
		else:
			closest_object = null




func _on_grip_release():
	if picked_up_object:
		joint.node_b = ""
		if picked_up_object is XRPickable:
			picked_up_object.drop()
		else:
			picked_up_object.set_collision_layer(original_collision_layer)
			picked_up_object.set_collision_mask(original_collision_mask)

		picked_up_object = null


func _on_area_3d_body_entered(body):
	if body == picked_up_object:
		pass
	elif body is RigidBody3D:
		closest_object = body




func _on_area_3d_body_exited(body):
	if body == picked_up_object:
		pass
	elif closest_object:
		closest_object = null
