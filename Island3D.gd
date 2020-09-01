extends CSGMesh


export var amplitude = 10.0;

export var noise_size : Vector2 = Vector2(25.0,25.0);
export var noise_precision : Vector2 = Vector2(4,4);
export var noise_scale = Vector2(5.0,5.0);
export var noise_shift = Vector3(0.0,0.0,0.0);

export var noise_lacunarity = 2.0;
export var noise_octaves = 8;
export var noise_period = 64.0;
export var noise_persistence = 0.5;
export var noise_seed = 0;

onready var noise_mesh = self.get_mesh();
onready var noiseGenerator = OpenSimplexNoise.new();


func distance(a : Vector2,b : Vector2):
	return sqrt(pow(a.x-b.x,2)+pow(a.y-b.y,2));

onready var MAX_CIRCLE_DISTANCE = min(noise_size.x,noise_size.y) / 2.0;

func circle_distance(coord : Vector2):
	return 1 - min(distance(coord,Vector2(0.0,0.0)) / MAX_CIRCLE_DISTANCE,1)

func update_noise_settings():
	noiseGenerator.seed = noise_seed;
	noiseGenerator.octaves = noise_octaves;
	noiseGenerator.period = noise_period;
	noiseGenerator.persistence = noise_persistence;
	noiseGenerator.lacunarity = noise_lacunarity;
	
func get_noise_height(coord : Vector2):
	var height = noiseGenerator.get_noise_3d(coord.x*noise_scale.x + noise_shift.x,coord.y*noise_scale.y + noise_shift.y , noise_shift.z);
	height = (height+1)/2;
	return height;

func get_island_height(coord : Vector2):
	var height =  get_noise_height(coord);
	height *= amplitude;
	height *= circle_distance(coord);
	return height;

func update_mesh():
	var st = SurfaceTool.new();
	noise_mesh.subdivide_width = noise_precision.x * noise_size.x;
	noise_mesh.subdivide_depth = noise_precision.y * noise_size.y;
	noise_mesh.size = noise_size;
	
	st.create_from(noise_mesh, 0);
	var array_plane = st.commit();
	
	var mdt = MeshDataTool.new();
	mdt.create_from_surface(array_plane, 0);
	
	for i in range(mdt.get_vertex_count()):
		var vtx = mdt.get_vertex(i)
		vtx.y = get_island_height(Vector2(vtx.x,vtx.z));	
		mdt.set_vertex(i, vtx)
	
	
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
	
	mdt.commit_to_surface(array_plane)
	st.create_from(array_plane, 0)
	st.generate_normals()
	self.mesh = st.commit()


func _ready():
	update_mesh();



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
