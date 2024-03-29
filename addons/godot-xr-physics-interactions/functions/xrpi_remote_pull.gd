extends Node3D

@export var selection_thing : SelectionThing

var detect_gesture = false
var animating = false
var target_x_rotation : float

var target : RigidBody3D

var pull_path = Path3D.new()

var pull_target = PathFollow3D.new()
var pull_transform = RemoteTransform3D.new()
var pull_curve : Curve3D

signal grab_state_changed(new_state : bool)

@export var grab_function : XRPIGrabFunction

@export var input_name : StringName = "grip_click"



func _update_grab_state(new_state : bool):
	if new_state:
		if selection_thing.highlighted:
			target = selection_thing.highlighted
			detect_gesture = true
			selection_thing.update_color(selection_thing.grabbing_color)
			target_x_rotation = rad_to_deg(get_parent().rotation.x) + 65
		else:
			target = null
			detect_gesture = false
			selection_thing.update_color(selection_thing.default_color)
		
	else:
		target = null
		selection_thing.update_color(selection_thing.default_color)
		detect_gesture = false
		
func check_for_grab(input):
	if input == input_name:
		_update_grab_state(false) if !get_parent().is_button_pressed(input_name) else _update_grab_state(true)


func pull_node(target : RigidBody3D):
	animating = true
	target.freeze = true
	var original_freeze_mode = target.freeze_mode
	target.freeze_mode = RigidBody3D.FREEZE_MODE_STATIC
	pull_path.global_position = global_position
	pull_curve = Curve3D.new()
	var point = target.global_position - pull_path.global_position
	target.set_linear_velocity(-point)
	pull_curve.add_point(point, Vector3(0, 0, 0), Vector3(0, 1, 0))
	pull_curve.add_point(Vector3(0, 0, 0))
	pull_path.curve = pull_curve
	pull_transform.remote_path = target.get_path()
	pull_target.progress_ratio = 0

	var tween = get_tree().create_tween()

	tween.tween_property(pull_target, "progress_ratio", 1, 0.45).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(target, "freeze", false, 0.001)
	await tween.finished
	target.freeze_mode = original_freeze_mode
	pull_transform.remote_path = ""

	animating = false



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	get_parent().button_pressed.connect(check_for_grab)
	get_parent().button_released.connect(check_for_grab)
	
	pull_target.add_child(pull_transform)
	pull_path.add_child(pull_target)
	add_child(pull_path)
	pull_path.top_level = true


func _physics_process(delta: float) -> void:
	if detect_gesture && grab_function.picked_up_object == null:
		if rad_to_deg(get_parent().rotation.x) >= target_x_rotation && !animating:
			if target is XRPickable:
				target.grabbed.emit()
			pull_node(target)


