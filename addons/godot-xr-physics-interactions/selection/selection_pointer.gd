extends MeshInstance3D

var move_processing := false

func tween_finished():
	move_processing = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if $"..".highlighted && !move_processing:
		global_position = $"..".highlighted.global_position
