extends Node3D

@export var SelectionThingNode : SelectionThing

var grabbed = false

signal grab_state_changed(new_state : bool)

@export var input_name : StringName = "primary_click"


func _link_nodes(node : PhysicsBody3D):
	SelectionThingNode.update_color(SelectionThingNode.grabbing_color)
	$Generic6DOFJoint3D.global_position = node.global_position
	$Generic6DOFJoint3D.global_rotation = node.global_rotation
	$Generic6DOFJoint3D.node_b = node.get_path()

func _unlink_nodes():
	$Generic6DOFJoint3D.global_position = global_position
	$Generic6DOFJoint3D.global_rotation = global_rotation
	$Generic6DOFJoint3D.node_b = ""
	SelectionThingNode.update_color(SelectionThingNode.default_color)

func _update_grab_state(new_state : bool):
	if new_state:
		if SelectionThingNode.Highlighted:
			_link_nodes(SelectionThingNode.Highlighted)
			grabbed = true
		else:
			_unlink_nodes()
			grabbed = false
		
	else:
		_unlink_nodes()
		grabbed = false
		
func check_for_grab(input):
	if input == input_name:
		_update_grab_state(false) if !get_parent().is_button_pressed(input_name) else  _update_grab_state(true)
		

		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().button_pressed.connect(check_for_grab)
	get_parent().button_released.connect(check_for_grab)


