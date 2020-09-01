extends CSGMesh

#onready var heightMesh = self.get_mesh();
onready var heightMap = get_node("OneTimeNoiseTexture");
export var anim_speed = 1.0;
export var amplitude = 10.0;

export var noise_size : Vector2 = Vector2(25.0,25.0);
export var noise_scale = Vector2(1.0,1.0);
export var noise_shift = Vector3(0.0,0.0,0.0);

export var lacunarity = 2.0;
export var octaves = 8;
export var period = 64.0;
export var persistence = 0.5;
export var seed_num = 0;

var total_time = 0;

var noise_mesh = self.get_mesh();

func update_noise_settings():
	heightMap.noise_scale = noise_scale;
	heightMap.noise_shift = noise_shift;
	
	heightMap.lacunarity = lacunarity;
	heightMap.octaves = octaves;
	heightMap.period = period;
	heightMap.persistence = persistence;
	heightMap.seed_num = seed_num;
	heightMap.update_noise_settings();

func update_mesh():
	var st = SurfaceTool.new()
	noise_mesh.subdivide_width = noise_size.x 
	noise_mesh.subdivide_depth = noise_size.y 
	noise_mesh.size = noise_size;
	
	# create an arrayMesh to be used by the MeshDataTool
	st.create_from(noise_mesh, 0) 
	var array_plane = st.commit()
	
	var mdt = MeshDataTool.new();
	# In practice we copy the array mesh into the MeshDataTool
	var error = mdt.create_from_surface(array_plane, 0)
	
	for i in range(mdt.get_vertex_count()):		
		var vtx = mdt.get_vertex(i)
		vtx.y = heightMap.get_noise_height(Vector2(vtx.x,vtx.z)) * amplitude;
		
		# We tell the MeshDataTool to modify the vertex accordingly
		mdt.set_vertex(i, vtx)
	
	
	# To avoid adding new surfaces to the mesh instance
	# I had to run through all the existing surfaces and remove them
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
	
	# Then we are ready to place the modified plane 
	# back into the original arraymesh
	mdt.commit_to_surface(array_plane)
	
	# This last step is needed in order to generate the normals
	# without the need of doing it manually
	st.create_from(array_plane, 0)
	st.generate_normals()
	
	#finally, attach the mesh to the MeshInstance node
	self.mesh = st.commit()


# Called when the node enters the scene tree for the first time.
func _ready():
	
	update_noise_settings();
	
	
	#heightMap.update_heightmap_data();
	
	noise_mesh.size = noise_size;
	#heightMesh.material.set_shader_param("offset",islandMesh.material.get_shader_param("offset")+Vector3(0.0,0.0,0.25))
	#self.get_material().set_shader_param("height_map_offset",heightMap.generate_texture());
	
	update_mesh();










# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	total_time += delta;
	
	#if(total_time > 2.5):
	#	total_time = 0;
	#	seed_num += 1;
	#	update_noise_settings();
	
	#heightMap.noise_shift.z += anim_speed * delta;
	#update_mesh();

