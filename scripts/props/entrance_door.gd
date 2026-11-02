extends Node3D
## A door the player can use. Pairs with another door through door_id / target_door_id.

@export var door_id: StringName
@export_file("*.tscn") var target_scene: String
@export var target_door_id: StringName
@export var arrival_facing: OverworldCharacter.Dir = OverworldCharacter.Dir.DOWN

var _used := false

@onready var anim: AnimationPlayer = $door/AnimationPlayer
@onready var spawn: Marker3D = $SpawnPoint


func _ready() -> void:
	$DialogueActionable3D.actioned.connect(_on_actioned)
	if door_id != &"" and SceneTransition.arrival_door_id == door_id:
		SceneTransition.arrival_door_id = &""
		_arrive()


func _on_actioned() -> void:
	if _used:
		return
	_used = true
	var player := get_tree().get_first_node_in_group("player") as Player
	player.input_locked = true
	anim.play("open")
	await anim.animation_finished
	SceneTransition.change_to(target_scene, target_door_id)


func _arrive() -> void:
	var player := get_tree().get_first_node_in_group("player") as Player
	player.global_position = spawn.global_position
	player.facing = arrival_facing
	anim.play_backwards("open")
