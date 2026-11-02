extends CanvasLayer
## Lives outside the current scene, so it survives change_scene_to_file().
## Fades to black, swaps the scene, remembers which door the player arrives at.

var arrival_door_id: StringName

@onready var fade: ColorRect = $Fade


func change_to(scene_path: String, door_id: StringName) -> void:
	arrival_door_id = door_id
	var fade_out := create_tween()
	fade_out.tween_property(fade, "color:a", 1.0, 0.3)
	await fade_out.finished
	get_tree().change_scene_to_file(scene_path)
	await get_tree().scene_changed
	var fade_in := create_tween()
	fade_in.tween_property(fade, "color:a", 0.0, 0.3)
