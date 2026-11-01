@tool
class_name Building
extends StaticBody3D
## A block of facade. Change `size` / `wall_material` in the Inspector and the
## meshes and collider resize live. The front face is local +Z.
##
## Wall materials use world-space triplanar mapping, so windows line up on a
## 2 m x 3 m grid no matter how buildings are sized or placed.

@export var size := Vector3(12, 12, 16):
	set(value):
		size = value
		_rebuild()
@export var wall_material: Material:
	set(value):
		wall_material = value
		_rebuild()


func _ready() -> void:
	_rebuild()


func _rebuild() -> void:
	if not is_node_ready():
		return
	var body: MeshInstance3D = $Body
	(body.mesh as BoxMesh).size = size
	body.position = Vector3(0, size.y / 2.0, 0)
	body.material_override = wall_material
	# stone plinth and cornice stick out a little to break up the silhouette
	var plinth: MeshInstance3D = $Plinth
	(plinth.mesh as BoxMesh).size = Vector3(size.x + 0.3, 0.75, size.z + 0.3)
	plinth.position = Vector3(0, 0.375, 0)
	var cornice: MeshInstance3D = $Cornice
	(cornice.mesh as BoxMesh).size = Vector3(size.x + 0.6, 0.4, size.z + 0.6)
	cornice.position = Vector3(0, size.y - 0.1, 0)
	var col: CollisionShape3D = $CollisionShape3D
	(col.shape as BoxShape3D).size = size
	col.position = body.position
