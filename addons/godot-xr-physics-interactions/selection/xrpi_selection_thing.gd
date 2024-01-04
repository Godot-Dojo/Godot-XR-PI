extends Node3D
class_name SelectionThing

var highlighted : Node3D

@export var default_color : Color = Color(1, 1, 1)

@export var grabbing_color : Color = Color(1, 0, 0)



func update_color(new_color : Color):
	var tween = get_tree().create_tween()
	tween.tween_property($SelectionPointer.material_override, "shader_parameter/albedo", new_color, 0.3).set_trans(Tween.TRANS_QUAD)


func _ready() -> void:
	
	var selection_material = load("res://resources/materials/Selection_Thing_Shader.tres").duplicate()
	
	$SelectionPointer.material_override = selection_material
	
	update_color(default_color)
	

func _update_highlighted(new_highlighted : Node3D):
	$SelectionPointer.visible = 1
	$SelectionPointer.move_processing = true
	var tween = get_tree().create_tween()
	tween.tween_property($SelectionPointer, "global_position", new_highlighted.global_position, 0.6).set_trans(Tween.TRANS_BACK)
	tween.finished.connect($SelectionPointer.tween_finished)
	highlighted = new_highlighted


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if !$ShapeCast3D.is_colliding():
		$SelectionPointer.visible = 0
		highlighted = null
		$SelectionPointer.global_position = global_position
		return
		
	if highlighted != $ShapeCast3D.get_collider(0):
		_update_highlighted($ShapeCast3D.get_collider(0))

