extends Node3D

@export var selection_thing : SelectionThing
@export var grab_function : XRPIGrabFunction


var grabbed = false

signal grab_state_changed(new_state : bool)

@export var input_name : StringName = "primary_click"

var joint = Generic6DOFJoint3D.new()

func _link_nodes(node : PhysicsBody3D):
	selection_thing.update_color(selection_thing.grabbing_color)
	joint.global_position = node.global_position
	joint.global_rotation = node.global_rotation
	joint.node_b = node.get_path()

func _unlink_nodes():
	joint.global_position = global_position
	joint.global_rotation = global_rotation
	joint.node_b = ""
	selection_thing.update_color(selection_thing.default_color)

func _update_grab_state(new_state : bool):
	if new_state:
		if selection_thing.highlighted:
			_link_nodes(selection_thing.highlighted)
			grabbed = true
		else:
			_unlink_nodes()
			grabbed = false
		
	else:
		_unlink_nodes()
		grabbed = false
		
func check_for_grab(input):
	if input == input_name:
		_update_grab_state(false) if !get_parent().is_button_pressed(input_name) else _update_grab_state(true)
		

		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_child(joint)
	joint.node_a = grab_function.get_path()
	get_parent().button_pressed.connect(check_for_grab)
	get_parent().button_released.connect(check_for_grab)


