@tool
class_name OverworldCharacter
extends CharacterBody3D
## Base for anything that walks on the tile grid (the player and NPCs).
##
## Movement is tile-by-tile like the games. Before each step we ask the
## physics world two questions about the next tile:
##   - how high is the ground there?      (ray against layer 1 "ground")
##   - is anything standing in the way?   (box against layers 2 "obstacles"
##                                          and 3 "characters")
## So level design is just placing scenes with colliders, no tile tables.

enum Dir { DOWN, LEFT, RIGHT, UP }

const DIR_VECTORS: Array[Vector3] = [Vector3.BACK, Vector3.LEFT, Vector3.RIGHT, Vector3.FORWARD]
const DIR_NAMES: Array[String] = ["down", "left", "right", "up"]
const GROUND_MASK := 1
const BLOCKER_MASK := 2 | 4

## Animations named stand_<dir> / walk_<dir> (see res://art/characters).
@export var sprite_frames: SpriteFrames:
	set(value):
		sprite_frames = value
		_refresh_sprite()
@export var facing: Dir = Dir.DOWN:
	set(value):
		facing = value
		_refresh_sprite()
@export var walk_speed := 4.0 ## tiles per second
@export var run_speed := 8.0

var moving := false
var speed := 4.0

var _from := Vector3.ZERO
var _to := Vector3.ZERO
var _t := 0.0
var _just_finished := false
var _snapped := false
var _probe := BoxShape3D.new()

@onready var sprite: AnimatedSprite3D = $Sprite
@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var _collision_offset := collision.position


func _ready() -> void:
	_probe.size = Vector3(0.8, 1.0, 0.8)
	speed = walk_speed
	_refresh_sprite()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if not _snapped:
		_snap_to_grid()
	_just_finished = false
	var carry := 0.0
	if moving:
		_t += delta * speed
		if _t >= 1.0:
			carry = (_t - 1.0) / speed
			position = _to
			moving = false
			_just_finished = true
		else:
			position = _from.lerp(_to, _t)
	if not moving:
		_think(delta)
		if moving and carry > 0.0:
			# keep leftover time so chained steps don't stutter on tile edges
			_t = carry * speed
			position = _from.lerp(_to, _t)
	# The collider sits on the tile we're heading to, so nobody else claims it.
	collision.position = _collision_offset + (_to - position if moving else Vector3.ZERO)
	_refresh_sprite()


## Override in subclasses: decide what to do while standing on a tile.
func _think(_delta: float) -> void:
	pass


func try_step(dir: int) -> bool:
	if facing != dir:
		facing = dir as Dir
	var target := position + DIR_VECTORS[dir]
	var ground := _ground_height(target)
	if is_nan(ground) or not _is_free(Vector3(target.x, ground, target.z)):
		return false
	target.y = ground
	_from = position
	_to = target
	_t = 0.0
	moving = true
	return true


func _snap_to_grid() -> void:
	_snapped = true
	position.x = floorf(position.x) + 0.5
	position.z = floorf(position.z) + 0.5
	var ground := _ground_height(position)
	if not is_nan(ground):
		position.y = ground


func _ground_height(p: Vector3) -> float:
	var q := PhysicsRayQueryParameters3D.create(Vector3(p.x, p.y + 3.0, p.z), Vector3(p.x, p.y - 3.0, p.z), GROUND_MASK)
	var hit := get_world_3d().direct_space_state.intersect_ray(q)
	return hit.position.y if hit else NAN


func _is_free(ground_pos: Vector3) -> bool:
	var q := PhysicsShapeQueryParameters3D.new()
	q.shape = _probe
	q.transform = Transform3D(Basis.IDENTITY, ground_pos + Vector3(0, 0.95, 0))
	q.collision_mask = BLOCKER_MASK
	q.exclude = [get_rid()]
	return get_world_3d().direct_space_state.intersect_shape(q, 1).is_empty()


func _refresh_sprite() -> void:
	if not is_node_ready():
		return
	if sprite_frames and sprite.sprite_frames != sprite_frames:
		sprite.sprite_frames = sprite_frames
	if sprite.sprite_frames == null:
		return
	# Walk cycle is [step A, stand, step B, stand] at 8 fps = 2 frames per tile.
	var anim := ("walk_" if moving else "stand_") + DIR_NAMES[facing]
	sprite.speed_scale = speed / walk_speed
	if sprite.animation != anim or not sprite.is_playing():
		sprite.play(anim)
