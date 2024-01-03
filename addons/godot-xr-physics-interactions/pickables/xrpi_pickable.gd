class_name XRPickable
extends RigidBody3D
### A Pickable XR 3d Rigid Body

# Default layer for held objects is 17:held-object
const DEFAULT_LAYER := 0b0000_0000_0000_0001_0000_0000_0000_0000


## If true, the pickable supports being picked up
@export var enabled : bool = true

## Layer for this object while picked up
@export_flags_3d_physics var picked_up_layer : int = DEFAULT_LAYER

@export_flags_3d_physics var picked_up_mask = pow(2, 1-1) + pow(2, 2-1) + pow(2, 3-1) + pow(2, 17-1)


var is_grabbed = false

signal grabbed

signal let_go

func _action():
	pass

func grab():
	is_grabbed = true
	set_collision_layer(picked_up_layer)
	set_collision_mask(picked_up_mask)
	grabbed.emit()

func drop():
	is_grabbed = false
	set_collision_layer_value(3, true)
	collision_layer -= picked_up_layer
	set_collision_mask(pow(2, 1-1) + pow(2, 2-1) + pow(2, 3-1) + pow(2, 17-1) + pow(2, 18-1))
	let_go.emit()

