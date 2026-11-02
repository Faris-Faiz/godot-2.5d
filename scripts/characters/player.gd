@tool
class_name Player
extends OverworldCharacter
## Walks with the move_* input actions, runs while "run" is held.
## Tapping a new direction turns on the spot first, like in the games.

const TURN_DELAY := 0.08

var _turn_timer := 0.0
var input_locked := false

## How close (in tiles) an actionable must be to the faced tile's centre.
const INTERACT_TOLERANCE := 0.6	

func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("interact"):
		return
	if moving or input_locked or _is_dialogue_open():
		return
	var actionable := _actionable_in_front()
	if actionable:
		actionable.action()
		get_viewport().set_input_as_handled()

## The DialogueActionable3D standing on the tile we're facing, if any.
func _actionable_in_front() -> DialogueActionable3D:
	var target := global_position + DIR_VECTORS[facing]
	var best: DialogueActionable3D = null
	var best_dist := INTERACT_TOLERANCE
	for node in get_tree().get_nodes_in_group("dialogue_actionables"):
		var a := node as DialogueActionable3D
		if a == null or not a.is_visible_in_tree():
			continue
		var d := Vector2(a.global_position.x - target.x, a.global_position.z - target.z).length()
		if d < best_dist:
			best = a
			best_dist = d
	return best

func _is_dialogue_open() -> bool:
	var balloon := get_tree().get_first_node_in_group("dialogue_balloon")
	return balloon != null and balloon.visible

func _think(delta: float) -> void:
	if input_locked or _is_dialogue_open():
		return
	speed = run_speed if Input.is_action_pressed("run") else walk_speed
	var dir := _input_dir()
	if dir < 0:
		_turn_timer = 0.0
		return
	if dir != facing and not _just_finished:
		facing = dir as Dir
		_turn_timer = TURN_DELAY
		return
	if _turn_timer > 0.0:
		_turn_timer -= delta
		return
	try_step(dir)


func _input_dir() -> int:
	if Input.is_action_pressed("move_up"):
		return Dir.UP
	if Input.is_action_pressed("move_down"):
		return Dir.DOWN
	if Input.is_action_pressed("move_left"):
		return Dir.LEFT
	if Input.is_action_pressed("move_right"):
		return Dir.RIGHT
	return -1
