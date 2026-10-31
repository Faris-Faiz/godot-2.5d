@tool
class_name Pedestrian
extends OverworldCharacter
## Walks back and forth in its facing direction, sidestepping when blocked.
## Untick `wander` for NPCs that should just stand still (the shop queue).

const OPPOSITE: Array[int] = [Dir.UP, Dir.RIGHT, Dir.LEFT, Dir.DOWN]

@export var wander := true
@export var max_steps := 30 ## tiles before turning around
@export_range(0.0, 0.1) var pause_chance := 0.01

var _heading := 0
var _steps := 0
var _wait := 0.0
var talking := false

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
		
	if not wander:
		return
	if _wait > 0.0:
		_wait -= delta
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
