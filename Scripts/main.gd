extends Node3D

@export var terrain_mesh: MeshInstance3D
@export var grass_texture: Texture2D
@export var grass_material: ShaderMaterial
@export var mesh_size: float = 1
@export var spawn_radius: float = 10.0
@export var density: int = 1500

@onready var multimesh_instance := $SubViewportContainer/SubViewport/MeshInstance3D2/MultiMeshInstance3D
var mm := MultiMesh.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	var mesh := QuadMesh.new()
	mesh.size = Vector2(mesh_size, mesh_size)
	mesh.material = grass_material
	
	mm.mesh = mesh
	mm.transform_format = MultiMesh.TRANSFORM_3D
	mm.instance_count = density
	multimesh_instance.multimesh = mm
	
	var mdt := MeshDataTool.new()
	var terrain := terrain_mesh.mesh
	mdt.create_from_surface(terrain, 0)
	
	var instance_idx = 0
	for i in range(density):
		var angle = randf() * TAU
		var dist = randf() * spawn_radius
		var pos = Vector3(cos(angle) * dist, 0.0, sin(angle) * dist)
		
		
		var transform = Transform3D(Basis(), pos)
		mm.set_instance_transform(instance_idx, transform)
		
		instance_idx += 1 
	mm.instance_count = instance_idx
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
