@tool
extends Camera3D
## Gen 5 style camera: narrow FOV, set far back, tilted down the street.
## Runs in the editor too, so the 3D view's camera preview shows the real shot.

@export var target: Node3D
@export var offset := Vector3(0, 6.0, 16.5)
@export var look_offset := Vector3(0, 0, -3.0)


func _process(_delta: float) -> void:
	if not target:
		return
	# Ignore the target's height so stepping onto a curb doesn't bob the camera.
	var anchor := Vector3(target.global_position.x, 0.0, target.global_position.z)
	global_position = anchor + offset
	look_at(anchor + look_offset)
