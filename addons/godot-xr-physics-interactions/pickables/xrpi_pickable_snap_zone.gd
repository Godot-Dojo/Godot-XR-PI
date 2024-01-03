class_name XRPickableSnapZone
extends Area3D


signal pickable_snapped
signal pickable_grabbed

@export var target_group : StringName

@export var picked_up_sound : AudioStream
@export var stashed_sound : AudioStream

var target_node : XRPickable

func _ready() -> void:
	set_collision_mask_value(3, true)
	set_collision_mask_value(17, true)
	set_collision_mask_value(1, false)
	body_entered.connect(pickable_body_entered)
	body_exited.connect(pickable_body_exited)

func pickable_body_entered(body : Node3D):
	if target_node:
		return
	if target_group in body.get_groups() && body is XRPickable:
		target_node = body
		if !body.is_grabbed:
			snap_body()
		else:
			body.let_go.connect(snap_body)

func pickable_body_exited(body : Node3D):
	if body == target_node:
		body.let_go.disconnect(snap_body)
		target_node = null


func snap_body():
	var tween = get_tree().create_tween()
	tween.tween_property(target_node, "global_transform", global_transform, 0.15)
	target_node.freeze = true
	target_node.grabbed.connect(unsnap_body)
	if stashed_sound:
		$AudioStreamPlayer3D.stream = stashed_sound
		$AudioStreamPlayer3D.play()
	pickable_snapped.emit()

func unsnap_body():
	target_node.freeze = false
	target_node.grabbed.disconnect(unsnap_body)
	
	if picked_up_sound:
		$AudioStreamPlayer3D.stream = picked_up_sound
		$AudioStreamPlayer3D.play()
	pickable_grabbed.emit()
	
	
