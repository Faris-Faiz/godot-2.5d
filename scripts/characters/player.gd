@tool
class_name Player
extends OverworldCharacter
## Walks with the move_* input actions, runs while "run" is held.
## Tapping a new direction turns on the spot first, like in the games.

const TURN_DELAY := 0.08

var _turn_timer := 0.0


func _think(delta: float) -> void:
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
