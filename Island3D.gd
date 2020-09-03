extends CSGMesh


#export var noise_amplitude = 2.5;
var noise_amplitude = 2.5;
export var noise_power = 2.25;


export var noise_size : Vector2 = Vector2(100,100);
export var noise_precision : Vector2 = Vector2(1,1);
export var noise_shift = Vector3(0.0,0.0,0.0);

#export var noise_scale = Vector2(4.0,4.0);
var noise_scale = Vector2(4.0,4.0);


export var noise_lacunarity = 2.0;
export var noise_octaves = 4;
export var noise_period = 64.0;
export var noise_persistence = 0.35;
export var noise_seed = 0;


export var ridged_noise_amplitude = 1.5;
export var ridged_noise_power = 6;
export var ridged_noise_scale = Vector2(2,2);

onready var noise_mesh = self.get_mesh();
onready var noiseGenerator = OpenSimplexNoise.new();
onready var ridgedNoiseGenerator = OpenSimplexNoise.new();


export var liveRefresh = false;
export var animate = false;



func smin(a : float, b : float, k : float):
	var h = clamp(0.5 + 0.5*(a-b)/k, 0.0, 1.0);
	return (a * (1-h) + b * h) - k*h*(1.0-h);

func distance(a : Vector2,b : Vector2):
	return sqrt(pow(a.x-b.x,2)+pow(a.y-b.y,2));

onready var MAX_CIRCLE_DISTANCE = min(noise_size.x,noise_size.y) / 2.0;

func circle_distance(coord : Vector2):
	var dis = distance(coord,Vector2(0.0,0.0));
	dis /= MAX_CIRCLE_DISTANCE;
	
	dis = smin(pow(dis,0.15),pow(dis+0.5,4),0.999999)
	return clamp(1 - dis,0,1);


func update_noise_settings():
	
	noise_scale.x = max(1,floor(400.0/noise_size.x));
	noise_scale.y = max(1,floor(400.0/noise_size.y));
	
	noise_amplitude = 2.0 + min(noise_scale.x,noise_scale.y)/200.0;
	
	
	noiseGenerator.seed = noise_seed;
	noiseGenerator.octaves = noise_octaves;
	noiseGenerator.period = noise_period;
	noiseGenerator.persistence = noise_persistence;
	noiseGenerator.lacunarity = noise_lacunarity;
	
	ridgedNoiseGenerator.seed = noise_seed;
	ridgedNoiseGenerator.octaves = noise_octaves;
	ridgedNoiseGenerator.period = noise_period;
	ridgedNoiseGenerator.persistence = noise_persistence;
	ridgedNoiseGenerator.lacunarity = noise_lacunarity;
	
func get_transformed_noise_3d(coord : Vector2, generator, scale_factor):
	return generator.get_noise_3d(coord.x*scale_factor.x + noise_shift.x,coord.y*scale_factor.y + noise_shift.y , noise_shift.z);
	

func get_noise_mask(coord : Vector2, midpoint : float):
	return 1 if get_transformed_noise_3d(coord, noiseGenerator, noise_scale) > midpoint else -1;

func get_ridged_noise(coord : Vector2):
	var height =  1 - abs(get_transformed_noise_3d(coord, ridgedNoiseGenerator, ridged_noise_scale));
	height *= ridged_noise_amplitude;
	height = pow(height,ridged_noise_power);
	return height;

func get_noise_height(coord : Vector2):
	var height = get_transformed_noise_3d(coord, noiseGenerator, noise_scale);
	height = (height+1)/2;
	
	height *= noise_amplitude;
	height = pow(height,noise_power);
	
	return height;

func get_island_height(coord : Vector2):
	var height =  get_noise_height(coord);
	var ridges = get_ridged_noise(coord);
	
	var circle = circle_distance(coord);
	height *= circle;
	ridges *= pow(circle,1.25);
	
	height += ridges;
	
	
	
	
	if(height < 0.25):
		noiseGenerator.seed += 100;
		height -= (get_transformed_noise_3d(coord, noiseGenerator, noise_scale)+1)/12;
		noiseGenerator.seed = noise_seed;
	
	if(height < 0.01):
		height = 0;
	
	return height;

func update_mesh(output : bool):
	var st = SurfaceTool.new();
	noise_mesh.subdivide_width = noise_precision.x * noise_size.x;
	noise_mesh.subdivide_depth = noise_precision.y * noise_size.y;
	noise_mesh.size = noise_size;
	
	st.create_from(noise_mesh, 0);
	var array_plane = st.commit();
	
	var mdt = MeshDataTool.new();
	mdt.create_from_surface(array_plane, 0);
	
	var count = mdt.get_vertex_count();
	for i in range(count):
		var vtx = mdt.get_vertex(i)
		vtx.y = get_island_height(Vector2(vtx.x,vtx.z));
		if(vtx.y > 0):
			mdt.set_vertex(i, vtx);
		#Need to find a way to delete it
		
		#if(output):
		#	print(floor(i/count * 100),'%');
	
	
	for s in range(array_plane.get_surface_count()):
		array_plane.surface_remove(s)
	
	mdt.commit_to_surface(array_plane);
	st.create_from(array_plane, 0);
	st.generate_normals();
	
	self.mesh = st.commit();
	

func _ready():
	update_noise_settings();
	update_mesh(true);



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if liveRefresh:
		if animate:
			noise_shift.z += delta * 50;
		update_noise_settings();
		update_mesh(false);
