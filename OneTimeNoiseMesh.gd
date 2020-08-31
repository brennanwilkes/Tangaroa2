extends CSGMesh

#onready var heightMesh = self.get_mesh();
onready var heightMap = get_node("OneTimeNoiseTexture");


# Called when the node enters the scene tree for the first time.
func _ready():
	
	heightMap.noise_size = self.get_mesh().size;
	
	#heightMesh.material.set_shader_param("offset",islandMesh.material.get_shader_param("offset")+Vector3(0.0,0.0,0.25))
	self.get_material().set_shader_param("height_map_offset",heightMap.generate_texture());
	
	#var tex = get_node("OneTimeNoiseTexture");
	print("setup")
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
