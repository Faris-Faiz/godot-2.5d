@tool
class_name Pedestrian
extends OverworldCharacter
## Walks back and forth in its facing direction, sidestepping when blocked.
## Untick `wander` for NPCs that should just stand still (the shop queue).

const OPPOSITE: Array[int] = [Dir.UP, Dir.RIGHT, Dir.LEFT, Dir.DOWN]

@export var wander := true
@export var short_wander := false ## step out, pause, then walk the same way home
@export_range(1, 8) var short_steps := 2 ## tiles walked away from home per burst
@export_range(0.0, 5.0) var short_pause := 1.5 ## seconds standing still between bursts
@export var max_steps := 30 ## tiles before turning around
@export_range(0.0, 0.1) var pause_chance := 0.01

var _heading := 0
var _steps := 0
var _wait := 0.0
var talking := false
var _path: Array[int] = [] ## headings walked away from home, oldest first
var _burst_left := 0
var _returning := false

func _ready() -> void:
	super()
	_heading = facing
	if Engine.is_editor_hint():
		return
	for child in get_children():
		if child is DialogueActionable3D:
			child.actioned.connect(_on_talked_to)
	DialogueManager.dialogue_ended.connect(func(_r): talking = false)

func _on_talked_to() -> void:
	talking = true
	var player := get_tree().get_first_node_in_group("player") as Node3D
	if player:
		var d := player.global_position - global_position
		if absf(d.x) > absf(d.z):
			facing = Dir.RIGHT if d.x > 0 else Dir.LEFT
		else:
			facing = Dir.DOWN if d.z > 0 else Dir.UP

func _think(delta: float) -> void:
	if talking:
		return
	if not wander and not short_wander:
		return
	if _wait > 0.0:
		_wait -= delta
		return
	if short_wander:
		_think_short()
		return
	if randf() < pause_chance:
		_wait = randf_range(0.4, 1.5)
	return
	if _steps >= max_steps:
		_heading = OPPOSITE[_heading]
		facing = _heading as Dir
		_steps = 0
		_wait = 0.6
		return
	if try_step(_heading):
		_steps += 1
		return
	var vertical := _heading == Dir.UP or _heading == Dir.DOWN
	var side := (Dir.LEFT if randf() < 0.5 else Dir.RIGHT) if vertical else (Dir.UP if randf() < 0.5 else Dir.DOWN)
	if not try_step(side):
		facing = _heading as Dir
		_wait = 0.4

## Short wander: walk `short_steps` tiles, stand still, then retrace those exact
## tiles back to where the node was placed. Retracing needs no pathfinding and
## lands on the original tile by construction, while still respecting
## try_step()'s ground/blocking checks.
func _think_short() -> void:
	# Phase 3: walk the recorded path backwards until we're home again.
	if _returning:
		if _path.is_empty():
			_returning = false
			_heading = randi_range(0, 3)
			_burst_left = short_steps
			_wait = short_pause
			return
		if try_step(OPPOSITE[_path.back()]):
			_path.pop_back()
		else:
			_wait = 0.25 # someone is standing on our way home, wait and retry
		return

	# Phase 2: burst finished, pause on the spot facing away, then head home.
	if _burst_left <= 0:
		_returning = true
		_wait = short_pause * 0.5
		return

	# Phase 1: step away from home along the current heading.
	if try_step(_heading):
		_path.push_back(_heading)
		_burst_left -= 1
		return

	# Blocked: try a random heading, otherwise cut the burst short and go home
	# on the steps we already recorded.
	for i in 3:
		var alt := randi_range(0, 3)
		if try_step(alt):
			_path.push_back(alt)
			_burst_left -= 1
			return
	_burst_left = 0
	_wait = 0.3
