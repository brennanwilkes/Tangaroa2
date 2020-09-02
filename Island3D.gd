extends CSGMesh


export var amplitude = 15.0;

export var noise_size : Vector2 = Vector2(50.0,50.0);
export var noise_precision : Vector2 = Vector2(4,4);
export var noise_scale = Vector2(12.5,12.5);
export var noise_shift = Vector3(0.0,0.0,0.0);

export var noise_lacunarity = 2.0;
export var noise_octaves = 8;
export var noise_period = 64.0;
export var noise_persistence = 0.5;
export var noise_seed = 0;

onready var noise_mesh = self.get_mesh();
onready var noiseGenerator = OpenSimplexNoise.new();



func smin(a : float, b : float, k : float):
	var h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
	return (a * (1-h) + b * h) - k*h*(1.0-h);

func distance(a : Vector2,b : Vector2):
	return sqrt(pow(a.x-b.x,2)+pow(a.y-b.y,2));

onready var MAX_CIRCLE_DISTANCE = min(noise_size.x,noise_size.y) / 2.0;

func circle_distance(coord : Vector2):
	var dis = distance(coord,Vector2(0.0,0.0));
	dis /= MAX_CIRCLE_DISTANCE;
	
	#dis = smin(pow(dis,1/4),pow(dis+0.5,4),0.85);
	#dis = pow(dis,0.15);
	#dis = pow(dis+0.2,4)
	dis = smin(pow(dis,0.15),pow(dis+0.5,4),0.999999)
	return clamp(1 - dis,0,1);


func update_noise_settings():
	noiseGenerator.seed = noise_seed;
	noiseGenerator.octaves = noise_octaves;
	noiseGenerator.period = noise_period;
	noiseGenerator.persistence = noise_persistence;
	noiseGenerator.lacunarity = noise_lacunarity;
	
func get_transformed_noise_3d(coord):
	return noiseGenerator.get_noise_3d(coord.x*noise_scale.x + noise_shift.x,coord.y*noise_scale.y + noise_shift.y , noise_shift.z);
	

func get_noise_mask(coord : Vector2, midpoint : float):
	return 1 if get_transformed_noise_3d(coord) > midpoint else -1;


func get_noise_height(coord : Vector2):
	var height = get_transformed_noise_3d(coord);
	height = (height+1)/2;
	return height;

func get_island_height(coord : Vector2):
	var height =  get_noise_height(coord);
	height *= circle_distance(coord);
	height *= amplitude;
	
	if(height < 0.1):
		var oldseed = noiseGenerator.seed;
		noiseGenerator.seed += 100;
		height *= get_noise_mask(coord, 0.25);
		noiseGenerator.seed = oldseed;
	
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
	update_noise_settings();
	update_mesh();



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
